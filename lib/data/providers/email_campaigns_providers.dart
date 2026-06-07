import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';

const _emailCampaignsKey = 'email.campaigns.v1';

enum EmailStatus { draft, scheduled, sent }

class EmailCampaign {
  EmailCampaign({
    required this.id,
    required this.subject,
    required this.preview,
    required this.body,
    DateTime? createdAt,
    this.status = EmailStatus.draft,
    this.recipientCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String subject;
  final String preview;
  final String body;
  final DateTime createdAt;
  EmailStatus status;
  int recipientCount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'preview': preview,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'recipientCount': recipientCount,
      };

  static EmailCampaign fromMap(Map<dynamic, dynamic> m) => EmailCampaign(
        id: m['id'] as String,
        subject: m['subject'] as String? ?? '',
        preview: m['preview'] as String? ?? '',
        body: m['body'] as String? ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        status: EmailStatus.values.firstWhere(
          (s) => s.name == (m['status'] as String?),
          orElse: () => EmailStatus.draft,
        ),
        recipientCount: (m['recipientCount'] as num?)?.toInt() ?? 0,
      );
}

class EmailCampaignsNotifier extends StateNotifier<List<EmailCampaign>> {
  EmailCampaignsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<EmailCampaign> _load() {
    try {
      final raw = HiveService.instance.cache.get(_emailCampaignsKey);
      if (raw is List) {
        return raw.map((e) => EmailCampaign.fromMap(e as Map)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _emailCampaignsKey,
        state.map((c) => c.toMap()).toList(),
      );
    } catch (_) {}
  }

  String create({
    required String subject,
    required String preview,
    required String body,
    int recipientCount = 0,
  }) {
    final id = _uuid.v4();
    state = [
      EmailCampaign(
        id: id,
        subject: subject,
        preview: preview,
        body: body,
        recipientCount: recipientCount,
      ),
      ...state,
    ];
    return id;
  }

  void remove(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final emailCampaignsProvider =
    StateNotifierProvider<EmailCampaignsNotifier, List<EmailCampaign>>(
        (_) => EmailCampaignsNotifier());
