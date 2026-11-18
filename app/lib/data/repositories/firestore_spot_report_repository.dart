import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'spot_report_repository.dart';

/// Счётчик жалоб на авторов заметок карты в Firestore.
///
/// Документ: `spotReportCounters/{authorId}` с полями `count` (число жалоб) и
/// `reporters` (идентификаторы пожаловавшихся). Один пользователь добавляется в
/// список только один раз. Правила Firestore разрешают только такой инкремент,
/// поэтому счётчик нельзя накрутить в одиночку.
class FirestoreSpotReportRepository implements SpotReportRepository {
  FirestoreSpotReportRepository({
    this.firestore,
    required this.currentUserId,
  });

  static const String countersCollection = 'spotReportCounters';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  bool get _online => currentUserId.isNotEmpty;

  void _logError(Object error) {
    debugPrint('Счётчик жалоб Firestore недоступен: $error');
  }

  @override
  Future<int> registerReport({
    required String authorId,
    required String authorName,
  }) async {
    if (!_online || authorId.isEmpty) return 0;
    final DocumentReference<Map<String, dynamic>> reference = _db
        .collection(countersCollection)
        .doc(authorId);
    try {
      return await _db.runTransaction<int>((
        Transaction transaction,
      ) async {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(reference);
        if (!snapshot.exists) {
          transaction.set(reference, <String, dynamic>{
            'count': 1,
            'reporters': <String>[currentUserId],
          });
          return 1;
        }
        final Map<String, dynamic> data =
            snapshot.data() ?? <String, dynamic>{};
        final List<String> reporters = <String>[
          for (final Object? item in (data['reporters'] as List<dynamic>? ??
              const <dynamic>[]))
            '$item',
        ];
        if (reporters.contains(currentUserId)) {
          return reporters.length;
        }
        reporters.add(currentUserId);
        transaction.update(reference, <String, dynamic>{
          'count': reporters.length,
          'reporters': reporters,
        });
        return reporters.length;
      });
    } catch (error) {
      _logError(error);
      return 0;
    }
  }
}
