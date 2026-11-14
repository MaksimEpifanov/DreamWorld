import 'dart:ui' show Color;

/// Комментарий под отметкой на карте планеты.
class MapComment {
  const MapComment({required this.authorName, required this.text});

  final String authorName;
  final String text;
}

/// Отметка на карте «внутреннего мира» планеты.
///
/// Место, связанное с интересом планеты: точка, фото (эмодзи-заглушка),
/// теги, число лайков и комментарии. [x] и [y] — нормализованные координаты
/// `0..1` относительно области карты.
class MapSpot {
  const MapSpot({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.emoji,
    required this.tags,
    required this.likes,
    required this.x,
    required this.y,
    this.latitude,
    this.longitude,
    this.color,
    this.comments = const <MapComment>[],
  });

  final String id;
  final String title;
  final String description;

  /// Имя того, кто оставил отметку.
  final String authorName;

  /// Эмодзи-«фото» отметки.
  final String emoji;

  /// Теги интересов отметки.
  final List<String> tags;

  final int likes;

  /// Нормализованные координаты на карте (`0..1`).
  final double x;
  final double y;

  final double? latitude;
  final double? longitude;

  /// Акцентный цвет отметки (в тон планеты, если не задан).
  final Color? color;

  final List<MapComment> comments;
}
