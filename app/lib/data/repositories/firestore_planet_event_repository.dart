import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/planet.dart';
import '../models/planet_event.dart';
import 'planet_event_repository.dart';

/// События планет в Firestore.
///
/// Путь: `planets/{planetId}/events/{eventId}`. События общие для всех: их
/// видят на сайте и в приложении. Заявки на участие хранятся списками
/// идентификаторов `applicantIds` (ожидают решения) и `participantIds`
/// (подтверждены организатором).
class FirestorePlanetEventRepository implements PlanetEventRepository {
  FirestorePlanetEventRepository({
    this.firestore,
    required this.currentUserId,
  });

  static const String planetsCollection = 'planets';
  static const String eventsCollection = 'events';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  bool get _online => currentUserId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _events(String planetId) => _db
      .collection(planetsCollection)
      .doc(planetId)
      .collection(eventsCollection);

  void _logError(Object error) {
    debugPrint('События Firestore недоступны: $error');
  }

  List<PlanetEvent> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final List<PlanetEvent> events = <PlanetEvent>[];
    for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic>? data = doc.data();
      if (data == null) continue;
      try {
        events.add(
          PlanetEvent.fromJson(<String, dynamic>{...data, 'id': doc.id}),
        );
      } catch (error) {
        _logError(error);
      }
    }
    return List<PlanetEvent>.unmodifiable(events);
  }

  @override
  Stream<List<PlanetEvent>> watchEvents(Planet planet) {
    if (!_online) return Stream<List<PlanetEvent>>.value(const <PlanetEvent>[]);
    return _events(planet.id)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_parse)
        .handleError((Object error) {
          _logError(error);
        });
  }

  @override
  Future<void> addEvent(Planet planet, PlanetEvent event) async {
    if (!_online) return;
    try {
      await _events(planet.id).doc(event.id).set(<String, dynamic>{
        ...event.toJson(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> apply(Planet planet, String eventId) async {
    if (!_online) return;
    try {
      await _events(planet.id).doc(eventId).update(<String, dynamic>{
        'applicantIds': FieldValue.arrayUnion(<String>[currentUserId]),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> withdraw(Planet planet, String eventId) async {
    if (!_online) return;
    try {
      await _events(planet.id).doc(eventId).update(<String, dynamic>{
        'applicantIds': FieldValue.arrayRemove(<String>[currentUserId]),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> approve(Planet planet, String eventId, String userId) async {
    if (!_online || userId.isEmpty) return;
    try {
      await _events(planet.id).doc(eventId).update(<String, dynamic>{
        'applicantIds': FieldValue.arrayRemove(<String>[userId]),
        'participantIds': FieldValue.arrayUnion(<String>[userId]),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> decline(Planet planet, String eventId, String userId) async {
    if (!_online || userId.isEmpty) return;
    try {
      await _events(planet.id).doc(eventId).update(<String, dynamic>{
        'applicantIds': FieldValue.arrayRemove(<String>[userId]),
        'participantIds': FieldValue.arrayRemove(<String>[userId]),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> removeEvent(Planet planet, String eventId) async {
    if (!_online) return;
    try {
      await _events(planet.id).doc(eventId).delete();
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  void dispose() {}
}
