import 'dart:async';

import '../models/review.dart';
import 'review_repository.dart';

/// Мок-репозиторий отзывов: память без сети (демо-режим без Firebase).
///
/// В рабочей версии отзывы хранятся в Firestore и показываются только
/// настоящие; здесь же список живёт в памяти и сбрасывается при перезапуске.
class MockReviewRepository implements ReviewRepository {
  MockReviewRepository({this.currentUserId = ''}) {
    _reviews.addAll(_demoReviews);
  }

  final String currentUserId;

  final List<Review> _reviews = <Review>[];
  final StreamController<List<Review>> _controller =
      StreamController<List<Review>>.broadcast();

  @override
  Stream<List<Review>> watchReviews() async* {
    yield _snapshot();
    yield* _controller.stream;
  }

  @override
  Future<void> addReview(Review review) async {
    _reviews.insert(0, review);
    if (!_controller.isClosed) _controller.add(_snapshot());
  }

  @override
  void dispose() {
    _controller.close();
  }

  List<Review> _snapshot() => List<Review>.unmodifiable(_reviews);
}

/// Демонстрационные отзывы для мок-режима (в рабочей версии их нет).
const List<Review> _demoReviews = <Review>[
  Review(
    id: 'demo_review_1',
    authorId: '',
    authorName: 'Аня',
    rating: 5,
    text: 'Наконец-то место, где можно найти людей по интересам, а не просто '
        'листать анкеты. Планеты — отличная идея!',
    createdAt: '2026-11-10T18:20:00.000Z',
  ),
  Review(
    id: 'demo_review_2',
    authorId: '',
    authorName: 'Марк',
    rating: 4,
    text: 'Пользуюсь и на телефоне, и на сайте. Удобно, что всё синхронно. '
        'Жду больше планет и событий.',
    createdAt: '2026-11-08T09:05:00.000Z',
  ),
];
