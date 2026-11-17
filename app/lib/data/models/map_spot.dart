import 'dart:ui' show Color;

/// Комментарий под отметкой на карте планеты.
class MapComment {
  const MapComment({
    required this.authorName,
    required this.text,
    this.authorId = '',
  });

  final String authorName;
  final String text;

  /// Идентификатор автора (пустой для демонстрационных комментариев).
  final String authorId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'authorName': authorName,
    'text': text,
    'authorId': authorId,
  };

  factory MapComment.fromJson(Map<String, dynamic> json) => MapComment(
    authorName: '${json['authorName'] ?? ''}',
    text: '${json['text'] ?? ''}',
    authorId: '${json['authorId'] ?? ''}',
  );
}

/// Отметка на карте «внутреннего мира» планеты.
///
/// Место, связанное с интересом планеты: точка, фото (эмодзи-заглушка),
/// теги, число лайков и комментарии. [x] и [y] — нормализованные координаты
/// `0..1` относительно области карты.
///
/// Отметки хранятся в Firestore (`planets/{planetId}/spots`), поэтому их видят
/// все участники планеты на сайте и в приложении. Число лайков в облаке
/// считается по списку [likedBy]; в демо-режиме [likes] задаётся напрямую.
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
    this.authorId = '',
    this.likedBy = const <String>[],
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

  /// Идентификатор того, кто оставил отметку (пустой в демо-режиме).
  final String authorId;

  /// Эмодзи-«фото» отметки.
  final String emoji;

  /// Теги интересов отметки.
  final List<String> tags;

  final int likes;

  /// Идентификаторы тех, кто поставил лайк (для общих отметок).
  final List<String> likedBy;

  /// Нормализованные координаты на карте (`0..1`).
  final double x;
  final double y;

  final double? latitude;
  final double? longitude;

  /// Акцентный цвет отметки (в тон планеты, если не задан).
  final Color? color;

  final List<MapComment> comments;

  /// Ставил ли лайк пользователь [userId].
  bool isLikedBy(String userId) => userId.isNotEmpty && likedBy.contains(userId);

  MapSpot copyWith({
    String? title,
    String? description,
    String? authorName,
    String? authorId,
    String? emoji,
    List<String>? tags,
    int? likes,
    List<String>? likedBy,
    double? x,
    double? y,
    double? latitude,
    double? longitude,
    Color? color,
    List<MapComment>? comments,
  }) => MapSpot(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    authorName: authorName ?? this.authorName,
    authorId: authorId ?? this.authorId,
    emoji: emoji ?? this.emoji,
    tags: tags ?? this.tags,
    likes: likes ?? this.likes,
    likedBy: likedBy ?? this.likedBy,
    x: x ?? this.x,
    y: y ?? this.y,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    color: color ?? this.color,
    comments: comments ?? this.comments,
  );

  /// Данные для записи в Firestore.
  ///
  /// Число лайков не сохраняем: в облаке оно считается по [likedBy], чтобы
  /// счётчик не расходился между устройствами. Цвет тоже не сохраняем — он
  /// берётся из оформления планеты.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'authorId': authorId,
    'authorName': authorName,
    'emoji': emoji,
    'tags': tags,
    'likedBy': likedBy,
    'x': x,
    'y': y,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'comments': comments.map((MapComment c) => c.toJson()).toList(),
  };

  factory MapSpot.fromJson(Map<String, dynamic> json) {
    final List<String> likedBy = _stringList(json['likedBy']);
    return MapSpot(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      authorId: '${json['authorId'] ?? ''}',
      authorName: '${json['authorName'] ?? ''}',
      emoji: '${json['emoji'] ?? '📍'}',
      tags: _stringList(json['tags']),
      likes: likedBy.length,
      likedBy: likedBy,
      x: _toDouble(json['x']),
      y: _toDouble(json['y']),
      latitude: _toNullableDouble(json['latitude']),
      longitude: _toNullableDouble(json['longitude']),
      comments: _comments(json['comments']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value.map((Object? item) => '$item').toList(growable: false);
  }

  static List<MapComment> _comments(Object? value) {
    if (value is! List) return const <MapComment>[];
    final List<MapComment> result = <MapComment>[];
    for (final Object? item in value) {
      if (item is Map) {
        result.add(MapComment.fromJson(item.cast<String, dynamic>()));
      }
    }
    return List<MapComment>.unmodifiable(result);
  }

  static double _toDouble(Object? value, [double fallback = 0]) =>
      _toNullableDouble(value) ?? fallback;

  static double? _toNullableDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
