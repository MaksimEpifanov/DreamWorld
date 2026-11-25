import '../models/discussion_message.dart';
import '../models/planet.dart';
import '../models/planet_discussion.dart';

/// Репозиторий обсуждений планеты.
///
/// Обсуждения и сообщения общие для всех участников: созданное одним видно
/// остальным на сайте и в приложении. В рабочей версии данные хранятся в
/// Firestore, в мок-режиме — в памяти.
abstract class PlanetDiscussionRepository {
  /// Живой список обсуждений планеты (сначала активные).
  Stream<List<PlanetDiscussion>> watchDiscussions(Planet planet);

  /// Живая лента сообщений обсуждения (сначала старые, как в чате).
  Stream<List<DiscussionMessage>> watchMessages(
    String planetId,
    String discussionId,
  );

  /// Создаёт обсуждение.
  Future<void> addDiscussion(Planet planet, PlanetDiscussion discussion);

  /// Добавляет сообщение и обновляет счётчик обсуждения.
  Future<void> addMessage(
    Planet planet,
    String discussionId,
    DiscussionMessage message,
  );

  /// Ставит/снимает лайк текущего пользователя.
  Future<void> toggleLike(
    Planet planet,
    String discussionId,
    String messageId,
    bool liked,
  );

  /// Удаляет обсуждение (доступно его автору).
  Future<void> removeDiscussion(Planet planet, String discussionId);

  /// Удаляет сообщение (доступно автору сообщения или автору обсуждения).
  Future<void> removeMessage(
    Planet planet,
    String discussionId,
    String messageId,
  );

  /// Освобождает ресурсы (закрывает потоки в мок-режиме).
  void dispose();
}
