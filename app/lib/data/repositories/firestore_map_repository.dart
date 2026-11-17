import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/map_spot.dart';
import '../models/planet.dart';
import 'map_repository.dart';

/// Отметки на карте планет в Firestore.
///
/// Путь: `planets/{planetId}/spots/{spotId}`. Отметки общие для всех участников
/// планеты, поэтому добавленное одним пользователем сразу видят остальные.
/// Комментарии хранятся в самом документе отметки (массив), лайки — списком
/// идентификаторов `likedBy`, а число лайков считается при чтении, чтобы
/// счётчик не расходился между устройствами.
class FirestoreMapRepository implements MapRepository {
  FirestoreMapRepository({this.firestore, required this.currentUserId});

  static const String planetsCollection = 'planets';
  static const String spotsCollection = 'spots';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  bool get _online => currentUserId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _spots(String planetId) => _db
      .collection(planetsCollection)
      .doc(planetId)
      .collection(spotsCollection);

  void _logError(Object error) {
    debugPrint('Карта Firestore недоступна: $error');
  }

  MapSpot? _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) return null;
    try {
      return MapSpot.fromJson(<String, dynamic>{...data, 'id': snapshot.id});
    } catch (error) {
      _logError(error);
      return null;
    }
  }

  List<MapSpot> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final List<MapSpot> spots = <MapSpot>[];
    for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final MapSpot? spot = _fromSnapshot(doc);
      if (spot != null) spots.add(spot);
    }
    return List<MapSpot>.unmodifiable(spots);
  }

  @override
  Stream<List<MapSpot>> watchSpots(Planet planet) {
    if (!_online) return Stream<List<MapSpot>>.value(const <MapSpot>[]);
    return _spots(planet.id)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_parse)
        .handleError((Object error) {
          _logError(error);
        });
  }

  @override
  Future<void> addSpot(Planet planet, MapSpot spot) async {
    if (!_online) return;
    try {
      await _spots(planet.id).doc(spot.id).set(<String, dynamic>{
        ...spot.toJson(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> addComment(
    Planet planet,
    String spotId,
    MapComment comment,
  ) async {
    if (!_online) return;
    try {
      await _spots(planet.id).doc(spotId).update(<String, dynamic>{
        'comments': FieldValue.arrayUnion(<Map<String, dynamic>>[
          comment.toJson(),
        ]),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> setLike(
    Planet planet,
    String spotId, {
    required bool liked,
  }) async {
    if (!_online) return;
    try {
      await _spots(planet.id).doc(spotId).update(<String, dynamic>{
        'likedBy': liked
            ? FieldValue.arrayUnion(<String>[currentUserId])
            : FieldValue.arrayRemove(<String>[currentUserId]),
      });
    } catch (error) {
      _logError(error);
    }
  }

  @override
  void dispose() {}
}
