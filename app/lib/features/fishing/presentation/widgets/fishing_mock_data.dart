import 'package:flutter/material.dart';

class FishingDirection {
  const FishingDirection({
    required this.title,
    required this.members,
    required this.image,
  });

  final String title;
  final String members;
  final String image;
}

class FishingPopularType {
  const FishingPopularType({
    required this.title,
    required this.members,
    required this.image,
  });

  final String title;
  final String members;
  final String image;
}

class FishingEvent {
  const FishingEvent({
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

class FishingPerson {
  const FishingPerson({required this.name, required this.image});

  final String name;
  final String image;
}

class FishingNavItem {
  const FishingNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class FishingMockData {
  const FishingMockData._();

  static const Color accent = Color(0xFF2E8BFF);
  static const Color cyan = Color(0xFF24D4FF);
  static const Color panel = Color(0xA6111A33);
  static const Color border = Color(0x3DBFE4FF);

  static const String planetTitle = 'Рыбалка';
  static const String planetSubtitle = 'Озера, реки и большой улов';
  static const String members = '2 987';
  static const String online = '143';

  static const String featuredTitle = 'Щука на 12 кг: секреты спиннинга';
  static const String featuredSubtitle =
      'Как выважить трофей и не потерять улов';
  static const String featuredAuthor = 'Щукарь_99';
  static const String featuredLikes = '142';
  static const String featuredComments = '23';

  static const String bottomTitle = 'Делитесь уловами с сообществом';
  static const String bottomSubtitle =
      'Находи единомышленников и новые места для рыбалки';

  static const List<String> tabs = <String>[
    'Главная',
    'Виды ловли',
    'Новости',
    'Люди',
    'События',
    'Карта',
    'Чат',
  ];

  static const List<FishingNavItem> navigation = <FishingNavItem>[
    FishingNavItem(label: 'Главная', icon: Icons.home_outlined, route: '/main'),
    FishingNavItem(
      label: 'Рыбалка',
      icon: Icons.phishing_outlined,
      route: '/main/planet/p_fishing',
    ),
    FishingNavItem(
      label: 'Виды ловли',
      icon: Icons.explore_outlined,
      route: '/main/planet/p_fishing/types',
    ),
    FishingNavItem(
      label: 'Новости',
      icon: Icons.article_outlined,
      route: '/main/planet/p_fishing/news',
    ),
    FishingNavItem(
      label: 'Люди',
      icon: Icons.people_outline,
      route: '/main/planet/p_fishing/people',
    ),
    FishingNavItem(
      label: 'События',
      icon: Icons.event_outlined,
      route: '/main/planet/p_fishing/events',
    ),
    FishingNavItem(
      label: 'Карта',
      icon: Icons.map_outlined,
      route: '/main/planet/p_fishing/map',
    ),
    FishingNavItem(
      label: 'Чат',
      icon: Icons.chat_bubble_outline_rounded,
      route: '/main/planet/p_fishing/chat',
    ),
  ];

  static const String settingsRoute = '/settings';

  static const List<FishingDirection> directions = <FishingDirection>[
    // Фото: рыбак со спиннингом на берегу озера.
    FishingDirection(
      title: 'Спиннинг',
      members: '2 310 уч.',
      image: 'photo-1520017475683-552555ddd7f9',
    ),
    // Фото: фидерные удилища на берегу реки.
    FishingDirection(
      title: 'Поплавок',
      members: '1 980 уч.',
      image: 'photo-1518509562904-e7ef99cdcc86',
    ),
    // Фото: поплавок на спокойной воде.
    FishingDirection(
      title: 'Фидер',
      members: '1 764 уч.',
      image: 'photo-1516026672322-bc52d61a55d5',
    ),
    // Фото: зимняя рыбалка на заснеженном озере.
    FishingDirection(
      title: 'Зимняя рыбалка',
      members: '1 205 уч.',
      image: 'photo-1487730116645-74489c95b41b',
    ),
    // Фото: нахлыстовик в реке на рассвете.
    FishingDirection(
      title: 'Нахлыст',
      members: '1 542 уч.',
      image: 'photo-1470770841072-f978cf4d019e',
    ),
    // Фото: морская рыбалка с лодки в открытом море.
    FishingDirection(
      title: 'Морская рыбалка',
      members: '987 уч.',
      image: 'photo-1499750310107-5fef28a66643',
    ),
  ];

  static const List<FishingPopularType> popularTypes = <FishingPopularType>[
    // Фото: спиннинг крупным планом.
    FishingPopularType(
      title: 'Спиннинг',
      members: '2 310',
      image: 'photo-1520017475683-552555ddd7f9',
    ),
    // Фото: фидерное удилище с катушкой.
    FishingPopularType(
      title: 'Фидер',
      members: '1 980',
      image: 'photo-1518509562904-e7ef99cdcc86',
    ),
    // Фото: безынерционная катушка.
    FishingPopularType(
      title: 'Катушка 4000',
      members: '1 764',
      image: 'photo-1518182170546-0766b7b6d2d3',
    ),
    // Фото: плетёная леска на катушке.
    FishingPopularType(
      title: 'Плетёнка',
      members: '1 205',
      image: 'photo-1500534623283-312aade485b7',
    ),
    // Фото: набор воблеров и блёсен.
    FishingPopularType(
      title: 'Приманки',
      members: '1 542',
      image: 'photo-1487730116645-74489c95b41b',
    ),
  ];

  static const List<FishingEvent> events = <FishingEvent>[
    FishingEvent(
      day: '22',
      month: 'НОЯ',
      title: 'Турнир по спиннингу',
      time: '18:00',
      online: true,
    ),
    FishingEvent(
      day: '26',
      month: 'НОЯ',
      title: 'Выезд на карпа',
      time: '06:30',
      online: false,
    ),
    FishingEvent(
      day: '29',
      month: 'НОЯ',
      title: 'Мастер-класс по нахлысту',
      time: '14:00',
      online: true,
    ),
  ];

  static const List<FishingPerson> people = <FishingPerson>[
    // Фото: портрет рыбака.
    FishingPerson(
      name: 'Рыбак_Иван',
      image: 'photo-1500648767791-00dcc994a43e',
    ),
    // Фото: портрет рыбака с уловом.
    FishingPerson(name: 'Щукарь_99', image: 'photo-1534528741775-53994a69daeb'),
    // Фото: портрет мужчины в кепке.
    FishingPerson(
      name: 'ФидерМастер',
      image: 'photo-1506794778202-cad84cf45f1d',
    ),
    // Фото: портрет рыбалки у воды.
    FishingPerson(name: 'Лещ_77', image: 'photo-1517841905240-472988babdf9'),
  ];

  // Фото: широкий водоём (озеро/водохранилище) на рассвете — фон шапки.
  static const String heroImage = 'photo-1501785888041-af3ef285b470';
  // Фото: рыбак, держащий крупную щуку, на фоне воды — «Трофей дня».
  static const String featuredImage = 'photo-1544551763-46a013bb70d5';
  // Фото: блесна/приманка крупным планом с неоновым свечением.
  static const String lureImage = 'photo-1518182170546-0766b7b6d2d3';
  // Фото: ночной водоём с палаткой — фон нижнего баннера.
  static const String bottomImage = 'photo-1500534623283-312aade485b7';
  // Фото: аватар пользователя-рыбака.
  static const String profileImage = 'photo-1507003211169-0a1dd7228f2d';

  static String photo(String id, {int width = 800}) =>
      'https://images.unsplash.com/$id?auto=format&fit=crop&w=$width&q=80';

  static String? localDirectionImage(int index) {
    if (index < 0 || index >= 6) return null;
    return 'assets/planets/genres/p_fishing/${index + 1}.webp';
  }
}
