import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review.dart';
import '../repositories/firestore_review_repository.dart';
import '../repositories/mock_review_repository.dart';
import '../repositories/review_repository.dart';
import '../services/firebase_bootstrap.dart';
import 'app_providers.dart';

/// Репозиторий отзывов о сайте и приложении.
///
/// В рабочей версии отзывы хранятся в Firestore и общие для всех, в мок-режиме
/// — в памяти.
final Provider<ReviewRepository> reviewRepositoryProvider =
    Provider<ReviewRepository>((Ref ref) {
      final String currentUserId = ref.watch(currentUserIdProvider);
      if (isFirebaseInitialized) {
        final FirestoreReviewRepository repository = FirestoreReviewRepository(
          currentUserId: currentUserId,
        );
        ref.onDispose(repository.dispose);
        return repository;
      }
      final MockReviewRepository repository = MockReviewRepository(
        currentUserId: currentUserId,
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

/// Живой список отзывов (сначала новые).
final StreamProvider<List<Review>> reviewsProvider =
    StreamProvider<List<Review>>(
      (Ref ref) => ref.watch(reviewRepositoryProvider).watchReviews(),
    );
