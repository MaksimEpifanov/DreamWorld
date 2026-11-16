import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../services/realtime_service.dart';
import '../services/user_code.dart';
import 'mock_profile_repository.dart';
import 'profile_repository.dart';

/// Профиль пользователя в Firestore с локальным кэшем.
///
/// Анкета текущего пользователя хранится в коллекции `profiles` под его
/// Firebase UID. В рабочей версии подбор и участники планет показывают только
/// реальные анкеты из Firestore; демо-профили остаются лишь в мок-режиме
/// (когда параметры Firebase не заполнены).
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    this.firestore,
    required this.currentUserId,
    RealtimeService? realtime,
  }) : _local = MockProfileRepository(
         currentUserId: currentUserId,
         realtime: realtime,
       );

  static const String collectionName = 'profiles';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final MockProfileRepository _local;
  final String currentUserId;

  /// Firestore нужен только вошедшему пользователю: до входа работаем на
  /// локальном кэше, чтобы не загружать SDK и не получать отказ правил.
  bool get _online =>
      currentUserId.isNotEmpty &&
      currentUserId != MockProfileRepository.defaultCurrentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _document =>
      _db.collection(collectionName).doc(currentUserId);

  Profile? _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    try {
      return Profile.fromJson(data);
    } catch (error) {
      debugPrint('Профиль Firestore повреждён: $error');
      return null;
    }
  }

  void _logError(Object error) {
    debugPrint('Firestore недоступен, используем локальный профиль: $error');
  }

  @override
  Future<Profile?> getCurrentProfile() async {
    if (!_online) return _local.getCurrentProfile();
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _document
          .get();
      final Profile? profile = _fromSnapshot(snapshot);
      if (profile != null) return profile;
    } catch (error) {
      _logError(error);
    }
    return _local.getCurrentProfile();
  }

  @override
  Stream<Profile?> watchCurrentProfile() async* {
    if (!_online) {
      yield* _local.watchCurrentProfile();
      return;
    }
    yield await getCurrentProfile();
    yield* _document.snapshots().map(_fromSnapshot).handleError(_logError);
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    if (id == currentUserId ||
        id == MockProfileRepository.defaultCurrentUserId) {
      return getCurrentProfile();
    }
    if (_online) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> snapshot = await _db
            .collection(collectionName)
            .doc(id)
            .get();
        final Profile? profile = _fromSnapshot(snapshot);
        if (profile != null) return profile;
      } catch (error) {
        _logError(error);
      }
    }
    return _local.getProfileById(id);
  }

  @override
  Future<List<Profile>> getDiscoveryProfiles({
    int limit = 20,
    String? excludeUserId,
  }) async {
    if (!_online) {
      return _local.getDiscoveryProfiles(
        limit: limit,
        excludeUserId: excludeUserId,
      );
    }
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection(collectionName)
          .limit(limit + 1)
          .get();
      return _realProfiles(
        snapshot,
        excludeUserId: excludeUserId,
        limit: limit,
      );
    } catch (error) {
      _logError(error);
      return const <Profile>[];
    }
  }

  @override
  Stream<List<Profile>> watchDiscoveryProfiles({int limit = 20}) async* {
    if (!_online) {
      yield* _local.watchDiscoveryProfiles(limit: limit);
      return;
    }
    yield await getDiscoveryProfiles(limit: limit);
    yield* _db
        .collection(collectionName)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => _realProfiles(
            snapshot,
            excludeUserId: currentUserId,
            limit: limit,
          ),
        )
        .handleError(_logError);
  }

  /// Реальные анкеты из Firestore: без текущего пользователя и без демо-сида.
  List<Profile> _realProfiles(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    required String? excludeUserId,
    required int limit,
  }) {
    final String exclude = excludeUserId ?? currentUserId;
    final List<Profile> result = <Profile>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      if (document.id == exclude) continue;
      try {
        final Profile profile = Profile.fromJson(document.data());
        if (profile.name.trim().isEmpty) continue;
        result.add(profile);
      } catch (error) {
        debugPrint('Профиль Firestore повреждён: $error');
      }
      if (result.length >= limit) break;
    }
    return List<Profile>.unmodifiable(result);
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    final Profile stored = profile.copyWith(id: currentUserId);
    await _local.saveProfile(stored);
    if (!_online) return;
    try {
      await _document.set(stored.toJson(), SetOptions(merge: true));
    } catch (error) {
      _logError(error);
    }
  }

  @override
  Future<List<Profile>> findByUserCode(String normalizedCode) async {
    if (normalizedCode.isEmpty) return const <Profile>[];
    final Map<String, Profile> found = <String, Profile>{};

    if (!_online) {
      final List<Profile> local = await _local.getDiscoveryProfiles(limit: 500);
      final Profile? ownProfile = await _local.getCurrentProfile();
      for (final Profile profile in <Profile>[...local, ?ownProfile]) {
        if (UserCode.matches(profile.id, normalizedCode)) {
          found[profile.id] = profile;
        }
      }
      return found.values.toList(growable: false);
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection(collectionName)
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> document
          in snapshot.docs) {
        if (!UserCode.matches(document.id, normalizedCode)) continue;
        try {
          found[document.id] = Profile.fromJson(document.data());
        } catch (error) {
          debugPrint('Профиль Firestore повреждён: $error');
        }
      }
    } catch (error) {
      _logError(error);
    }

    return found.values.toList(growable: false);
  }

  @override
  Future<bool> hasSavedProfileAsync() async {
    if (!_online) return _local.hasSavedProfileAsync();
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _document
          .get();
      if (snapshot.exists) return true;
    } catch (error) {
      _logError(error);
    }
    return _local.hasSavedProfileAsync();
  }

  @override
  void dispose() {
    _local.dispose();
  }
}
