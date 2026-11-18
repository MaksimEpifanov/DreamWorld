import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/conversation.dart';
import '../../data/models/message.dart';
import '../../data/models/profile.dart';
import '../../data/providers/app_providers.dart';

/// Слушает новые сообщения и показывает системное уведомление со звуком,
/// когда приложение не на переднем плане.
///
/// Уведомления нужны именно для свёрнутого приложения: если пользователь уже
/// смотрит на экран, обновления видны прямо в интерфейсе и баннер только мешал
/// бы. Слушатель монтируется один раз поверх всего приложения.
class ChatNotificationListener extends ConsumerStatefulWidget {
  const ChatNotificationListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ChatNotificationListener> createState() =>
      _ChatNotificationListenerState();
}

class _ChatNotificationListenerState
    extends ConsumerState<ChatNotificationListener>
    with WidgetsBindingObserver {
  final Set<String> _seenMessageIds = <String>{};
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(localNotificationServiceProvider).initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appLifecycleStateProvider.notifier).state = state;
  }

  @override
  Widget build(BuildContext context) {
    // Держим поток анкет «тёплым»: имя отправителя нужно мгновенно, а сам
    // поток в рабочей версии уже слушается на главном экране.
    ref.listen(discoveryProfilesProvider, (_, _) {});
    ref.listen<AsyncValue<List<Conversation>>>(conversationsProvider, (
      AsyncValue<List<Conversation>>? previous,
      AsyncValue<List<Conversation>> next,
    ) {
      final List<Conversation>? conversations = next.valueOrNull;
      if (conversations == null) return;
      _handleConversations(conversations);
    });
    return widget.child;
  }

  void _handleConversations(List<Conversation> conversations) {
    // Первый снимок только запоминаем: уведомлять о том, что уже прочитано
    // (или пришло до запуска), не нужно.
    if (!_seeded) {
      for (final Conversation conversation in conversations) {
        final String? id = conversation.lastMessage?.id;
        if (id != null) _seenMessageIds.add(id);
      }
      _seeded = true;
      return;
    }
    if (ref.read(appLifecycleStateProvider) == AppLifecycleState.resumed) {
      return;
    }

    final String currentUserId = ref.read(currentUserIdProvider);
    for (final Conversation conversation in conversations) {
      final Message? message = conversation.lastMessage;
      if (message == null) continue;
      if (!_seenMessageIds.add(message.id)) continue;
      if (message.senderId == currentUserId) continue;
      _notify(conversation, message);
    }
  }

  void _notify(Conversation conversation, Message message) {
    final String text = message.text.trim();
    ref
        .read(localNotificationServiceProvider)
        .showMessageNotification(
          conversationId: conversation.id,
          title: _senderName(message.senderId),
          body: text.isEmpty ? 'Новое сообщение' : text,
        );
  }

  String _senderName(String senderId) {
    final List<Profile>? profiles = ref
        .read(discoveryProfilesProvider)
        .valueOrNull;
    if (profiles != null) {
      for (final Profile profile in profiles) {
        if (profile.id == senderId && profile.name.trim().isNotEmpty) {
          return profile.name.trim();
        }
      }
    }
    return 'Новое сообщение';
  }
}
