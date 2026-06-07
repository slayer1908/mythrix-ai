import 'dart:async';

import '../constants/app_constants.dart';
import '../../data/models/user_account.dart';
import 'secure_storage_service.dart';

/// Authentication service. In V1 this works against a mock backend so the UI
/// is fully exercisable; real OAuth/Firebase wiring lives behind the same
/// interface and will be filled in across subsequent sessions.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _userController = StreamController<UserAccount?>.broadcast();
  Stream<UserAccount?> get userChanges => _userController.stream;

  UserAccount? _currentUser;
  UserAccount? get currentUser => _currentUser;

  /// Restore session from secure storage.
  Future<UserAccount?> restoreSession() async {
    final token = await SecureStorageService.instance.readSecure(AppConstants.kAuthToken);
    if (token == null) {
      _emit(null);
      return null;
    }
    // TODO: validate token against backend.
    final id = SecureStorageService.instance.getString(AppConstants.kUserId) ?? 'demo-user';
    final user = UserAccount(
      id: id,
      email: 'demo@mythrix.ai',
      fullName: 'Demo Marketer',
      workspaceName: 'Acme Brand Co.',
    );
    _emit(user);
    return user;
  }

  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulated network latency
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (email.isEmpty || password.length < 6) {
      throw const AuthException('Please enter a valid email and a 6+ character password.');
    }
    final user = UserAccount(
      id: 'user_${email.hashCode.abs()}',
      email: email,
      fullName: _nameFromEmail(email),
      workspaceName: 'Acme Brand Co.',
    );
    await _persist(user, token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}');
    _emit(user);
    return user;
  }

  Future<UserAccount> signUp({
    required String email,
    required String password,
    required String fullName,
    required String workspaceName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || !email.contains('@')) {
      throw const AuthException('That doesn\'t look like a valid email.');
    }
    if (password.length < 8) {
      throw const AuthException('Passwords need at least 8 characters.');
    }
    final user = UserAccount(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      workspaceName: workspaceName,
    );
    await _persist(user, token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}');
    _emit(user);
    return user;
  }

  Future<void> signInWithProvider(SocialProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = UserAccount(
      id: 'user_${provider.name}',
      email: '${provider.name}@mythrix.ai',
      fullName: 'Connected via ${provider.label}',
      workspaceName: 'Acme Brand Co.',
    );
    await _persist(user, token: 'mock-oauth-${provider.name}');
    _emit(user);
  }

  Future<void> signOut() async {
    await SecureStorageService.instance.deleteSecure(AppConstants.kAuthToken);
    await SecureStorageService.instance.deleteSecure(AppConstants.kRefreshToken);
    await SecureStorageService.instance.remove(AppConstants.kUserId);
    _emit(null);
  }

  Future<void> _persist(UserAccount user, {required String token}) async {
    await SecureStorageService.instance.writeSecure(AppConstants.kAuthToken, token);
    await SecureStorageService.instance.setString(AppConstants.kUserId, user.id);
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
