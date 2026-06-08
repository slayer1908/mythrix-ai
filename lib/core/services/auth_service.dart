import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../../data/models/user_account.dart';
import 'secure_storage_service.dart';

/// Real Firebase-backed authentication. Replaces the previous mock service
/// while keeping the exact same public API so every caller still works.
///
/// V1 supports: email/password signup + signin, Google sign-in, password
/// reset, sign-out, restore-session. Apple sign-in stub returns a friendly
/// "coming soon" error until we wire up native config.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _userController = StreamController<UserAccount?>.broadcast();
  Stream<UserAccount?> get userChanges => _userController.stream;
  UserAccount? _currentUser;
  UserAccount? get currentUser => _currentUser;

  final Logger _log = Logger();
  fb.FirebaseAuth get _fb => fb.FirebaseAuth.instance;

  bool _wiredAuthStream = false;

  /// Restore session from Firebase. If there's a cached user, emit them.
  Future<UserAccount?> restoreSession() async {
    _wireAuthStream();
    final fbUser = _fb.currentUser;
    if (fbUser == null) {
      _emit(null);
      return null;
    }
    final user = _toAccount(fbUser);
    await _persistLocal(user);
    _emit(user);
    return user;
  }

  /// Subscribe to Firebase's authStateChanges so the rest of the app reacts
  /// to sign-in / sign-out automatically (e.g. through router redirects).
  void _wireAuthStream() {
    if (_wiredAuthStream) return;
    _wiredAuthStream = true;
    _fb.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        _emit(null);
        return;
      }
      final user = _toAccount(fbUser);
      await _persistLocal(user);
      _emit(user);
    });
  }

  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _wireAuthStream();
    try {
      final cred = await _fb.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _toAccount(cred.user!);
      await _persistLocal(user);
      _emit(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  Future<UserAccount> signUp({
    required String email,
    required String password,
    required String fullName,
    required String workspaceName,
  }) async {
    _wireAuthStream();
    try {
      final cred = await _fb.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Save display name on the Firebase user.
      await cred.user!.updateDisplayName(fullName);
      await cred.user!.reload();

      final user = _toAccount(_fb.currentUser ?? cred.user!).copyWith(
        fullName: fullName,
        workspaceName: workspaceName,
      );
      await _persistLocal(user);
      _emit(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  Future<void> signInWithProvider(SocialProvider provider) async {
    _wireAuthStream();
    try {
      switch (provider) {
        case SocialProvider.google:
          await _signInWithGoogle();
          break;
        case SocialProvider.apple:
          throw const AuthException(
              'Apple Sign-In ships with the iOS/macOS release. Use Google or email for now.');
        case SocialProvider.microsoft:
          throw const AuthException(
              'Microsoft Sign-In lands in the next pass. Use Google or email for now.');
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  /// Google sign-in. On web we use Firebase's built-in popup flow which
  /// handles everything in-browser; on native we use google_sign_in.
  Future<void> _signInWithGoogle() async {
    if (kIsWeb) {
      final provider = fb.GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      final cred = await _fb.signInWithPopup(provider);
      if (cred.user == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      return;
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled.');
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _fb.signInWithCredential(credential);
  }

  /// Send password-reset email. Used by the "Forgot password?" link.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _fb.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _fb.signOut();
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }
    } finally {
      await SecureStorageService.instance.deleteSecure(AppConstants.kAuthToken);
      await SecureStorageService.instance.deleteSecure(AppConstants.kRefreshToken);
      await SecureStorageService.instance.remove(AppConstants.kUserId);
      _emit(null);
    }
  }

  // ----- helpers --------------------------------------------------------

  UserAccount _toAccount(fb.User u) {
    final displayName = u.displayName?.trim();
    return UserAccount(
      id: u.uid,
      email: u.email ?? '',
      fullName: displayName != null && displayName.isNotEmpty
          ? displayName
          : _nameFromEmail(u.email ?? 'friend'),
      workspaceName: 'My workspace',
    );
  }

  Future<void> _persistLocal(UserAccount user) async {
    try {
      // Cache the user ID locally so we can render greetings + workspace
      // names instantly on next boot before the auth stream emits.
      await SecureStorageService.instance
          .setString(AppConstants.kUserId, user.id);
    } catch (e) {
      _log.w('Local user-ID persist failed: $e');
    }
  }

  void _emit(UserAccount? user) {
    _currentUser = user;
    _userController.add(user);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    final cleaned = local.replaceAll(RegExp(r'[._-]'), ' ');
    return cleaned
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
  }

  /// Turn Firebase's cryptic error codes into something the user can read.
  String _friendly(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "That doesn't look like a valid email.";
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'No account with that email + password. Try Sign up.';
      case 'wrong-password':
        return 'Wrong password. Try again or click "Forgot password".';
      case 'email-already-in-use':
        return 'An account already exists with that email — try signing in.';
      case 'weak-password':
        return 'That password is too weak. Use 8+ characters with a mix.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Contact support.';
      case 'network-request-failed':
        return "Can't reach Firebase. Check your internet and try again.";
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a minute and try again.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}

enum SocialProvider { google, apple, microsoft }

extension SocialProviderX on SocialProvider {
  String get label {
    switch (this) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.microsoft:
        return 'Microsoft';
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
