import 'dart:ui' show Color;

/// Визуальная сцена (тема оформления) планеты-сообщества.
///
/// Определяет, какими элементами оформлен «внутренний мир» планеты:
/// водой, достопримечательностями, нотами, пикселями и т.д.
enum PlanetScene {
  fishing,
  travel,
  cinema,
  books,
  music,
  sports,
  reading,
  art,
  technology,
  food,
  nature,
  gaming,
  cars,
  animals,
  gardening,
  esoteric,
  finance,
  volunteering,
  psychology,
  other,
  selfDevelopment,
  collecting,
  space,
}

/// Планета-сообщество по интересам.
///
/// Маленькое «сообщество» людей с общим увлечением со своим визуальным
/// оформлением и подборкой участников.
class Planet {
  const Planet({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.emoji,
    required this.scene,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.memberCount,
    required this.keywords,
  });

  final String id;
  final String name;

  /// Короткий слоган под названием.
  final String tagline;

  /// Подробное описание планеты.
  final String description;

  final String emoji;
  final PlanetScene scene;

  final Color primary;
  final Color secondary;
  final Color accent;

  final int memberCount;

  /// Ключевые интересы планеты (по ним подбираются участники).
  final List<String> keywords;

  /// Короткое название для подписей: без слова «Планета» и с большой буквы.
  String get shortName {
    final String base = name.startsWith(_planetPrefix)
        ? name.substring(_planetPrefix.length)
        : name;
    final int index = base.indexOf(_firstLetter);
    if (index < 0) return base;
    return base.replaceRange(index, index + 1, base[index].toUpperCase());
  }

  /// Полное название с большой буквы: «Планета рыбалки» → «Планета Рыбалки».
  String get displayName =>
      name.startsWith(_planetPrefix) ? '$_planetPrefix$shortName' : name;

  static const String _planetPrefix = 'Планета ';
  static final RegExp _firstLetter = RegExp(r'[A-Za-zА-Яа-яЁё]');

  /// Копия планеты с изменёнными полями.
  Planet copyWith({int? memberCount}) => Planet(
    id: id,
    name: name,
    tagline: tagline,
    description: description,
    emoji: emoji,
    scene: scene,
    primary: primary,
    secondary: secondary,
    accent: accent,
    memberCount: memberCount ?? this.memberCount,
    keywords: keywords,
  );

  @override
  bool operator ==(Object other) => other is Planet && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
