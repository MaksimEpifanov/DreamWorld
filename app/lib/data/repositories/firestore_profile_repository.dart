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
/// Firebase UID. Демо-профили для подбора остаются локальными, чтобы подбор
/// работал сразу после регистрации.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    required this.firestore,
    required this.currentUserId,
    RealtimeService? realtime,
  }) : _local = MockProfileRepository(
         currentUserId: currentUserId,
         realtime: realtime,
       );

  static const String collectionName = 'profiles';

  final FirebaseFirestore firestore;
  final MockProfileRepository _local;
  final String currentUserId;

  DocumentReference<Map<String, dynamic>> get _document =>
      firestore.collection(collectionName).doc(currentUserId);

  List<Profile> get _demoProfiles => MockProfileRepository.seedProfiles
      .where(
        (Profile profile) =>
            profile.id != currentUserId &&
            profile.id != MockProfileRepository.defaultCurrentUserId,
      )
      .toList(growable: false);

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
    yield await getCurrentProfile();
    yield* _document.snapshots().map(_fromSnapshot).handleError(_logError);
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    if (id == currentUserId ||
        id == MockProfileRepository.defaultCurrentUserId) {
      return getCurrentProfile();
    }
    return _local.getProfileById(id);
  }

  @override
  Future<List<Profile>> getDiscoveryProfiles({
    int limit = 20,
    String? excludeUserId,
  }) async {
    final String exclude = excludeUserId ?? currentUserId;
    return _demoProfiles
        .where((Profile profile) => profile.id != exclude)
        .take(limit)
        .toList(growable: false);
  }

  @override
  Stream<List<Profile>> watchDiscoveryProfiles({int limit = 20}) {
    return Stream<List<Profile>>.value(
      _demoProfiles.take(limit).toList(growable: false),
    );
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    final Profile stored = profile.copyWith(id: currentUserId);
    await _local.saveProfile(stored);
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

    final Profile? ownProfile = await _local.getCurrentProfile();
    for (final Profile profile in <Profile>[..._demoProfiles, ?ownProfile]) {
      if (UserCode.matches(profile.id, normalizedCode)) {
        found[profile.id] = profile;
      }
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
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
