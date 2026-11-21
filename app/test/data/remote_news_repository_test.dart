import 'dart:ui' show Color;

import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_news.dart';
import 'package:dreem_world/data/repositories/remote_news_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const Planet planet = Planet(
    id: 'p_gaming',
    name: 'Планета геймеров',
    tagline: 'Тест',
    description: 'Тест',
    emoji: '🎮',
    scene: PlanetScene.gaming,
    primary: Color(0xFF000000),
    secondary: Color(0xFF000000),
    accent: Color(0xFF000000),
    keywords: <String>['Игры'],
    memberCount: 1,
  );

  const String validBody = '''
  {"planetId":"p_gaming","news":[
    {"id":"n1","title":"Игра","summary":"Коротко","emoji":"🎮",
     "sourceName":"Источник","tag":"Игры",
     "publishedAt":"2026-11-21T10:00:00Z","likes":7,
     "sourceUrl":"https://example.com/news"}
  ]}
  ''';

  test('parseNews разбирает валидный JSON и ссылку', () {
    final List<PlanetNewsItem> news = parseNews(validBody);
    expect(news, hasLength(1));
    expect(news.single.id, 'n1');
    expect(news.single.sourceUrl, 'https://example.com/news');
  });

  test('parseNews возвращает пустой список для битых данных', () {
    expect(parseNews('not json'), isEmpty);
    expect(parseNews('{}'), isEmpty);
  });

  test('fetch кэширует новости и возвращает null при ошибке', () async {
    int calls = 0;
    final RemoteNewsRepository repository = RemoteNewsRepository(
      client: MockClient((http.Request request) async {
        calls++;
        if (calls == 1) {
          return http.Response(validBody, 200, headers: <String, String>{
            'content-type': 'application/json; charset=utf-8',
          });
        }
        return http.Response('error', 500);
      }),
      baseUrl: 'https://example.com/news',
    );

    final List<PlanetNewsItem>? loaded = await repository.fetch(planet);
    expect(loaded, hasLength(1));
    expect(repository.cached('p_gaming'), hasLength(1));
    expect(calls, 1);

    final List<PlanetNewsItem>? failed = await repository.fetch(planet);
    expect(failed, isNull);
    expect(calls, 2);
    expect(repository.cached('p_gaming'), hasLength(1));
  });
}
