import 'package:dreem_world/data/models/review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review: сериализация', () {
    test('toJson/fromJson сохраняют поля отзыва', () {
      const Review review = Review(
        id: 'r1',
        authorId: 'u1',
        authorName: 'Аня',
        text: 'Отличное приложение',
        rating: 4,
        createdAt: '2026-11-18T10:00:00.000Z',
      );

      final Review restored = Review.fromJson(review.toJson());

      expect(restored.id, 'r1');
      expect(restored.authorId, 'u1');
      expect(restored.authorName, 'Аня');
      expect(restored.text, 'Отличное приложение');
      expect(restored.rating, 4);
      expect(restored.createdAt, '2026-11-18T10:00:00.000Z');
      expect(restored.createdDate, isNotNull);
    });

    test('fromJson терпим к отсутствующим полям и чинит оценку', () {
      final Review missing = Review.fromJson(<String, dynamic>{
        'id': 'x',
        'rating': 99,
      });
      expect(missing.id, 'x');
      expect(missing.rating, 5);
      expect(missing.text, '');

      final Review low = Review.fromJson(<String, dynamic>{'rating': 0});
      expect(low.rating, 1);
    });
  });
}
