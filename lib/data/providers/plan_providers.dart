import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/services/hive_service.dart';
import '../models/user_plan.dart';

const _planCacheKey = 'user.plan.v1';

/// State of the current user's billing plan.
/// Loads from Firestore (users/{uid}/meta/billing) and caches in Hive so
/// the UI can render plan badges instantly on next boot.
class UserPlanNotifier extends StateNotifier<UserPlan> {
  UserPlanNotifier() : super(_loadCached()) {
    addListener((_) => _save());
    _hydrateFromCloud();
  }

  final _log = Logger();

  static UserPlan _loadCached() {
    try {
      final raw = HiveService.instance.cache.get(_planCacheKey);
      if (raw is Map) return UserPlan.fromMap(raw);
    } catch (_) {}
    return UserPlan.defaultStarter();
  }

  void _save() {
    try {
      HiveService.instance.cache.put(_planCacheKey, state.toMap());
    } catch (_) {}
  }

  FirebaseFirestore? get _db {
    try { return FirebaseFirestore.instance; } catch (_) { return null; }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Try to load the latest plan from Firestore. If not present, write the
  /// default Starter plan so the user's record is initialized.
  Future<void> _hydrateFromCloud() async {
    final db = _db;
    final uid = _uid;
    if (db == null || uid == null) return;
    try {
      final doc = await db
          .collection('users').doc(uid)
          .collection('meta').doc('billing').get();
      if (doc.exists && doc.data() != null) {
        state = UserPlan.fromMap(doc.data()!);
      } else {
        // First time on this device — write the default plan to cloud.
        await _persistToCloud(state);
      }
    } catch (e) {
      _log.w('Plan hydrate failed: $e');
    }
  }

  Future<void> _persistToCloud(UserPlan plan) async {
    final db = _db;
    final uid = _uid;
    if (db == null || uid == null) return;
    try {
      await db
          .collection('users').doc(uid)
          .collection('meta').doc('billing')
          .set(plan.toMap(), SetOptions(merge: true));
    } catch (e) {
      _log.w('Plan persist failed: $e');
    }
  }

  /// Called when the user clicks "Start free trial" on the Pricing page.
  /// Locally toggles them to Pro + 14-day trial; on payment success the
  /// Stripe webhook will confirm. Until webhook is wired this just trusts.
  Future<void> startTrial(PlanTier tier) async {
    final newPlan = UserPlan(
      tier: tier,
      trialEndsAt: DateTime.now().add(const Duration(days: 14)),
      subscribedAt: null,
    );
    state = newPlan;
    await _persistToCloud(newPlan);
  }

  /// Called after Stripe Checkout success (webhook updates this in cloud,
  /// or the success-return URL handler updates it locally).
  Future<void> markPaid(PlanTier tier, {String? razorpayCustomerId}) async {
    final newPlan = UserPlan(
      tier: tier,
      subscribedAt: DateTime.now(),
      razorpayCustomerId: razorpayCustomerId ?? state.razorpayCustomerId,
      trialEndsAt: null,
    );
    state = newPlan;
    await _persistToCloud(newPlan);
  }

  /// Called when user clicks Cancel — marks for cancel at period end.
  Future<void> cancelAtPeriodEnd() async {
    final newPlan = UserPlan(
      tier: state.tier,
      trialEndsAt: state.trialEndsAt,
      subscribedAt: state.subscribedAt,
      razorpayCustomerId: state.razorpayCustomerId,
      cancelAtPeriodEnd: true,
    );
    state = newPlan;
    await _persistToCloud(newPlan);
  }

  /// Force a reload from cloud (used after returning from Stripe Checkout).
  Future<void> refresh() async {
    await _hydrateFromCloud();
  }

  /// Reset to starter (used for testing).
  Future<void> reset() async {
    state = UserPlan.defaultStarter();
    await _persistToCloud(state);
  }
}

final userPlanProvider =
    StateNotifierProvider<UserPlanNotifier, UserPlan>((_) => UserPlanNotifier());

/// Convenience selectors.
final planLimitsProvider = Provider<PlanLimits>((ref) {
  return ref.watch(userPlanProvider).limits;
});

final isProOrAboveProvider = Provider<bool>((ref) {
  final tier = ref.watch(userPlanProvider).tier;
  return tier == PlanTier.pro || tier == PlanTier.agency;
});

final trialDaysLeftProvider = Provider<int>((ref) {
  return ref.watch(userPlanProvider).trialDaysLeft;
});
