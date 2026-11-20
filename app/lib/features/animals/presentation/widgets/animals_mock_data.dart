import 'package:flutter/material.dart';

class AnimalsDirection {
  const AnimalsDirection({
    required this.title,
    required this.members,
    required this.image,
  });

  final String title;
  final String members;
  final String image;
}

class AnimalsPopularType {
  const AnimalsPopularType({
    required this.title,
    required this.members,
    required this.image,
  });

  final String title;
  final String members;
  final String image;
}

class AnimalsEvent {
  const AnimalsEvent({
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.online,
  });

  final String day;
  final String month;
  final String title;
  final String time;
  final bool online;
}

class AnimalsPerson {
  const AnimalsPerson({required this.name, required this.image});

  final String name;
  final String image;
}

class AnimalsNavItem {
  const AnimalsNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class AnimalsMockData {
  const AnimalsMockData._();

  static const Color accent = Color(0xFF9BE15D);
  static const Color cyan = Color(0xFFFFB74D);
  static const Color panel = Color(0xA6111A33);
  static const Color border = Color(0x3D9BE15D);

  static const String planetTitle = 'Животные';
  static const String planetSubtitle = 'Питомцы, спасение и забота';
  static const String members = '3 412';
  static const String online = '211';

  static const String featuredTitle = 'Лев и его прайд: жизнь больших кошек';
  static const String featuredSubtitle =
      'Как хищники живут и охотятся в дикой природе';
  static const String featuredAuthor = 'Зоолог_Аня';
  static const String featuredLikes = '186';
  static const String featuredComments = '31';

  static const String bottomTitle = 'Делитесь историями о животных';
  static const String bottomSubtitle =
      'Находите друзей, советы и новые места для наблюдений';

  static const List<String> tabs = <String>[
    'Главная',
    'Виды животных',
    'Новости',
    'Люди',
    'События',
    'Карта',
    'Чат',
  ];

  static const List<AnimalsNavItem> navigation = <AnimalsNavItem>[
    AnimalsNavItem(label: 'Главная', icon: Icons.home_outlined, route: '/main'),
    AnimalsNavItem(
      label: 'Животные',
      icon: Icons.pets_outlined,
      route: '/main/planet/p_animals',
    ),
    AnimalsNavItem(
      label: 'Виды животных',
      icon: Icons.explore_outlined,
      route: '/main/planet/p_animals/types',
    ),
    AnimalsNavItem(
      label: 'Новости',
      icon: Icons.article_outlined,
      route: '/main/planet/p_animals/news',
    ),
    AnimalsNavItem(
      label: 'Люди',
      icon: Icons.people_outline,
      route: '/main/planet/p_animals/people',
    ),
    AnimalsNavItem(
      label: 'События',
      icon: Icons.event_outlined,
      route: '/main/planet/p_animals/events',
    ),
    AnimalsNavItem(
      label: 'Карта',
      icon: Icons.map_outlined,
      route: '/main/planet/p_animals/map',
    ),
    AnimalsNavItem(
      label: 'Чат',
      icon: Icons.chat_bubble_outline_rounded,
      route: '/main/planet/p_animals/chat',
    ),
  ];

  static const String settingsRoute = '/settings';

  static const List<AnimalsDirection> directions = <AnimalsDirection>[
    AnimalsDirection(
      title: 'Собаки',
      members: '2 640 уч.',
      image: 'photo-1552053831-71594a27632d',
    ),
    AnimalsDirection(
      title: 'Кошки',
      members: '2 310 уч.',
      image: 'photo-1514888286974-6c03e2ca1dba',
    ),
    AnimalsDirection(
      title: 'Птицы',
      members: '1 874 уч.',
      image: 'photo-1444464666168-49d633b86797',
    ),
    AnimalsDirection(
      title: 'Дикие животные',
      members: '1 542 уч.',
      image: 'photo-1546182990-dffeafbe841d',
    ),
    AnimalsDirection(
      title: 'Грызуны',
      members: '1 205 уч.',
      image: 'photo-1585110396000-c9ffd4e4b308',
    ),
    AnimalsDirection(
      title: 'Рептилии',
      members: '987 уч.',
      image: 'photo-1531386151447-fd76ad50012f',
    ),
  ];

  static const List<AnimalsPopularType> popularTypes = <AnimalsPopularType>[
    AnimalsPopularType(
      title: 'Корм и лакомства',
      members: '2 410',
      image: 'photo-1589924691995-400dc9ecc119',
    ),
    AnimalsPopularType(
      title: 'Игрушки',
      members: '1 980',
      image: 'photo-1548199973-03cce0bbc87b',
    ),
    AnimalsPopularType(
      title: 'Уход и гигиена',
      members: '1 764',
      image: 'photo-1517849845537-4d257902454a',
    ),
    AnimalsPopularType(
      title: 'Клетки и аксессуары',
      members: '1 205',
      image: 'photo-1552728089-57bdde30beb3',
    ),
    AnimalsPopularType(
      title: 'Фото питомцев',
      members: '1 542',
      image: 'photo-1518791841217-8f162f1e1131',
    ),
  ];

  static const List<AnimalsEvent> events = <AnimalsEvent>[
    AnimalsEvent(
      day: '22',
      month: 'НОЯ',
      title: 'День помощи бездомным животным',
      time: '12:00',
      online: true,
    ),
    AnimalsEvent(
      day: '26',
      month: 'НОЯ',
      title: 'Выставка кошек',
      time: '15:00',
      online: false,
    ),
    AnimalsEvent(
      day: '03',
      month: 'ДЕК',
      title: 'Экскурсия в зоопарк',
      time: '10:30',
      online: false,
    ),
  ];

  static const List<AnimalsPerson> people = <AnimalsPerson>[
    AnimalsPerson(
      name: 'Зоолог_Аня',
      image: 'photo-1534528741775-53994a69daeb',
    ),
    AnimalsPerson(
      name: 'Котомания',
      image: 'photo-1517841905240-472988babdf9',
    ),
    AnimalsPerson(
      name: 'Пёс_Дружок',
      image: 'photo-1500648767791-00dcc994a43e',
    ),
    AnimalsPerson(
      name: 'Птицелов',
      image: 'photo-1506794778202-cad84cf45f1d',
    ),
  ];

  static const String heroImage = 'photo-1450778869180-41d0601e046e';
  static const String featuredImage = 'photo-1546182990-dffeafbe841d';
  static const String accentImage = 'photo-1514888286974-6c03e2ca1dba';
  static const String bottomImage = 'photo-1517849845537-4d257902454a';
  static const String profileImage = 'photo-1534528741775-53994a69daeb';

  static String photo(String id, {int width = 800}) =>
      'https://images.unsplash.com/$id?auto=format&fit=crop&w=$width&q=80';
}
