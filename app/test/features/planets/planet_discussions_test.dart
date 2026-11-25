import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/discussion_message.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_discussion.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/data/repositories/mock_planet_discussion_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/features/planets/discussions/planet_discussion_screen.dart';
import 'package:dreem_world/features/planets/discussions/planet_discussions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Обсуждения планеты', () {
    test('модели: сериализация и валидация оценки', () {
      final PlanetDiscussion discussion = PlanetDiscussion(
        id: 'd1',
        planetId: 'p_animals',
        title: 'Парк',
        authorId: 'u1',
        authorName: 'Аня',
        createdAt: '2026-11-24T10:00:00.000Z',
        topic: 'Природа',
      );
      final PlanetDiscussion restored = PlanetDiscussion.fromJson(
        discussion.toJson(),
      );
      expect(restored.title, 'Парк');
      expect(restored.topic, 'Природа');
      expect(restored.emoji, '💬');
      expect(restored.isAuthor('u1'), isTrue);

      final DiscussionMessage message = DiscussionMessage.fromJson(
        <String, dynamic>{...discussion.toJson(), 'rating': 6},
      );
      expect(message.rating, isNull);
      expect(
        DiscussionMessage.fromJson(<String, dynamic>{
          ...message.toJson(),
          'rating': 5,
        }).rating,
        5,
      );
    });

    test('мок-репозиторий: тема, сообщение, лайк и удаление', () async {
      final MockPlanetDiscussionRepository repository =
          MockPlanetDiscussionRepository(currentUserId: 'u1');
      addTearDown(repository.dispose);

      final Planet planet = const MockPlanetRepository().byId('p_animals')!;
      final List<PlanetDiscussion> initial = await repository
          .watchDiscussions(planet)
          .first;
      expect(initial, isNotEmpty);

      final PlanetDiscussion discussion = PlanetDiscussion(
        id: 'd_test',
        planetId: planet.id,
        title: 'Новая тема',
        authorId: 'u1',
        authorName: 'Вы',
        createdAt: DateTime.now().toIso8601String(),
        topic: 'Книги',
      );
      await repository.addDiscussion(planet, discussion);

      final DiscussionMessage message = DiscussionMessage(
        id: 'm_test',
        discussionId: discussion.id,
        authorId: 'u2',
        authorName: 'Друг',
        text: 'Отзыв',
        rating: 4,
        createdAt: DateTime.now().toIso8601String(),
      );
      await repository.addMessage(planet, discussion.id, message);

      List<DiscussionMessage> messages = await repository
          .watchMessages(planet.id, discussion.id)
          .first;
      expect(messages.single.text, 'Отзыв');

      await repository.toggleLike(planet, discussion.id, message.id, true);
      messages = await repository.watchMessages(planet.id, discussion.id).first;
      expect(messages.single.isLikedBy('u1'), isTrue);

      await repository.removeMessage(planet, discussion.id, message.id);
      messages = await repository.watchMessages(planet.id, discussion.id).first;
      expect(messages, isEmpty);

      final PlanetDiscussion updated =
          (await repository.watchDiscussions(planet).first).firstWhere(
            (PlanetDiscussion item) => item.id == discussion.id,
          );
      expect(updated.messagesCount, 0);

      await repository.removeDiscussion(planet, discussion.id);
      final List<PlanetDiscussion> after = await repository
          .watchDiscussions(planet)
          .first;
      expect(
        after.any((PlanetDiscussion item) => item.id == discussion.id),
        isFalse,
      );
    });

    testWidgets('экран списка обсуждений показывает кнопку и темы', (
      WidgetTester tester,
    ) async {
      final MockPlanetDiscussionRepository repository =
          MockPlanetDiscussionRepository(currentUserId: 'u1');
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetDiscussionRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetDiscussionsScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Создать обсуждение'), findsWidgets);
      expect(find.textContaining('обсуждени'), findsWidgets);
      expect(
        find.byKey(const ValueKey<String>('create-discussion-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discussion-filter-all')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discussion-filter-Природа')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discussion-filter-место')),
        findsNothing,
      );
    });

    testWidgets('тема обсуждения вводится свободным текстом', (
      WidgetTester tester,
    ) async {
      final MockPlanetDiscussionRepository repository =
          MockPlanetDiscussionRepository(currentUserId: 'u1');
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetDiscussionRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetDiscussionsScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(
        find.byKey(const ValueKey<String>('create-discussion-button')),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey<String>('discussion-topic-field')),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey<String>('discussion-topic-field')),
        'Мои любимые питомцы',
      );
      expect(find.text('Мои любимые питомцы'), findsOneWidget);
    });

    testWidgets('экран темы показывает ленту и поле ввода', (
      WidgetTester tester,
    ) async {
      final MockPlanetDiscussionRepository repository =
          MockPlanetDiscussionRepository(currentUserId: 'u1');
      addTearDown(repository.dispose);

      final Planet planet = const MockPlanetRepository().byId('p_animals')!;
      final List<PlanetDiscussion> discussions = await repository
          .watchDiscussions(planet)
          .first;
      final PlanetDiscussion demo = discussions.firstWhere(
        (PlanetDiscussion item) => item.id.contains('_discussion_demo_1'),
      );

      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetDiscussionRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: PlanetDiscussionScreen(
              planetId: planet.id,
              discussionId: demo.id,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('discussion-message-field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discussion-add-photo-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discussion-send-button')),
        findsOneWidget,
      );
      expect(find.textContaining('Очень понравилось'), findsOneWidget);
    });
  });
}
