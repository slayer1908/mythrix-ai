import 'package:flutter/material.dart';

/// Notification category — drives icon, color tint, and route on tap.
enum NotificationKind {
  campaign,
  post,
  content,
  image,
  deal,
  email,
  automation,
  system,
}

extension NotificationKindX on NotificationKind {
  IconData get icon {
    switch (this) {
      case NotificationKind.campaign:
        return Icons.campaign_rounded;
      case NotificationKind.post:
        return Icons.send_rounded;
      case NotificationKind.content:
        return Icons.edit_note_rounded;
      case NotificationKind.image:
        return Icons.image_rounded;
      case NotificationKind.deal:
        return Icons.handshake_rounded;
      case NotificationKind.email:
        return Icons.mail_outline_rounded;
      case NotificationKind.automation:
        return Icons.bolt_rounded;
      case NotificationKind.system:
        return Icons.auto_awesome_rounded;
    }
  }

  String get label {
    switch (this) {
      case NotificationKind.campaign:
        return 'Campaign';
      case NotificationKind.post:
        return 'Post';
      case NotificationKind.content:
        return 'Content';
      case NotificationKind.image:
        return 'Image';
      case NotificationKind.deal:
        return 'Deal';
      case NotificationKind.email:
        return 'Email';
      case NotificationKind.automation:
        return 'Automation';
      case NotificationKind.system:
        return 'Mythrix';
    }
  }
}

/// A single notification entry in the user's feed.
class AppNotification {
  AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.route,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? route;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        createdAt: createdAt,
        route: route,
        read: read ?? this.read,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'route': route,
        'read': read,
      };

  static AppNotification fromMap(Map<String, dynamic> m) => AppNotification(
        id: m['id'] as String,
        kind: NotificationKind.values.firstWhere(
          (k) => k.name == m['kind'],
          orElse: () => NotificationKind.system,
        ),
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
        route: m['route'] as String?,
        read: m['read'] as bool? ?? false,
      );
}
