import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../data/models/brand_profile.dart';

/// Cloud sync wrapper around Firestore for the multi-brand workspace.
///
/// Document layout:
///   users/{uid}                            -> top-level user record (email, plan, accountType)
///   users/{uid}/brands/{brandId}           -> each BrandProfile the user has
///   users/{uid}/meta/activeBrand           -> which brandId is currently selected
///
/// All reads/writes are best-effort: if Firebase isn't initialized (offline or
/// not configured) every method is a no-op so the local Hive cache still works.
class FirestoreSyncService {
  FirestoreSyncService._();
  static final FirestoreSyncService instance = FirestoreSyncService._();

  final Logger _log = Logger();
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Persist a single brand. Creates or updates the document at
  /// users/{uid}/brands/{brandId}.
  Future<void> saveBrand(BrandProfile brand) async {
    final uid = _uid;
    final db = _db;
    if (uid == null || db == null) return;
    if (brand.id.isEmpty) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('brands')
          .doc(brand.id)
          .set(brand.toMap(), SetOptions(merge: true));

      // Top-level user doc records the account type and the email so we can
      // segment/analyze later.
      await db.collection('users').doc(uid).set({
        'email': FirebaseAuth.instance.currentUser?.email,
        'displayName': FirebaseAuth.instance.currentUser?.displayName,
        'accountType': brand.accountType.name,
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _log.w('Firestore saveBrand failed: $e');
    }
  }

  /// Persist the entire brands list (used after add / remove / reorder).
  Future<void> saveAllBrands(List<BrandProfile> brands) async {
    final uid = _uid;
    final db = _db;
    if (uid == null || db == null) return;
    try {
      final batch = db.batch();
      final col = db.collection('users').doc(uid).collection('brands');
      for (final b in brands) {
        if (b.id.isEmpty) continue;
        batch.set(col.doc(b.id), b.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      _log.w('Firestore saveAllBrands failed: $e');
    }
  }

  /// Set which brand is currently active for this user.
  Future<void> setActiveBrandId(String brandId) async {
    final uid = _uid;
    final db = _db;
    if (uid == null || db == null) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('meta')
          .doc('activeBrand')
          .set({'brandId': brandId}, SetOptions(merge: true));
    } catch (e) {
      _log.w('Firestore setActiveBrandId failed: $e');
    }
  }

  /// Delete a brand from the user's workspace.
  Future<void> removeBrand(String brandId) async {
    final uid = _uid;
    final db = _db;
    if (uid == null || db == null) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('brands')
          .doc(brandId)
          .delete();
    } catch (e) {
      _log.w('Firestore removeBrand failed: $e');
    }
  }

  /// Load all brands + active-brand ID for the signed-in user.
  /// Returns null if not signed in or Firestore unreachable.
  Future<({List<BrandProfile> brands, String? activeId})?> loadAll() async {
    final uid = _uid;
    final db = _db;
    if (uid == null || db == null) return null;
    try {
      final snap =
          await db.collection('users').doc(uid).collection('brands').get();
      final brands = snap.docs
          .map((d) => BrandProfile.fromMap(d.data()))
          .toList();
      final activeSnap = await db
          .collection('users')
          .doc(uid)
          .collection('meta')
          .doc('activeBrand')
          .get();
      final activeId = activeSnap.data()?['brandId'] as String?;
      return (brands: brands, activeId: activeId);
    } catch (e) {
      _log.w('Firestore loadAll failed: $e');
      return null;
    }
  }
}
