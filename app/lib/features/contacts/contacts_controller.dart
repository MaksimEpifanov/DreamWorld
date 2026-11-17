import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/app_providers.dart';

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

  /// Добавляет участника в контакты взаимно (себе и ему).
  Future<void> add(String profileId) {
    if (profileId.isEmpty) return Future<void>.value();
    return _ref.read(profileRepositoryProvider).addContactMutual(profileId);
  }

  /// Убирает участника из контактов взаимно (у себя и у него).
  Future<void> remove(String profileId) =>
      _ref.read(profileRepositoryProvider).removeContactMutual(profileId);
}
