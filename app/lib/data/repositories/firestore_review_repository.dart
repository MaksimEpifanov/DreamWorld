import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/review.dart';
import 'review_repository.dart';

/// Отзывы о сайте и приложении в Firestore.
///
/// Коллекция `reviews`: читают все вошедшие, писать может каждый от своего
/// имени. Изменять и удалять чужие отзывы нельзя — это проверяют правила.
class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository({this.firestore, required this.currentUserId});

  static const String collectionName = 'reviews';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  bool get _online => currentUserId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection(collectionName);

  void _logError(Object error) {
    debugPrint('Отзывы Firestore недоступны: $error');
  }

  @override
  Stream<List<Review>> watchReviews() {
    if (!_online) return Stream<List<Review>>.value(const <Review>[]);
    return _reviews
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          final List<Review> reviews = <Review>[];
          for (final DocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            final Map<String, dynamic>? data = doc.data();
            if (data == null) continue;
            reviews.add(
              Review.fromJson(<String, dynamic>{...data, 'id': doc.id}),
            );
          }
          return List<Review>.unmodifiable(reviews);
        })
        .handleError((Object error) => _logError(error));
  }

  @override
  Future<void> addReview(Review review) async {
    if (!_online) return;
    try {
      await _reviews.doc(review.id).set(review.toJson());
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  void dispose() {}
}
