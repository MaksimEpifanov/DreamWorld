import '../models/map_spot.dart';
import '../models/planet.dart';

/// Репозиторий отметок на карте планеты.
///
/// Отметки общие для всех участников планеты: их видят на сайте и в приложении.
/// В рабочей версии они хранятся в Firestore, в мок-режиме — в памяти.
abstract class MapRepository {
  /// Живой список отметок на карте указанной планеты.
  Stream<List<MapSpot>> watchSpots(Planet planet);

  /// Добавляет новую отметку на карту планеты.
  Future<void> addSpot(Planet planet, MapSpot spot);

  /// Добавляет комментарий к отметке.
  Future<void> addComment(Planet planet, String spotId, MapComment comment);

  /// Ставит ([liked] = `true`) или убирает лайк отметки.
  Future<void> setLike(Planet planet, String spotId, {required bool liked});

  /// Удаляет все отметки автора [authorId] на карте планеты.
  ///
  /// Возвращает число удалённых отметок. В рабочей версии вызывается, когда на
  /// автора накопилось больше 3 жалоб, и убирает его заметки у всех.
  Future<int> deleteSpotsByAuthor(Planet planet, String authorId);

  /// Освобождает ресурсы (закрывает потоки в мок-режиме).
  void dispose();
}
