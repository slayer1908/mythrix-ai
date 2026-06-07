import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';

const _galleryKey = 'creative.gallery.v1';
const _draftsKey = 'content.drafts.v1';

/// A persistent record of one AI-generated image.
class GalleryImage {
  GalleryImage({
    required this.id,
    required this.url,
    required this.prompt,
    required this.style,
    required this.aspect,
    required this.seed,
    DateTime? createdAt,
    this.starred = false,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String url;
  final String prompt;
  final String style;
  final String aspect;
  final int seed;
  final DateTime createdAt;
  bool starred;

  Map<String, dynamic> toMap() => {
        'id': id,
        'url': url,
        'prompt': prompt,
        'style': style,
        'aspect': aspect,
        'seed': seed,
        'createdAt': createdAt.toIso8601String(),
        'starred': starred,
      };

  static GalleryImage fromMap(Map<dynamic, dynamic> m) => GalleryImage(
        id: m['id'] as String,
        url: m['url'] as String,
        prompt: m['prompt'] as String? ?? '',
        style: m['style'] as String? ?? '',
        aspect: m['aspect'] as String? ?? '1:1',
        seed: (m['seed'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        starred: m['starred'] as bool? ?? false,
      );
}

/// A persistent record of one AI-generated content draft.
class SavedDraft {
  SavedDraft({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.tone,
    DateTime? createdAt,
    this.starred = false,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String body;
  final String type;
  final String tone;
  final DateTime createdAt;
  bool starred;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'tone': tone,
        'createdAt': createdAt.toIso8601String(),
        'starred': starred,
      };

  static SavedDraft fromMap(Map<dynamic, dynamic> m) => SavedDraft(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        type: m['type'] as String? ?? 'socialPost',
        tone: m['tone'] as String? ?? 'friendly',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        starred: m['starred'] as bool? ?? false,
      );
}

// ---------------- Gallery ----------------

class GalleryNotifier extends StateNotifier<List<GalleryImage>> {
  GalleryNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  static List<GalleryImage> _load() {
    try {
      final raw = HiveService.instance.cache.get(_galleryKey);
      if (raw is List) {
        return raw.map((e) => GalleryImage.fromMap(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _galleryKey,
        state.map((g) => g.toMap()).toList(),
      );
    } catch (_) {}
  }

  void addMany(List<GalleryImage> images) {
    state = [...images, ...state];
  }

  void toggleStar(String id) {
    state = [
      for (final g in state)
        if (g.id == id)
          GalleryImage(
            id: g.id,
            url: g.url,
            prompt: g.prompt,
            style: g.style,
            aspect: g.aspect,
            seed: g.seed,
            createdAt: g.createdAt,
            starred: !g.starred,
          )
        else
          g,
    ];
  }

  void remove(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final galleryProvider =
    StateNotifierProvider<GalleryNotifier, List<GalleryImage>>(
        (_) => GalleryNotifier());

// ---------------- Drafts ----------------

class DraftsNotifier extends StateNotifier<List<SavedDraft>> {
  DraftsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<SavedDraft> _load() {
    try {
      final raw = HiveService.instance.cache.get(_draftsKey);
      if (raw is List) {
        return raw.map((e) => SavedDraft.fromMap(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _draftsKey,
        state.map((d) => d.toMap()).toList(),
      );
    } catch (_) {}
  }

  String add({
    required String title,
    required String body,
    required String type,
    required String tone,
  }) {
    final id = _uuid.v4();
    final draft = SavedDraft(id: id, title: title, body: body, type: type, tone: tone);
    state = [draft, ...state];
    return id;
  }

  void toggleStar(String id) {
    state = [
      for (final d in state)
        if (d.id == id)
          SavedDraft(
            id: d.id,
            title: d.title,
            body: d.body,
            type: d.type,
            tone: d.tone,
            createdAt: d.createdAt,
            starred: !d.starred,
          )
        else
          d,
    ];
  }

  void remove(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final draftsStoreProvider =
    StateNotifierProvider<DraftsNotifier, List<SavedDraft>>(
        (_) => DraftsNotifier());
