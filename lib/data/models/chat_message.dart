enum ChatRole { user, assistant, system }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    DateTime? sentAt,
    this.streaming = false,
  }) : sentAt = sentAt ?? DateTime.now();

  final String id;
  final ChatRole role;
  String text;
  final DateTime sentAt;
  bool streaming;

  ChatMessage copyWith({String? text, bool? streaming}) => ChatMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        sentAt: sentAt,
        streaming: streaming ?? this.streaming,
      );
}

/// Hard-coded quick action prompts shown above the input.
const List<({String label, String prompt})> kChatQuickActions = [
  (
    label: '📊 Summarize my campaigns',
    prompt:
        'Give me a quick health check on my active campaigns. What\'s working, what\'s not?',
  ),
  (
    label: '✍️ Draft an email',
    prompt:
        'Draft a punchy re-engagement email for customers who haven\'t purchased in 60 days.',
  ),
  (
    label: '💡 Suggest 3 ad creatives',
    prompt:
        'Suggest 3 fresh ad creative angles for a B2B SaaS targeting marketing leaders.',
  ),
  (
    label: '🎯 What should I optimize?',
    prompt:
        'Looking at my dashboard, what single change would give me the biggest ROAS lift this week?',
  ),
];
