import '../models/review.dart';

/// Репозиторий отзывов о сайте и приложении.
///
/// Отзывы общие для всех: написанный одним пользователем отзыв видят остальные.
/// В рабочей версии они хранятся в Firestore, в мок-режиме — в памяти.
abstract class ReviewRepository {
  /// Живой список отзывов (сначала новые).
  Stream<List<Review>> watchReviews();

  /// Добавляет новый отзыв.
  Future<void> addReview(Review review);

  /// Освобождает ресурсы (закрывает потоки в мок-режиме).
  void dispose();
}
