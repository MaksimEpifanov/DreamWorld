import 'dart:ui' show Color;

import '../models/planet.dart';
import 'planet_repository.dart';

/// Мок-репозиторий планет с предзаполненным каталогом сообществ.
class MockPlanetRepository implements PlanetRepository {
  const MockPlanetRepository();

  @override
  List<Planet> getPlanets() => planets;

  @override
  Planet? byId(String id) {
    for (final Planet planet in planets) {
      if (planet.id == id) return planet;
    }
    return null;
  }

  /// Каталог планет-сообществ по интересам.
  static const List<Planet> planets = <Planet>[
    Planet(
      id: 'p_fishing',
      name: 'Планета рыбалки',
      tagline: 'Озёра, реки и большой улов',
      description:
          'Тихие рассветы у воды, старые удочки и рыбацкие истории. '
          'Здесь собираются те, для кого рыбалка — это покой и азарт.',
      emoji: '🎣',
      scene: PlanetScene.fishing,
      primary: Color(0xFF0A6E8A),
      secondary: Color(0xFF12C2C2),
      accent: Color(0xFF6EF3D6),
      memberCount: 1284,
      keywords: <String>['Природа', 'Спорт', 'Путешествия'],
    ),
    Planet(
      id: 'p_travel',
      name: 'Планета путешествий',
      tagline: 'Новые города и далёкие страны',
      description:
          'Архитектура, достопримечательности и дороги, что ведут к мечте. '
          'Сообщество для тех, кто живёт путешествиями.',
      emoji: '✈️',
      scene: PlanetScene.travel,
      primary: Color(0xFFFF7A00),
      secondary: Color(0xFFFFC24B),
      accent: Color(0xFFFF3D8B),
      memberCount: 3421,
      keywords: <String>['Путешествия', 'Природа', 'Фотография'],
    ),
    Planet(
      id: 'p_cinema',
      name: 'Планета кино',
      tagline: 'Фильмы, сериалы и громкие премьеры',
      description:
          'Обсуждайте новые релизы, пересматривайте классику и находите '
          'тех, с кем можно устроить киновечер.',
      emoji: '🎬',
      scene: PlanetScene.cinema,
      primary: Color(0xFF7A1FA2),
      secondary: Color(0xFFFF4D6D),
      accent: Color(0xFFFFD166),
      memberCount: 2987,
      keywords: <String>['Кино', 'Искусство'],
    ),
    Planet(
      id: 'p_music',
      name: 'Планета музыки',
      tagline: 'Концерты, плейлисты и джемы',
      description:
          'От инди до классики. Найдите тех, кто услышит ваш вкус, '
          'сходите на концерт или соберите плейлист вместе.',
      emoji: '🎵',
      scene: PlanetScene.music,
      primary: Color(0xFFFF2E88),
      secondary: Color(0xFFB14DFF),
      accent: Color(0xFF00E5FF),
      memberCount: 1988,
      keywords: <String>['Музыка', 'Искусство'],
    ),
    Planet(
      id: 'p_sports',
      name: 'Планета спорта',
      tagline: 'Тренировки, матчи и рекорды',
      description:
          'Спутники по бегу, залу и командным видам спорта. '
          'Мотивируйте друг друга и держите форму.',
      emoji: '⚽',
      scene: PlanetScene.sports,
      primary: Color(0xFF12B76A),
      secondary: Color(0xFF9BE15D),
      accent: Color(0xFF00E0B8),
      memberCount: 2410,
      keywords: <String>['Спорт', 'Фитнес'],
    ),
    Planet(
      id: 'p_reading',
      name: 'Клуб чтения',
      tagline: 'Читаем вместе и обсуждаем',
      description:
          'Совместные читательские марафоны, закладки, цитаты и споры '
          'о финалах. Для тех, кто не представляет дня без страницы.',
      emoji: '📖',
      scene: PlanetScene.reading,
      primary: Color(0xFF5C6BC0),
      secondary: Color(0xFF9FA8DA),
      accent: Color(0xFFFFD166),
      memberCount: 1120,
      keywords: <String>['Книги', 'Искусство'],
    ),
    Planet(
      id: 'p_art',
      name: 'Планета художников',
      tagline: 'Краски, свет и вдохновение',
      description:
          'Место для художников, фотографов и всех, кто создаёт. '
          'Показывайте работы и находите единомышленников.',
      emoji: '🎨',
      scene: PlanetScene.art,
      primary: Color(0xFFD500F9),
      secondary: Color(0xFF7C4DFF),
      accent: Color(0xFF00E5FF),
      memberCount: 1320,
      keywords: <String>['Искусство', 'Фотография', 'Музыка'],
    ),
    Planet(
      id: 'p_tech',
      name: 'Планета технологий',
      tagline: 'Гаджеты, код и будущее',
      description:
          'Новинки техники, ИИ, разработка и стартапы. Обсуждайте, '
          'что меняет мир, и находите союзников по идеям.',
      emoji: '💻',
      scene: PlanetScene.technology,
      primary: Color(0xFF2979FF),
      secondary: Color(0xFF00E5FF),
      accent: Color(0xFFB388FF),
      memberCount: 3150,
      keywords: <String>['Технологии', 'Игры', 'Книги'],
    ),
    Planet(
      id: 'p_food',
      name: 'Планета кулинаров',
      tagline: 'Рецепты, вкусы и уютные ужины',
      description:
          'Готовьте вместе, делитесь рецептами и находите тех, '
          'для кого еда — это язык любви.',
      emoji: '🍜',
      scene: PlanetScene.food,
      primary: Color(0xFFFF8A3D),
      secondary: Color(0xFFFFD166),
      accent: Color(0xFFFF4D6D),
      memberCount: 1567,
      keywords: <String>['Кулинария', 'Путешествия'],
    ),
    Planet(
      id: 'p_nature',
      name: 'Планета природы',
      tagline: 'Леса, горы и свежий воздух',
      description:
          'Походы, рассветы и маршруты выходного дня. Для тех, '
          'кто заряжается природой и бережёт её.',
      emoji: '🌲',
      scene: PlanetScene.nature,
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF9BE15D),
      accent: Color(0xFF6EF3D6),
      memberCount: 2044,
      keywords: <String>['Природа', 'Путешествия', 'Фотография'],
    ),
    Planet(
      id: 'p_gaming',
      name: 'Планета геймеров',
      tagline: 'Кооп, рейды и вечерние катки',
      description:
          'Соберите команду, обсудите свежий релиз и найдите союзников '
          'для вечерних игровых сессий.',
      emoji: '🎮',
      scene: PlanetScene.gaming,
      primary: Color(0xFF7C4DFF),
      secondary: Color(0xFF00E5FF),
      accent: Color(0xFFFF2EDB),
      memberCount: 2765,
      keywords: <String>['Игры', 'Технологии'],
    ),
    Planet(
      id: 'p_cars',
      name: 'Планета автолюбителей',
      tagline: 'Тачки, тюнинг и дороги',
      description:
          'От классики до электро. Обсуждайте марки, тюнинг, '
          'путешествия на колёсах и автоспорт.',
      emoji: '🚗',
      scene: PlanetScene.cars,
      primary: Color(0xFFD32F2F),
      secondary: Color(0xFFFF7043),
      accent: Color(0xFFFFD54F),
      memberCount: 1690,
      keywords: <String>['Технологии', 'Спорт', 'Путешествия'],
    ),
    Planet(
      id: 'p_animals',
      name: 'Планета животных',
      tagline: 'Питомцы, спасение и забота',
      description:
          'Собаки, кошки и все, кто рядом. Делитесь историями, '
          'советами по уходу и помогайте животным.',
      emoji: '🐾',
      scene: PlanetScene.animals,
      primary: Color(0xFF8D6E63),
      secondary: Color(0xFFFFB74D),
      accent: Color(0xFF9BE15D),
      memberCount: 2233,
      keywords: <String>['Природа', 'Фотография'],
    ),
    Planet(
      id: 'p_gardening',
      name: 'Планета садоводов',
      tagline: 'Растения, урожай и зелёный дом',
      description:
          'От комнатных растений до дачного огорода. Делитесь '
          'секретами ухода и собирайте урожай вместе.',
      emoji: '🌱',
      scene: PlanetScene.gardening,
      primary: Color(0xFF388E3C),
      secondary: Color(0xFFAED581),
      accent: Color(0xFFFFD166),
      memberCount: 876,
      keywords: <String>['Природа', 'Кулинария'],
    ),
    Planet(
      id: 'p_esoteric',
      name: 'Планета эзотерики',
      tagline: 'Астрология, таро и загадки',
      description:
          'Гороскопы, медитации и разговоры о необъяснимом. '
          'Пространство для тех, кто смотрит глубже.',
      emoji: '🔮',
      scene: PlanetScene.esoteric,
      primary: Color(0xFF6A1B9A),
      secondary: Color(0xFF3949AB),
      accent: Color(0xFF00E5FF),
      memberCount: 1412,
      keywords: <String>['Искусство', 'Книги'],
    ),
    Planet(
      id: 'p_finance',
      name: 'Планета финансов',
      tagline: 'Бюджет, инвестиции и цели',
      description:
          'Личные финансы, накопления и инвестиции без воды. '
          'Учитесь вместе и делитесь опытом.',
      emoji: '💰',
      scene: PlanetScene.finance,
      primary: Color(0xFF00A86B),
      secondary: Color(0xFF00E0B8),
      accent: Color(0xFFFFD166),
      memberCount: 1877,
      keywords: <String>['Технологии', 'Книги'],
    ),
    Planet(
      id: 'p_volunteering',
      name: 'Планета добра',
      tagline: 'Волонтёрство и добрые дела',
      description:
          'Помощь людям, приютам и природе. Найдите команду '
          'единомышленников и делайте мир лучше вместе.',
      emoji: '🤝',
      scene: PlanetScene.volunteering,
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFFF7043),
      accent: Color(0xFF9BE15D),
      memberCount: 1044,
      keywords: <String>['Природа', 'Искусство'],
    ),
    Planet(
      id: 'p_psychology',
      name: 'Планета психологии',
      tagline: 'Эмоции, отношения и поддержка',
      description:
          'Бережные разговоры о себе, отношениях и внутреннем мире. '
          'Место, где слушают без осуждения.',
      emoji: '🧠',
      scene: PlanetScene.psychology,
      primary: Color(0xFF5E35B1),
      secondary: Color(0xFF26A69A),
      accent: Color(0xFFB388FF),
      memberCount: 1355,
      keywords: <String>['Книги', 'Искусство'],
    ),
    Planet(
      id: 'p_other',
      name: 'Планета «Микс»',
      tagline: 'Всё, что не попало в другие миры',
      description:
          'Необычные увлечения и темы вне списка. Если вашего хобби '
          'ещё нет — оно может появиться здесь.',
      emoji: '✨',
      scene: PlanetScene.other,
      primary: Color(0xFF546E7A),
      secondary: Color(0xFF00E5FF),
      accent: Color(0xFFB388FF),
      memberCount: 640,
      keywords: <String>['Игры', 'Искусство'],
    ),
    Planet(
      id: 'p_selfdev',
      name: 'Планета саморазвития',
      tagline: 'Привычки, цели и рост',
      description:
          'Продуктивность, книги и маленькие шаги к большим целям. '
          'Растите вместе с теми, кто тоже движется вперёд.',
      emoji: '🚀',
      scene: PlanetScene.selfDevelopment,
      primary: Color(0xFFFF6F00),
      secondary: Color(0xFFFFD166),
      accent: Color(0xFF00E5FF),
      memberCount: 2109,
      keywords: <String>['Книги', 'Спорт', 'Фитнес'],
    ),
    Planet(
      id: 'p_collecting',
      name: 'Планета коллекционеров',
      tagline: 'Редкости, обмен и полки сокровищ',
      description:
          'Марки, винил, фигурки и всё, что собирают с любовью. '
          'Находите редкие экземпляры и таких же увлечённых.',
      emoji: '🧩',
      scene: PlanetScene.collecting,
      primary: Color(0xFF8E24AA),
      secondary: Color(0xFFFF6F00),
      accent: Color(0xFFFFD166),
      memberCount: 733,
      keywords: <String>['Искусство', 'Книги', 'Игры'],
    ),
  ];
}
