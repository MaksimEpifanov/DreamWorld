import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/review.dart';
import 'package:dreem_world/data/providers/review_providers.dart';
import 'package:dreem_world/data/repositories/mock_review_repository.dart';
import 'package:dreem_world/data/repositories/review_repository.dart';
import 'package:dreem_world/features/reviews/reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Отзывы', () {
    test('мок-репозиторий отдаёт список и принимает новый отзыв', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final ReviewRepository repository = container.read(
        reviewRepositoryProvider,
      );

      final List<Review> initial = await repository.watchReviews().first;
      expect(initial, isNotEmpty);

      await repository.addReview(
        Review(
          id: 'r1',
          authorId: 'u1',
          authorName: 'Иван',
          text: 'Мне нравится',
          rating: 5,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      final List<Review> after = await repository.watchReviews().first;
      expect(after.first.id, 'r1');
      expect(after.length, initial.length + 1);
    });

    testWidgets('экран отзывов показывает форму и список', (
      WidgetTester tester,
    ) async {
      final MockReviewRepository repository = MockReviewRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            reviewRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const ReviewsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Опубликовать отзыв'), findsOneWidget);
      expect(find.text('Отзывы участников'), findsOneWidget);
      expect(find.textContaining('Наконец-то место'), findsOneWidget);
    });
  });
}
