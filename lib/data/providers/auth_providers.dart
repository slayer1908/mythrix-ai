import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../models/user_account.dart';

/// Stream of the current user; null when signed-out.
final authStateProvider = StreamProvider<UserAccount?>((ref) {
  return AuthService.instance.userChanges;
});

/// Synchronous accessor for guards / quick reads.
final currentUserProvider = Provider<UserAccount?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// True once we've attempted session restore at least once.
final authReadyProvider = StateProvider<bool>((_) => false);
