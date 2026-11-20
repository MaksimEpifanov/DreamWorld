import 'package:flutter/material.dart';

import '../../../../core/constants/planet_genre_visuals.dart';
import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/repositories/mock_planet_repository.dart';
import 'universal_portal_dataset.dart';
import 'universal_portal_visuals.dart';
import 'datasets/portal_art_dataset.dart';
import 'datasets/portal_cars_dataset.dart';
import 'datasets/portal_cinema_dataset.dart';
import 'datasets/portal_collecting_dataset.dart';
import 'datasets/portal_esoteric_dataset.dart';
import 'datasets/portal_finance_dataset.dart';
import 'datasets/portal_food_dataset.dart';
import 'datasets/portal_gaming_dataset.dart';
import 'datasets/portal_gardening_dataset.dart';
import 'datasets/portal_music_dataset.dart';
import 'datasets/portal_nature_dataset.dart';
import 'datasets/portal_other_dataset.dart';
import 'datasets/portal_psychology_dataset.dart';
import 'datasets/portal_reading_dataset.dart';
import 'datasets/portal_selfdev_dataset.dart';
import 'datasets/portal_sports_dataset.dart';
import 'datasets/portal_tech_dataset.dart';
import 'datasets/portal_travel_dataset.dart';
import 'datasets/portal_volunteering_dataset.dart';

class PortalCatalog {
  const PortalCatalog._();

  static const Color accent = Color(0xFF9BE15D);
  static const Color cyan = Color(0xFFFFB74D);
  static const Color panel = Color(0xA6111A33);
  static const Color border = Color(0x3D9BE15D);

  static final Map<String, PortalDataset> _datasets =
      <String, PortalDataset>{
        'p_travel': travelDataset,
        'p_cinema': cinemaDataset,
        'p_music': musicDataset,
        'p_sports': sportsDataset,
        'p_reading': readingDataset,
        'p_art': artDataset,
        'p_tech': techDataset,
        'p_food': foodDataset,
        'p_nature': natureDataset,
        'p_gaming': gamingDataset,
        'p_cars': carsDataset,
        'p_gardening': gardeningDataset,
        'p_esoteric': esotericDataset,
        'p_finance': financeDataset,
        'p_volunteering': volunteeringDataset,
        'p_psychology': psychologyDataset,
        'p_other': otherDataset,
        'p_selfdev': selfdevDataset,
        'p_collecting': collectingDataset,
      };

  static const Set<String> dedicatedPortals = <String>{
        'p_fishing',
        'p_animals',
      };

  static const List<String> universalPlanetIds = <String>[
        'p_travel',
        'p_cinema',
        'p_music',
        'p_sports',
        'p_reading',
        'p_art',
        'p_tech',
        'p_food',
        'p_nature',
        'p_gaming',
        'p_cars',
        'p_gardening',
        'p_esoteric',
        'p_finance',
        'p_volunteering',
        'p_psychology',
        'p_other',
        'p_selfdev',
        'p_collecting',
      ];

  static Planet planet(String id) {
    for (final Planet item in MockPlanetRepository.planets) {
      if (item.id == id) return item;
    }
    return MockPlanetRepository.planets.first;
  }

  static PortalDataset? dataset(String id) => _datasets[id];

  static bool isUniversal(String id) =>
      !dedicatedPortals.contains(id) && _datasets.containsKey(id);

  static String title(String id) => planet(id).shortName;

  static String subtitle(String id) => planet(id).tagline;

  static String members(String id) {
    final int count = planet(id).memberCount;
    final String formatted = count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match match) => '${match.group(1)} ',
    );
    return formatted.trim();
  }

  static String online(String id) {
    final int count = (planet(id).memberCount / 16).round();
    return count.toString();
  }

  static String featuredTitle(String id) {
    final PlanetSceneTheme theme = themeForScene(planet(id).scene);
    return theme.featuredTitle;
  }

  static String featuredSubtitle(String id) {
    final PortalDataset? data = dataset(id);
    if (data != null && data.types.isNotEmpty) {
      return data.types.first.short;
    }
    return planet(id).tagline;
  }

  static String featuredAuthor(String id) => PortalVisuals.author(id);

  static const String featuredLikes = '186';
  static const String featuredComments = '31';

  static String bottomTitle(String id) {
    final PlanetSceneTheme theme = themeForScene(planet(id).scene);
    return theme.bannerHeadline;
  }

  static String bottomSubtitle(String id) {
    final PlanetSceneTheme theme = themeForScene(planet(id).scene);
    return theme.bannerSubtitle;
  }

  static String kindsLabel(String id) =>
      dataset(id)?.kindsLabel ?? themeForScene(planet(id).scene).checklistTitle;

  static List<String> tabs(String id) => <String>[
        'Главная',
        kindsLabel(id),
        'Новости',
        'Люди',
        'События',
        'Карта',
        'Чат',
      ];

  static List<String> directions(String id) {
    final List<PlanetGenreVisual>? genres =
        planetGenreVisualsByScene[planet(id).scene];
    if (genres == null) return <String>[];
    return genres.take(6).map((PlanetGenreVisual item) => item.shortLabel).toList();
  }
}
