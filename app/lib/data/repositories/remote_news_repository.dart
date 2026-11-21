import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/planet.dart';
import '../models/planet_news.dart';

class RemoteNewsRepository {
  RemoteNewsRepository({http.Client? client, this.baseUrl = defaultBaseUrl})
    : _client = client ?? http.Client();

  static const String defaultBaseUrl = String.fromEnvironment(
    'NEWS_BASE_URL',
    defaultValue: 'https://maksimepifanov.github.io/DreamWorld/news',
  );

  final http.Client _client;
  final String baseUrl;
  final Map<String, List<PlanetNewsItem>> _cache =
      <String, List<PlanetNewsItem>>{};

  List<PlanetNewsItem>? cached(String planetId) => _cache[planetId];

  void dispose() => _client.close();

  Future<List<PlanetNewsItem>?> fetch(Planet planet) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/${planet.id}.json');
      final http.Response response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final List<PlanetNewsItem> items = parseNews(response.body);
      if (items.isEmpty) return null;
      _cache[planet.id] = items;
      return items;
    } catch (_) {
      return null;
    }
  }
}

List<PlanetNewsItem> parseNews(String body) {
  try {
    final Map<String, dynamic> decoded = jsonDecode(body) as Map<String, dynamic>;
    final List<dynamic> list =
        decoded['news'] as List<dynamic>? ?? const <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => PlanetNewsItem.fromJson(item))
        .where(
          (PlanetNewsItem item) => item.title.isNotEmpty && item.id.isNotEmpty,
        )
        .toList(growable: false);
  } catch (_) {
    return const <PlanetNewsItem>[];
  }
}
