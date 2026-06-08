import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/firestore_sync_service.dart';
import '../../core/services/hive_service.dart';
import '../models/brand_profile.dart';

const _profileKey = 'brand.profile.v1';        // legacy single-brand storage
const _brandsListKey = 'brands.list.v1';        // new multi-brand storage
const _activeBrandIdKey = 'brands.active.id.v1';
const _onboardingDoneKey = 'brand.onboarding.done.v1';

/// Multi-brand workspace state. The list is the source of truth; `state` is the
/// active brand for backwards compatibility with everything that reads
/// `brandProfileProvider`.
class BrandProfileNotifier extends StateNotifier<BrandProfile?> {
  BrandProfileNotifier()
      : _brands = _loadBrands(),
        _activeId = _loadActiveId(),
        super(null) {
    // Set initial active brand from list.
    state = _activeBrand();
    addListener((_) => _saveActive());
  }

  List<BrandProfile> _brands;
  String? _activeId;
  final _uuid = const Uuid();

  static List<BrandProfile> _loadBrands() {
    try {
      final raw = HiveService.instance.cache.get(_brandsListKey);
      if (raw is List && raw.isNotEmpty) {
        return raw
            .map((e) => BrandProfile.fromMap(Map<dynamic, dynamic>.from(e as Map)))
            .toList();
      }
      // Migrate legacy single brand.
      final legacy = HiveService.instance.cache.get(_profileKey);
      if (legacy is Map) {
        final p = BrandProfile.fromMap(Map<dynamic, dynamic>.from(legacy));
        return [p];
      }
    } catch (_) {}
    return [];
  }

  static String? _loadActiveId() {
    try {
      final v = HiveService.instance.cache.get(_activeBrandIdKey);
      if (v is String) return v;
    } catch (_) {}
    return null;
  }

  BrandProfile? _activeBrand() {
    if (_brands.isEmpty) return null;
    if (_activeId != null) {
      try {
        return _brands.firstWhere((b) => b.id == _activeId);
      } catch (_) {}
    }
    _activeId = _brands.first.id;
    return _brands.first;
  }

  void _saveActive() {
    try {
      HiveService.instance.cache.put(
        _brandsListKey,
        _brands.map((b) => b.toMap()).toList(),
      );
      if (_activeId != null) {
        HiveService.instance.cache.put(_activeBrandIdKey, _activeId!);
      }
      // Keep legacy mirror for any reader still using it.
      if (state != null) {
        HiveService.instance.cache.put(_profileKey, state!.toMap());
      } else {
        HiveService.instance.cache.delete(_profileKey);
      }
    } catch (_) {}
  }

  List<BrandProfile> get brands => List.unmodifiable(_brands);
  String? get activeId => _activeId;

  /// Save the FIRST brand from onboarding. Becomes the active brand.
  void save(BrandProfile profile) {
    final withId = profile.id.isNotEmpty ? profile : profile.copyWith(id: _uuid.v4());
    _brands = [..._brands.where((b) => b.id != withId.id), withId];
    _activeId = withId.id;
    state = withId;
    HiveService.instance.cache.put(_onboardingDoneKey, true);
    // Fire-and-forget cloud sync.
    FirestoreSyncService.instance.saveBrand(withId);
    FirestoreSyncService.instance.setActiveBrandId(withId.id);
  }

  /// Add a NEW brand from the "Add brand" flow.
  void addBrand(BrandProfile profile) {
    final withId = profile.id.isEmpty ? profile.copyWith(id: _uuid.v4()) : profile;
    _brands = [..._brands, withId];
    _activeId = withId.id;
    state = withId;
    FirestoreSyncService.instance.saveBrand(withId);
    FirestoreSyncService.instance.setActiveBrandId(withId.id);
  }

  /// Switch the currently active brand. Every screen that reads brandProfileProvider
  /// rebuilds in response.
  void switchTo(String brandId) {
    if (_brands.any((b) => b.id == brandId)) {
      _activeId = brandId;
      state = _brands.firstWhere((b) => b.id == brandId);
      FirestoreSyncService.instance.setActiveBrandId(brandId);
    }
  }

  /// Update the currently active brand (used by Brand Assets edit).
  void updateActive(BrandProfile updated) {
    if (state == null) return;
    final id = state!.id;
    final merged = updated.copyWith(id: id);
    _brands = _brands.map((b) => b.id == id ? merged : b).toList();
    state = merged;
    FirestoreSyncService.instance.saveBrand(merged);
  }

  void removeBrand(String brandId) {
    _brands = _brands.where((b) => b.id != brandId).toList();
    if (_activeId == brandId) {
      _activeId = _brands.isNotEmpty ? _brands.first.id : null;
      state = _activeBrand();
    }
    FirestoreSyncService.instance.removeBrand(brandId);
  }

  /// Pull brands from Firestore after sign-in. Merges with local Hive cache —
  /// cloud is the source of truth where there are conflicts on `id`.
  Future<void> syncFromCloud() async {
    final remote = await FirestoreSyncService.instance.loadAll();
    if (remote == null || remote.brands.isEmpty) return;

    final byId = {for (final b in _brands) b.id: b};
    for (final b in remote.brands) {
      byId[b.id] = b; // cloud overwrites local
    }
    _brands = byId.values.toList();
    if (remote.activeId != null &&
        _brands.any((b) => b.id == remote.activeId)) {
      _activeId = remote.activeId;
    } else if (_brands.isNotEmpty && _activeId == null) {
      _activeId = _brands.first.id;
    }
    state = _activeBrand();
    if (state != null && state!.isComplete) {
      HiveService.instance.cache.put(_onboardingDoneKey, true);
    }
  }

  void clear() {
    _brands = [];
    _activeId = null;
    state = null;
    HiveService.instance.cache.delete(_onboardingDoneKey);
  }
}

final brandProfileProvider =
    StateNotifierProvider<BrandProfileNotifier, BrandProfile?>(
        (_) => BrandProfileNotifier());

/// All brands the user has set up. Used by the Brand Switcher in the topbar.
final allBrandsProvider = Provider<List<BrandProfile>>(
    (ref) => ref.watch(brandProfileProvider.notifier).brands);

/// True if the user has finished onboarding.
final onboardingDoneProvider = Provider<bool>((ref) {
  final profile = ref.watch(brandProfileProvider);
  if (profile != null && profile.isComplete) return true;
  try {
    return HiveService.instance.cache.get(_onboardingDoneKey) == true;
  } catch (_) {
    return false;
  }
});
