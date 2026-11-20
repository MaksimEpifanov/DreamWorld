import 'package:flutter/material.dart';

import '../../data/models/planet.dart';

class PlanetSceneTheme {
  const PlanetSceneTheme({
    required this.genreAnchorLabel,
    required this.genreSectionTitle,
    required this.checklistTitle,
    required this.featuredTitle,
    required this.coverIcon,
    required this.bannerHeadline,
    required this.bannerSubtitle,
  });

  final String genreAnchorLabel;
  final String genreSectionTitle;
  final String checklistTitle;
  final String featuredTitle;
  final IconData coverIcon;
  final String bannerHeadline;
  final String bannerSubtitle;
}

const PlanetSceneTheme _fallbackTheme = PlanetSceneTheme(
  genreAnchorLabel: 'Жанры',
  genreSectionTitle: 'Разделы',
  checklistTitle: 'Интересы',
  featuredTitle: 'Материал дня',
  coverIcon: Icons.auto_awesome_outlined,
  bannerHeadline: 'Делись впечатлениями, находи свою компанию!',
  bannerSubtitle: 'Рассказывай о том, что любишь, и собирай встречи',
);

const Map<PlanetScene, PlanetSceneTheme> planetSceneThemes =
    <PlanetScene, PlanetSceneTheme>{
      PlanetScene.fishing: PlanetSceneTheme(
        genreAnchorLabel: 'Направления',
        genreSectionTitle: 'Направления',
        checklistTitle: 'Виды ловли и снасти',
        featuredTitle: 'Улов дня',
        coverIcon: Icons.phishing_outlined,
        bannerHeadline: 'Делись уловом, находи компанию на берегу!',
        bannerSubtitle: 'Рассказывай о рыбалке и собирай вылазки',
      ),
      PlanetScene.travel: PlanetSceneTheme(
        genreAnchorLabel: 'Направления',
        genreSectionTitle: 'Направления',
        checklistTitle: 'Куда едем и как',
        featuredTitle: 'Маршрут дня',
        coverIcon: Icons.travel_explore_outlined,
        bannerHeadline: 'Делись маршрутами, находи попутчиков!',
        bannerSubtitle: 'Рассказывай о путешествиях и планируй поездки',
      ),
      PlanetScene.cinema: PlanetSceneTheme(
        genreAnchorLabel: 'Жанры',
        genreSectionTitle: 'Разделы',
        checklistTitle: 'Жанры и форматы',
        featuredTitle: 'Фильм дня',
        coverIcon: Icons.movie_outlined,
        bannerHeadline: 'Делись впечатлениями, находи компанию для кино!',
        bannerSubtitle: 'Рассказывай о фильмах и собирай киновечера',
      ),
      PlanetScene.books: PlanetSceneTheme(
        genreAnchorLabel: 'Жанры',
        genreSectionTitle: 'Жанры',
        checklistTitle: 'Литературные жанры',
        featuredTitle: 'Книга дня',
        coverIcon: Icons.menu_book_outlined,
        bannerHeadline: 'Делись находками, находи компанию по книжкам!',
        bannerSubtitle: 'Рассказывай о прочитанном и собирай книжные встречи',
      ),
      PlanetScene.music: PlanetSceneTheme(
        genreAnchorLabel: 'Жанры',
        genreSectionTitle: 'Жанры',
        checklistTitle: 'Музыкальные жанры',
        featuredTitle: 'Трек дня',
        coverIcon: Icons.music_note_outlined,
        bannerHeadline: 'Делись музыкой, находи компанию на концерты!',
        bannerSubtitle: 'Рассказывай о любимом звуке и собирай вечеринки',
      ),
      PlanetScene.sports: PlanetSceneTheme(
        genreAnchorLabel: 'Дисциплины',
        genreSectionTitle: 'Дисциплины',
        checklistTitle: 'Виды спорта',
        featuredTitle: 'Событие дня',
        coverIcon: Icons.sports_outlined,
        bannerHeadline: 'Делись победами, находи компанию для спорта!',
        bannerSubtitle: 'Рассказывай о тренировках и собирай матчи',
      ),
      PlanetScene.reading: PlanetSceneTheme(
        genreAnchorLabel: 'Форматы',
        genreSectionTitle: 'Форматы',
        checklistTitle: 'Что читаем и слушаем',
        featuredTitle: 'Чтение дня',
        coverIcon: Icons.auto_stories_outlined,
        bannerHeadline: 'Делись находками, находи компанию по чтению!',
        bannerSubtitle: 'Рассказывай о прочитанном и меняй рекомендациями',
      ),
      PlanetScene.art: PlanetSceneTheme(
        genreAnchorLabel: 'Направления',
        genreSectionTitle: 'Направления',
        checklistTitle: 'Виды искусства',
        featuredTitle: 'Работа дня',
        coverIcon: Icons.palette_outlined,
        bannerHeadline: 'Делись творчеством, находи компанию в галерее!',
        bannerSubtitle: 'Рассказывай о выставках и собирай художественные вечера',
      ),
      PlanetScene.technology: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Технологии и инструменты',
        featuredTitle: 'Новость дня',
        coverIcon: Icons.computer_outlined,
        bannerHeadline: 'Делись находками, находи компанию в технологиях!',
        bannerSubtitle: 'Рассказывай о разработке и собирай митапы',
      ),
      PlanetScene.food: PlanetSceneTheme(
        genreAnchorLabel: 'Кухни',
        genreSectionTitle: 'Кухни',
        checklistTitle: 'Кулинарные интересы',
        featuredTitle: 'Рецепт дня',
        coverIcon: Icons.restaurant_outlined,
        bannerHeadline: 'Делись рецептами, находи компанию за столом!',
        bannerSubtitle: 'Рассказывай о еде и собирай гастрономические встречи',
      ),
      PlanetScene.nature: PlanetSceneTheme(
        genreAnchorLabel: 'Активности',
        genreSectionTitle: 'Активности',
        checklistTitle: 'Природа и активность',
        featuredTitle: 'Маршрут дня',
        coverIcon: Icons.forest_outlined,
        bannerHeadline: 'Делись маршрутами, находи компанию на природе!',
        bannerSubtitle: 'Рассказывай о походах и собирай вылазки',
      ),
      PlanetScene.gaming: PlanetSceneTheme(
        genreAnchorLabel: 'Жанры',
        genreSectionTitle: 'Жанры',
        checklistTitle: 'Игровые жанры и платформы',
        featuredTitle: 'Игра дня',
        coverIcon: Icons.sports_esports_outlined,
        bannerHeadline: 'Делись прохождениями, находи компанию в игре!',
        bannerSubtitle: 'Рассказывай о играх и собирай турниры',
      ),
      PlanetScene.cars: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Автомобильные интересы',
        featuredTitle: 'Поездка дня',
        coverIcon: Icons.directions_car_outlined,
        bannerHeadline: 'Делись поездками, находи компанию в дороге!',
        bannerSubtitle: 'Рассказывай об автомобилях и собирай выезды',
      ),
      PlanetScene.animals: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Мир животных',
        featuredTitle: 'История дня',
        coverIcon: Icons.pets_outlined,
        bannerHeadline: 'Делись историями, находи компанию любителей животных!',
        bannerSubtitle: 'Рассказывай о питомцах и собирай встречи',
      ),
      PlanetScene.gardening: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Садовые интересы',
        featuredTitle: 'Растение дня',
        coverIcon: Icons.yard_outlined,
        bannerHeadline: 'Делись урожаем, находи компанию в саду!',
        bannerSubtitle: 'Рассказывай о растениях и обменивайся черенками',
      ),
      PlanetScene.esoteric: PlanetSceneTheme(
        genreAnchorLabel: 'Практики',
        genreSectionTitle: 'Практики',
        checklistTitle: 'Эзотерические интересы',
        featuredTitle: 'Расклад дня',
        coverIcon: Icons.auto_awesome_outlined,
        bannerHeadline: 'Делись открытиями, находи компанию по убеждениям!',
        bannerSubtitle: 'Рассказывай о практиках и собирай встречи',
      ),
      PlanetScene.finance: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Финансовые интересы',
        featuredTitle: 'Обзор дня',
        coverIcon: Icons.show_chart_outlined,
        bannerHeadline: 'Делись идеями, находи компанию по инвестициям!',
        bannerSubtitle: 'Рассказывай о рынках и собирай дискуссионные клубы',
      ),
      PlanetScene.volunteering: PlanetSceneTheme(
        genreAnchorLabel: 'Направления',
        genreSectionTitle: 'Направления',
        checklistTitle: 'Волонтёрские интересы',
        featuredTitle: 'Акция дня',
        coverIcon: Icons.volunteer_activism_outlined,
        bannerHeadline: 'Делись добром, находи компанию для волонтёрства!',
        bannerSubtitle: 'Рассказывай о проектах и собирай помощников',
      ),
      PlanetScene.psychology: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Психологические интересы',
        featuredTitle: 'Мысль дня',
        coverIcon: Icons.psychology_outlined,
        bannerHeadline: 'Делись мыслями, находи компанию для разговоров!',
        bannerSubtitle: 'Рассказывай об опыте и собирай встречи',
      ),
      PlanetScene.other: PlanetSceneTheme(
        genreAnchorLabel: 'Увлечения',
        genreSectionTitle: 'Увлечения',
        checklistTitle: 'Разные интересы',
        featuredTitle: 'Материал дня',
        coverIcon: Icons.interests_outlined,
        bannerHeadline: 'Делись увлечениями, находи компанию по интересам!',
        bannerSubtitle: 'Рассказывай о необычном и собирай встречи',
      ),
      PlanetScene.selfDevelopment: PlanetSceneTheme(
        genreAnchorLabel: 'Направления',
        genreSectionTitle: 'Направления',
        checklistTitle: 'Интересы развития',
        featuredTitle: 'Идея дня',
        coverIcon: Icons.trending_up_outlined,
        bannerHeadline: 'Делись прогрессом, находи компанию для роста!',
        bannerSubtitle: 'Рассказывай о целях и собирай встречи',
      ),
      PlanetScene.collecting: PlanetSceneTheme(
        genreAnchorLabel: 'Коллекции',
        genreSectionTitle: 'Коллекции',
        checklistTitle: 'Что коллекционируем',
        featuredTitle: 'Экспонат дня',
        coverIcon: Icons.collections_outlined,
        bannerHeadline: 'Делись находками, находи компанию коллекционеров!',
        bannerSubtitle: 'Рассказывай о коллекциях и обменивайся находками',
      ),
      PlanetScene.space: PlanetSceneTheme(
        genreAnchorLabel: 'Темы',
        genreSectionTitle: 'Темы',
        checklistTitle: 'Космические интересы',
        featuredTitle: 'Материал дня',
        coverIcon: Icons.rocket_launch_outlined,
        bannerHeadline: 'Делись открытиями, находи компанию звёзд!',
        bannerSubtitle: 'Рассказывай о космосе и собирай встречи',
      ),
    };

PlanetSceneTheme themeForScene(PlanetScene scene) =>
    planetSceneThemes[scene] ?? _fallbackTheme;
