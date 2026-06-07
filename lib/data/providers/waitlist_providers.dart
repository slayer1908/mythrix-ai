import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/hive_service.dart';

const _key = 'waitlist.emails.v1';

class WaitlistEntry {
  WaitlistEntry({required this.email, required this.joinedAt, this.role});
  final String email;
  final DateTime joinedAt;
  final String? role;

  Map<String, dynamic> toMap() => {
        'email': email,
        'joinedAt': joinedAt.toIso8601String(),
        'role': role,
      };

  static WaitlistEntry fromMap(Map<dynamic, dynamic> m) => WaitlistEntry(
        email: m['email'] as String? ?? '',
        joinedAt: DateTime.tryParse(m['joinedAt'] as String? ?? '') ?? DateTime.now(),
        role: m['role'] as String?,
      );
}

class WaitlistNotifier extends StateNotifier<List<WaitlistEntry>> {
  WaitlistNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  static List<WaitlistEntry> _load() {
    try {
      final raw = HiveService.instance.cache.get(_key);
      if (raw is List) {
        return raw.map((e) => WaitlistEntry.fromMap(e as Map)).toList()
          ..sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(_key, state.map((e) => e.toMap()).toList());
    } catch (_) {}
  }

  /// Returns true if added, false if duplicate or invalid.
  bool add(String email, {String? role}) {
    final clean = email.trim().toLowerCase();
    if (!_isValid(clean)) return false;
    if (state.any((e) => e.email == clean)) return false;
    state = [WaitlistEntry(email: clean, joinedAt: DateTime.now(), role: role), ...state];
    return true;
  }

  bool _isValid(String e) {
    final re = RegExp(r'^[\w.+-]+@[\w-]+(?:\.[\w-]+)+$');
    return re.hasMatch(e);
  }

  void clear() => state = [];
}

final waitlistProvider =
    StateNotifierProvider<WaitlistNotifier, List<WaitlistEntry>>((_) => WaitlistNotifier());

final waitlistCountProvider = Provider<int>((ref) => ref.watch(waitlistProvider).length);
