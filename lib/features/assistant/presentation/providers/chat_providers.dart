import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAtMs,
  });

  final String id;
  final String text;
  final bool isUser;
  final int createdAtMs;
}

class ChatController extends Notifier<List<ChatMessage>> {
  final _rand = Random();

  @override
  List<ChatMessage> build() {
    return <ChatMessage>[
      ChatMessage(
        id: 'welcome',
        text: 'Hi! I’m your AI assistant (placeholder). Ask me anything.',
        isUser: false,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    state = [
      ...state,
      ChatMessage(
        id: 'u-$now-${_rand.nextInt(1 << 32)}',
        text: trimmed,
        isUser: true,
        createdAtMs: now,
      ),
    ];

    // Placeholder AI response: keep it deterministic and offline for now.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    state = [
      ...state,
      ChatMessage(
        id: 'a-${now + 1}-${_rand.nextInt(1 << 32)}',
        text:
            "Got it. (Placeholder response)\n\nIf you want, I can help you break that into steps and add it as a goal.",
        isUser: false,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
  }
}

final chatControllerProvider = NotifierProvider<ChatController, List<ChatMessage>>(
  ChatController.new,
);

