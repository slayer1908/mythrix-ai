import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/ai/content_generation_service.dart';
import '../../core/services/hive_service.dart';
import '../models/chat_message.dart';
import '../models/content_draft.dart';
import 'ai_providers.dart';

const _chatHistoryKey = 'chat.history.v1';

/// Open/closed state of the chat drawer.
final chatDrawerOpenProvider = StateProvider<bool>((_) => false);

/// Conversation state — the full ordered list of chat messages.
/// Persists to Hive so messages survive page refresh / app restart.
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._ref) : super(_loadInitial()) {
    // Persist on every state change.
    addListener((_) => _save());
  }

  final Ref _ref;
  final _uuid = const Uuid();
  StreamSubscription<GenerationChunk>? _genSub;

  static final _greeting = ChatMessage(
    id: const Uuid().v4(),
    role: ChatRole.assistant,
    text:
        "👋 Hi, I'm Mythrix. Ask me anything about your marketing — campaigns, copy, audiences, what to optimize.",
  );

  /// Load saved history (if any) from Hive at boot.
  static List<ChatMessage> _loadInitial() {
    try {
      final raw = HiveService.instance.cache.get(_chatHistoryKey);
      if (raw is List && raw.isNotEmpty) {
        return raw.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return ChatMessage(
            id: m['id'] as String,
            role: ChatRole.values.firstWhere(
              (r) => r.name == m['role'],
              orElse: () => ChatRole.assistant,
            ),
            text: m['text'] as String? ?? '',
            sentAt: DateTime.tryParse(m['sentAt'] as String? ?? '') ??
                DateTime.now(),
          );
        }).toList();
      }
    } catch (_) {
      // Corrupt cache — fall back to greeting.
    }
    return [_greeting];
  }

  /// Save the current list back to Hive.
  void _save() {
    try {
      final encoded = state
          .where((m) => !m.streaming)
          .map((m) => {
                'id': m.id,
                'role': m.role.name,
                'text': m.text,
                'sentAt': m.sentAt.toIso8601String(),
              })
          .toList();
      HiveService.instance.cache.put(_chatHistoryKey, encoded);
    } catch (_) {
      // Storage errors shouldn't crash the chat.
    }
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    await _genSub?.cancel();

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      text: text.trim(),
    );

    final assistantMsg = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      text: '',
      streaming: true,
    );

    state = [...state, userMsg, assistantMsg];

    final router = _ref.read(aiRouterProvider);
    final brief = ContentBrief(
      type: ContentType.socialPost,
      tone: ContentTone.conversational,
      prompt:
          'Conversation:\n${_history()}\n\nUser asks: $text\n\nReply naturally as Mythrix, the AI marketing assistant. Be concise (≤ 3 short paragraphs). Use markdown if useful. Don\'t mention you\'re an LLM.',
      variants: 1,
      maxTokens: 600,
    );

    try {
      _genSub = router.generate(brief).listen(
        (chunk) {
          if (chunk.isFinal) return;
          _updateAssistant((m) => m.copyWith(text: m.text + chunk.text));
        },
        onError: (Object e) {
          _updateAssistant(
            (m) => m.copyWith(
              text: m.text.isEmpty
                  ? '⚠️ Something went wrong: $e'
                  : '${m.text}\n\n⚠️ Stream interrupted: $e',
              streaming: false,
            ),
          );
        },
        onDone: () => _updateAssistant((m) => m.copyWith(streaming: false)),
        cancelOnError: true,
      );
    } catch (e) {
      _updateAssistant(
        (m) => m.copyWith(
          text: '⚠️ Could not reach the AI: $e',
          streaming: false,
        ),
      );
    }
  }

  String _history() {
    return state.where((m) => !m.streaming).map((m) {
      final who = m.role == ChatRole.user ? 'User' : 'Mythrix';
      return '$who: ${m.text}';
    }).join('\n');
  }

  void _updateAssistant(ChatMessage Function(ChatMessage) update) {
    if (state.isEmpty) return;
    final last = state.last;
    if (last.role != ChatRole.assistant) return;
    state = [...state.sublist(0, state.length - 1), update(last)];
  }

  void reset() {
    _genSub?.cancel();
    state = [
      ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        text: "👋 Fresh start. What's on your mind?",
      ),
    ];
  }

  @override
  void dispose() {
    _genSub?.cancel();
    super.dispose();
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
        (ref) => ChatNotifier(ref));
