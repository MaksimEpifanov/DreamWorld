import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../models/profile.dart';
import '../models/relationship_status.dart';
import '../repositories/chat_repository.dart';
import '../repositories/firestore_profile_repository.dart';
import '../repositories/match_repository.dart';
import '../repositories/mock_chat_repository.dart';
import '../repositories/mock_match_repository.dart';
import '../repositories/mock_profile_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/relationship_status_repository.dart';
import '../services/ai_service.dart';
import '../services/firebase_bootstrap.dart';
import '../services/mock_ai_service.dart';
import '../services/mock_realtime_service.dart';
import '../services/mock_translation_service.dart';
import '../services/realtime_service.dart';
import '../services/translation_service.dart';
import '../services/user_code.dart';
import 'auth_providers.dart';

/// Идентификатор текущего пользователя: Firebase UID или мок-идентификатор.
final Provider<String> currentUserIdProvider = Provider<String>((Ref ref) {
  final String? uid = ref.watch(currentUserFromAuthProvider)?.id;
  return uid ?? MockProfileRepository.defaultCurrentUserId;
});

/// Шина реалтайм-событий.
///
/// TODO(A7): заменить на `SupabaseRealtimeService` при подключении бэкенда.
final Provider<RealtimeService> realtimeServiceProvider =
    Provider<RealtimeService>((Ref ref) {
      final MockRealtimeService service = MockRealtimeService();
      ref.onDispose(service.dispose);
      return service;
    });

/// ИИ-сервис (совместимость, темы, перевод).
///
/// TODO(A7): заменить на реальный провайдер без правок UI.
final Provider<AiService> aiServiceProvider = Provider<AiService>(
  (Ref ref) => const MockAiService(),
);

/// Сервис автоперевода.
final Provider<TranslationService> translationServiceProvider =
    Provider<TranslationService>((Ref ref) => const MockTranslationService());

/// Репозиторий профилей.
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((Ref ref) {
      final String currentUserId = ref.watch(currentUserIdProvider);
      final RealtimeService realtime = ref.watch(realtimeServiceProvider);
      if (isFirebaseInitialized) {
        final FirestoreProfileRepository repository =
            FirestoreProfileRepository(
              currentUserId: currentUserId,
              realtime: realtime,
            );
        ref.onDispose(repository.dispose);
        return repository;
      }
      final MockProfileRepository repository = MockProfileRepository(
        currentUserId: currentUserId,
        realtime: realtime,
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

/// Репозиторий мэтчей.
final Provider<MatchRepository> matchRepositoryProvider =
    Provider<MatchRepository>((Ref ref) {
      final MockMatchRepository repository = MockMatchRepository(
        profileRepository: ref.watch(profileRepositoryProvider),
        aiService: ref.watch(aiServiceProvider),
        currentUserId: ref.watch(currentUserIdProvider),
        realtime: ref.watch(realtimeServiceProvider),
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

/// Репозиторий чатов.
final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>((Ref ref) {
      final MockChatRepository repository = MockChatRepository(
        currentUserId: ref.watch(currentUserIdProvider),
        realtime: ref.watch(realtimeServiceProvider),
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

/// Поток текущего профиля.
final StreamProvider<Profile?> currentProfileProvider =
    StreamProvider<Profile?>(
      (Ref ref) => ref.watch(profileRepositoryProvider).watchCurrentProfile(),
    );

/// Есть ли сохранённый профиль текущего пользователя (для редиректа после
/// восстановления сессии). Никогда не бросает — вернёт `false` при сбое.
final FutureProvider<bool> hasSavedProfileProvider = FutureProvider<bool>((
  Ref ref,
) async {
  try {
    return await ref
        .watch(profileRepositoryProvider)
        .hasSavedProfileAsync()
        .timeout(const Duration(seconds: 8), onTimeout: () => false);
  } catch (_) {
    return false;
  }
});

/// Поток каталога профилей для подбора.
final StreamProvider<List<Profile>> discoveryProfilesProvider =
    StreamProvider<List<Profile>>(
      (Ref ref) =>
          ref.watch(profileRepositoryProvider).watchDiscoveryProfiles(),
    );

/// Поиск анкет по публичному ID пользователя (`DW-XXXX-XXXX`).
///
/// Неполный или неизвестный код возвращает пустой список.
final FutureProviderFamily<List<Profile>, String> profileSearchProvider =
    FutureProvider.family<List<Profile>, String>((Ref ref, String query) async {
      final String normalized = UserCode.normalize(query);
      if (normalized.length != UserCode.length) return const <Profile>[];
      try {
        return await ref
            .watch(profileRepositoryProvider)
            .findByUserCode(normalized);
      } catch (_) {
        return const <Profile>[];
      }
    });

/// Поток мэтчей.
final StreamProvider<List<Match>> matchesProvider = StreamProvider<List<Match>>(
  (Ref ref) => ref.watch(matchRepositoryProvider).watchMatches(),
);

/// Поток диалогов.
final StreamProvider<List<Conversation>> conversationsProvider =
    StreamProvider<List<Conversation>>(
      (Ref ref) => ref.watch(chatRepositoryProvider).watchConversations(),
    );

/// Поток сообщений диалога.
final StreamProviderFamily<List<Message>, String> messagesProvider =
    StreamProvider.family<List<Message>, String>(
      (Ref ref, String conversationId) =>
          ref.watch(chatRepositoryProvider).watchMessages(conversationId),
    );

/// Процент совместимости текущего пользователя с [other].
final FutureProviderFamily<int, Profile> compatibilityProvider =
    FutureProvider.family<int, Profile>((Ref ref, Profile other) async {
      final Profile? me = await ref
          .watch(profileRepositoryProvider)
          .getCurrentProfile();
      if (me == null) return 0;
      return ref.watch(aiServiceProvider).computeCompatibility(me, other);
    });

/// Репозиторий статуса отношений участников.
final Provider<RelationshipStatusRepository>
relationshipStatusRepositoryProvider = Provider<RelationshipStatusRepository>(
  (Ref ref) => const MockRelationshipStatusRepository(),
);

/// Статус отношений участника по его идентификатору.
final ProviderFamily<RelationshipStatus, String> relationshipStatusProvider =
    Provider.family<RelationshipStatus, String>(
      (Ref ref, String profileId) =>
          ref.watch(relationshipStatusRepositoryProvider).statusFor(profileId),
    );
