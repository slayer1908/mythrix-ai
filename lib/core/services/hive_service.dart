import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Centralized Hive bootstrap + box accessors.
///
/// Boxes:
///   * `cache`     — generic key/value cache for repository responses
///   * `drafts`    — content draft history (kept across restarts)
///   * `settings`  — app preferences not safe-stored
class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();
  final Logger _log = Logger();

  bool _initialized = false;

  Box<dynamic> get cache => Hive.box<dynamic>(AppConstants.boxCache);
  Box<dynamic> get drafts => Hive.box<dynamic>(AppConstants.boxDrafts);
  Box<dynamic> get settings => Hive.box<dynamic>(AppConstants.boxSettings);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await Hive.initFlutter('mythrix');

    await Future.wait<void>([
      Hive.openBox<dynamic>(AppConstants.boxCache),
      Hive.openBox<dynamic>(AppConstants.boxDrafts),
      Hive.openBox<dynamic>(AppConstants.boxSettings),
    ]);

    _log.i('Hive ready (3 boxes opened).');
  }

  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
