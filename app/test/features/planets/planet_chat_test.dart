import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/core/widgets/index.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_chat_message.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/data/repositories/mock_planet_chat_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/data/services/call_service.dart';
import 'package:dreem_world/features/planets/chat/planet_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('PlanetChatMessage: сериализация', () {
    test('toJson/fromJson сохраняют поля сообщения', () {
      final DateTime created = DateTime.parse('2026-11-18T10:00:00.000Z');
      final PlanetChatMessage message = PlanetChatMessage(
        id: 'm1',
        senderId: 'u1',
        senderName: 'Иван',
        text: 'Привет, сообщество!',
        createdAt: created,
      );

      final PlanetChatMessage restored = PlanetChatMessage.fromJson(
        message.toJson(),
      );

      expect(restored.id, 'm1');
      expect(restored.senderId, 'u1');
      expect(restored.senderName, 'Иван');
      expect(restored.text, 'Привет, сообщество!');
      expect(restored.createdAt, created);
    });

    test('fromJson терпим к отсутствующим полям', () {
      final PlanetChatMessage message = PlanetChatMessage.fromJson(
        <String, dynamic>{'id': 'x'},
      );

      expect(message.id, 'x');
      expect(message.senderId, '');
      expect(message.senderName, '');
      expect(message.text, '');
      expect(message.createdAt, isNull);
    });

    test('toMessage переносит текст и отправителя', () {
      final PlanetChatMessage message = PlanetChatMessage(
        id: 'm1',
        senderId: 'u1',
        senderName: 'Иван',
        text: 'Текст',
        createdAt: DateTime.parse('2026-11-18T10:00:00.000Z'),
      );

      expect(message.toMessage().id, 'm1');
      expect(message.toMessage().senderId, 'u1');
      expect(message.toMessage().text, 'Текст');
    });
  });

  group('Общий чат планеты: мок-репозиторий', () {
    test('watchMessages отдаёт сид и добавленное сообщение', () async {
      final MockPlanetChatRepository repository = MockPlanetChatRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      final Planet planet = const MockPlanetRepository().byId('p_animals')!;
      final List<PlanetChatMessage> initial = await repository
          .watchMessages(planet)
          .first;
      expect(initial, isNotEmpty);

      await repository.sendMessage(planet, 'Новое сообщение', senderName: 'Я');
      final List<PlanetChatMessage> updated = await repository
          .watchMessages(planet)
          .first;

      expect(updated.length, initial.length + 1);
      expect(updated.last.text, 'Новое сообщение');
      expect(updated.last.senderId, 'u1');
      expect(updated.last.senderName, 'Я');
    });
  });

  group('Экран общего чата планеты', () {
    testWidgets('показывает пояснение, сообщения и поле ввода', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPlanetChatRepository repository = MockPlanetChatRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetChatRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetChatScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.text('Общий чат. Сообщения видят все участники планеты.'),
        findsOneWidget,
      );
      expect(find.textContaining('Всем привет!'), findsOneWidget);
      expect(find.textContaining('Собираюсь на выходных'), findsOneWidget);
    });

    testWidgets('отправляет новое сообщение в общий чат', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPlanetChatRepository repository = MockPlanetChatRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetChatRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetChatScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      const String message = 'Привет из теста сообщества';
      await tester.enterText(find.byType(TextField), message);
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('отправляет сообщение по действию «отправить» (Enter в вебе)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPlanetChatRepository repository = MockPlanetChatRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetChatRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetChatScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      const String message = 'Отправка по Enter';
      await tester.enterText(find.byType(TextField), message);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('вставляет смайлик в поле ввода', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPlanetChatRepository repository = MockPlanetChatRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetChatRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetChatScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      expect(find.byType(EmojiPicker), findsNothing);
      await tester.tap(find.byIcon(Icons.emoji_emotions_outlined));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      expect(find.byType(EmojiPicker), findsOneWidget);

      await tester.tap(find.text('😀'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      final TextField field = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(field.controller!.text, '😀');
    });

    testWidgets('запускает звонок сообщества из листа звонка', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockPlanetChatRepository repository = MockPlanetChatRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);
      final _FakeCallService calls = _FakeCallService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetChatRepositoryProvider.overrideWithValue(repository),
            callServiceProvider.overrideWithValue(calls),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetChatScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(Duration.zero);

      expect(find.byIcon(Icons.call_outlined), findsOneWidget);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.videocam_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Видеозвонок'), findsOneWidget);

      await tester.tap(find.text('Видеозвонок'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(calls.video, isTrue);
      expect(calls.room, 'DreamWorld-planet-p_animals');
    });
  });
}

class _FakeCallService implements CallService {
  bool? video;
  String? room;

  @override
  String roomUrl(String room) => 'https://meet.jit.si/$room';

  @override
  Future<bool> startCall({
    required String room,
    required String displayName,
    bool video = true,
  }) async {
    this.video = video;
    this.room = room;
    return true;
  }
}
