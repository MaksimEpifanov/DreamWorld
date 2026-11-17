import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile.dart';
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

/// Входящие запросы в контакты: кто хочет добавить вас.
final Provider<List<String>> incomingContactRequestIdsProvider =
    Provider<List<String>>(
      (Ref ref) =>
          ref
              .watch(currentProfileProvider)
              .valueOrNull
              ?.incomingContactRequestIds ??
          const <String>[],
    );

/// Исходящие запросы в контакты: кому запрос отправили вы.
final Provider<List<String>> outgoingContactRequestIdsProvider =
    Provider<List<String>>(
      (Ref ref) =>
          ref
              .watch(currentProfileProvider)
              .valueOrNull
              ?.outgoingContactRequestIds ??
          const <String>[],
    );

/// Анкеты пользователей, приславших входящий запрос в контакты.
///
/// Имена и аватары берём из живого потока анкет, чтобы список запросов был
/// согласован с контактами и поиском.
final Provider<List<Profile>> incomingContactRequestProfilesProvider =
    Provider<List<Profile>>((Ref ref) {
      final List<String> ids = ref.watch(incomingContactRequestIdsProvider);
      if (ids.isEmpty) return const <Profile>[];
      final List<Profile> live =
          ref.watch(discoveryProfilesProvider).valueOrNull ??
          const <Profile>[];
      final Map<String, Profile> byId = <String, Profile>{
        for (final Profile profile in live) profile.id: profile,
      };
      return <Profile>[
        for (final String id in ids)
          if (byId[id] != null) byId[id]!,
      ];
    });

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

  /// Отправляет запрос в контакты: собеседник получит его и сможет принять
  /// или отклонить.
  Future<void> sendRequest(String profileId) {
    if (profileId.isEmpty) return Future<void>.value();
    return _ref.read(profileRepositoryProvider).sendContactRequest(profileId);
  }

  /// Принимает входящий запрос: контакт становится взаимным.
  Future<void> acceptRequest(String profileId) =>
      _ref.read(profileRepositoryProvider).acceptContactRequest(profileId);

  /// Отклоняет входящий запрос: контакт не создаётся.
  Future<void> declineRequest(String profileId) =>
      _ref.read(profileRepositoryProvider).declineContactRequest(profileId);

  /// Отменяет собственный отправленный запрос.
  Future<void> cancelRequest(String profileId) =>
      _ref.read(profileRepositoryProvider).cancelContactRequest(profileId);
}
