import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile.dart';
import '../../data/providers/app_providers.dart';
import '../../data/repositories/profile_repository.dart';

/// Идентификаторы контактов текущего пользователя.
///
/// Список хранится прямо в анкете (`profiles/{uid}.contactIds`), поэтому
/// контакты не пропадают при перезагрузке страницы и перезапуске приложения.
final Provider<List<String>> contactsProvider = Provider<List<String>>(
  (Ref ref) =>
      ref.watch(currentProfileProvider).valueOrNull?.contactIds ??
      const <String>[],
);

/// Управляет списком контактов в анкете текущего пользователя.
final Provider<ContactsController> contactsControllerProvider =
    Provider<ContactsController>((Ref ref) => ContactsController(ref));

/// Добавляет и удаляет контакты, сохраняя изменения в анкете.
class ContactsController {
  ContactsController(this._ref);

  final Ref _ref;

  /// Добавляет участника в контакты, если его там ещё нет.
  Future<void> add(String profileId) {
    if (profileId.isEmpty) return Future<void>.value();
    return _update(
      (List<String> ids) =>
          ids.contains(profileId) ? ids : <String>[...ids, profileId],
    );
  }

  /// Удаляет участника из контактов.
  Future<void> remove(String profileId) => _update(
    (List<String> ids) =>
        ids.where((String id) => id != profileId).toList(growable: false),
  );

  Future<void> _update(
    List<String> Function(List<String> ids) transform,
  ) async {
    final ProfileRepository repository = _ref.read(profileRepositoryProvider);
    final Profile? profile = await repository.getCurrentProfile();
    if (profile == null) return;
    final List<String> next = transform(profile.contactIds);
    if (listEquals(next, profile.contactIds)) return;
    await repository.saveProfile(profile.copyWith(contactIds: next));
  }
}
