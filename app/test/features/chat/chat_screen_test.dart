import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/core/widgets/index.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/services/call_service.dart';
import 'package:dreem_world/features/chat/chat_screen.dart';
import 'package:dreem_world/features/chat/conversations_list_screen.dart';

void main() {
  Future<void> pumpChat(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const ChatScreen(conversationId: 'c_anna'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ChatScreen рендерит сообщения и поле ввода', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.text('Введите сообщение...'), findsOneWidget);
    expect(find.textContaining('Привет!'), findsOneWidget);
    expect(find.textContaining('Спасибо!'), findsOneWidget);
  });

  testWidgets('ChatScreen отправляет новое сообщение', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    const String message = 'Привет из теста';
    await tester.enterText(find.byType(TextField), message);
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text(message), findsOneWidget);
  });

  testWidgets('ChatScreen отправляет сообщение по действию «отправить» (Enter в вебе)', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    const String message = 'Отправка по Enter';
    await tester.enterText(find.byType(TextField), message);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text(message), findsOneWidget);
  });

  testWidgets('ChatScreen вставляет смайлик в поле ввода', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    expect(find.byType(EmojiPicker), findsNothing);
    await tester.tap(find.byIcon(Icons.emoji_emotions_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(EmojiPicker), findsOneWidget);

    await tester.tap(find.text('😀'));
    await tester.pumpAndSettle();

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '😀');
  });

  testWidgets('ChatScreen запускает звонок из листа звонка', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakeCallService calls = _FakeCallService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[callServiceProvider.overrideWithValue(calls)],
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const ChatScreen(conversationId: 'c_anna'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.call_outlined), findsOneWidget);
    expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.videocam_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Видеозвонок'), findsOneWidget);

    await tester.tap(find.text('Видеозвонок'));
    await tester.pumpAndSettle();
    expect(calls.started, isTrue);
    expect(calls.video, isTrue);
    expect(calls.room, 'DreamWorld-c_anna');

    await tester.tap(find.byIcon(Icons.call_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аудиозвонок'));
    await tester.pumpAndSettle();
    expect(calls.video, isFalse);
  });

  testWidgets('ChatScreen открывает профиль собеседника по нажатию на имя', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final GoRouter router = GoRouter(
      initialLocation: '/chat/c_anna',
      routes: <RouteBase>[
        GoRoute(
          path: '/chat/:id',
          builder: (BuildContext context, GoRouterState state) =>
              ChatScreen(conversationId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/user/:id',
          builder: (BuildContext context, GoRouterState state) => Scaffold(
            body: Text('Профиль ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.of(AppThemeName.neonViolet),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Открыть профиль'), findsOneWidget);
    await tester.tap(find.byTooltip('Открыть профиль'));
    await tester.pumpAndSettle();

    expect(find.text('Профиль p_anna'), findsOneWidget);
  });

  testWidgets('список чатов показывает три подвкладки', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const ConversationsListScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Все'), findsOneWidget);
    expect(find.text('По интересам'), findsOneWidget);
    expect(find.text('Непрочитанные'), findsOneWidget);
  });
}

class _FakeCallService implements CallService {
  bool started = false;
  bool? video;
  String? room;
  String? displayName;

  @override
  String roomUrl(String room) => 'https://meet.jit.si/$room';

  @override
  Future<bool> startCall({
    required String room,
    required String displayName,
    bool video = true,
  }) async {
    started = true;
    this.video = video;
    this.room = room;
    this.displayName = displayName;
    return true;
  }
}
