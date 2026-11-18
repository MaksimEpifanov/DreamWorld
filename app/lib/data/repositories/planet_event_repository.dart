import '../models/planet.dart';
import '../models/planet_event.dart';

/// Репозиторий событий планеты.
///
/// События общие для всех: созданное одним участником событие видят остальные
/// на сайте и в приложении. В рабочей версии они хранятся в Firestore, в
/// мок-режиме — в памяти.
abstract class PlanetEventRepository {
  /// Живой список событий указанной планеты (сначала новые).
  Stream<List<PlanetEvent>> watchEvents(Planet planet);

  /// Создаёт новое событие.
  Future<void> addEvent(Planet planet, PlanetEvent event);

  /// Подаёт заявку текущего пользователя на участие.
  Future<void> apply(Planet planet, String eventId);

  /// Отменяет собственную заявку (до подтверждения организатором).
  Future<void> withdraw(Planet planet, String eventId);

  /// Подтверждает заявку [userId] (доступно организатору).
  Future<void> approve(Planet planet, String eventId, String userId);

  /// Отклоняет заявку или убирает участника [userId] (доступно организатору).
  Future<void> decline(Planet planet, String eventId, String userId);

  /// Удаляет событие (доступно организатору).
  Future<void> removeEvent(Planet planet, String eventId);

  /// Освобождает ресурсы (закрывает потоки в мок-режиме).
  void dispose();
}
