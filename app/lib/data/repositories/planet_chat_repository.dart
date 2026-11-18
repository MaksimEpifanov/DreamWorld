import '../models/planet.dart';
import '../models/planet_chat_message.dart';

/// Общий чат сообщества планеты.
///
/// Один чат на планету: все вошедшие видят сообщения друг друга в реальном
/// времени и могут писать сами. В рабочей версии сообщения хранятся в Firestore
/// (`planets/{planetId}/chat`), в мок-режиме — в памяти.
abstract interface class PlanetChatRepository {
  /// Живой поток сообщений чата планеты (от старых к новым).
  Stream<List<PlanetChatMessage>> watchMessages(Planet planet);

  /// Отправляет сообщение от текущего пользователя.
  Future<void> sendMessage(Planet planet, String text, {String senderName = ''});

  /// Освобождает ресурсы (закрывает потоки в мок-режиме).
  void dispose();
}
