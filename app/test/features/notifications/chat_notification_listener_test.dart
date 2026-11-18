import 'dart:async';

import 'package:dreem_world/data/models/conversation.dart';
import 'package:dreem_world/data/models/message.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/services/notification_service.dart';
import 'package:dreem_world/features/notifications/chat_notification_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Записывает показанные уведомления вместо системных.
class _FakeNotificationService implements NotificationService {
  final List<({String conversationId, String title, String body})> messages =
      <({String conversationId, String title, String body})>[];
  int initializeCount = 0;

  @override
  Future<void> initialize() async {
    initializeCount++;
  }

  @override
  Future<void> showMessageNotification({
    required String conversationId,
    required String title,
    required String body,
  }) async {
    messages.add((conversationId: conversationId, title: title, body: body));
  }

  @override
  Future<void> cancelAll() async {}
}

Conversation _conversation({
  required String senderId,
  required String messageId,
  String text = 'Привет',
}) => Conversation(
  id: 'c1',
  participantIds: <String>['me', senderId],
  lastMessage: Message(
    id: messageId,
    conversationId: 'c1',
    senderId: senderId,
    text: text,
  ),
);

void main() {
  late StreamController<List<Conversation>> controller;
  late _FakeNotificationService service;

  Widget build({
    AppLifecycleState lifecycle = AppLifecycleState.paused,
    List<Profile> profiles = const <Profile>[],
  }) {
    return ProviderScope(
      overrides: <Override>[
        conversationsProvider.overrideWith((Ref ref) => controller.stream),
        currentUserIdProvider.overrideWithValue('me'),
        discoveryProfilesProvider.overrideWith(
          (Ref ref) => Stream<List<Profile>>.value(profiles),
        ),
        appLifecycleStateProvider.overrideWith((Ref ref) => lifecycle),
        localNotificationServiceProvider.overrideWithValue(service),
      ],
      child: const MaterialApp(
        home: ChatNotificationListener(child: SizedBox()),
      ),
    );
  }

  setUp(() {
    controller = StreamController<List<Conversation>>.broadcast();
    service = _FakeNotificationService();
  });

  tearDown(() async {
    await controller.close();
  });

  testWidgets('инициализирует сервис и уведомляет о новом сообщении в фоне', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(build());
    controller.add(const <Conversation>[]);
    await tester.pump();
    expect(service.initializeCount, 1);

    controller.add(<Conversation>[
      _conversation(senderId: 'other', messageId: 'm1', text: 'Как дела?'),
    ]);
    await tester.pump();

    expect(service.messages.length, 1);
    expect(service.messages.first.conversationId, 'c1');
    expect(service.messages.first.body, 'Как дела?');
  });

  testWidgets('на переднем плане уведомление не показывается', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(build(lifecycle: AppLifecycleState.resumed));
    controller.add(const <Conversation>[]);
    await tester.pump();

    controller.add(<Conversation>[
      _conversation(senderId: 'other', messageId: 'm1'),
    ]);
    await tester.pump();

    expect(service.messages, isEmpty);
  });

  testWidgets('свои сообщения и повторы не уведомляют', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(build());
    controller.add(const <Conversation>[]);
    await tester.pump();

    controller.add(<Conversation>[
      _conversation(senderId: 'me', messageId: 'm1'),
    ]);
    await tester.pump();
    expect(service.messages, isEmpty);

    controller.add(<Conversation>[
      _conversation(senderId: 'other', messageId: 'm2'),
    ]);
    await tester.pump();
    expect(service.messages.length, 1);

    controller.add(<Conversation>[
      _conversation(senderId: 'other', messageId: 'm2'),
    ]);
    await tester.pump();
    expect(service.messages.length, 1);
  });

  testWidgets('в заголовке — имя отправителя из анкет', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      build(
        profiles: const <Profile>[
          Profile(id: 'other', name: 'Анна', age: 25),
        ],
      ),
    );
    controller.add(const <Conversation>[]);
    await tester.pump();

    controller.add(<Conversation>[
      _conversation(senderId: 'other', messageId: 'm1'),
    ]);
    await tester.pump();

    expect(service.messages.single.title, 'Анна');
  });
}
