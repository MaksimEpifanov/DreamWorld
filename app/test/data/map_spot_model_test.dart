import 'package:dreem_world/data/models/map_spot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapSpot: сериализация для Firestore', () {
    test('toJson/fromJson сохраняют поля отметки', () {
      const MapSpot spot = MapSpot(
        id: 's1',
        title: 'Тихий берег',
        description: 'Уютное место',
        authorName: 'Аня',
        authorId: 'u_anna',
        emoji: '🏞️',
        tags: <String>['Природа'],
        likes: 7,
        x: 0.3,
        y: 0.4,
        latitude: 12.5,
        longitude: 34.5,
        comments: <MapComment>[
          MapComment(authorName: 'Марк', text: 'Класс', authorId: 'u_mark'),
        ],
      );
      final Map<String, dynamic> json = spot.toJson();
      // Число лайков в облаке считается по `likedBy`, а не хранится отдельно.
      expect(json.containsKey('likes'), isFalse);

      final MapSpot restored = MapSpot.fromJson(<String, dynamic>{
        ...json,
        'likedBy': <String>['u_anna', 'u_mark'],
      });

      expect(restored.title, 'Тихий берег');
      expect(restored.authorId, 'u_anna');
      expect(restored.tags, <String>['Природа']);
      expect(restored.latitude, 12.5);
      expect(restored.longitude, 34.5);
      expect(restored.comments.single.text, 'Класс');
      expect(restored.likes, 2);
      expect(restored.isLikedBy('u_anna'), isTrue);
      expect(restored.isLikedBy('u_other'), isFalse);
    });

    test('fromJson терпим к отсутствующим полям', () {
      final MapSpot spot = MapSpot.fromJson(<String, dynamic>{'id': 'x'});

      expect(spot.id, 'x');
      expect(spot.tags, isEmpty);
      expect(spot.likes, 0);
      expect(spot.likedBy, isEmpty);
      expect(spot.emoji, '📍');
      expect(spot.comments, isEmpty);
    });

    test('copyWith меняет только указанные поля', () {
      const MapSpot spot = MapSpot(
        id: 's1',
        title: 'Точка',
        description: 'Описание',
        authorName: 'Аня',
        emoji: '📍',
        tags: <String>['Тег'],
        likes: 1,
        x: 0.1,
        y: 0.2,
      );

      final MapSpot updated = spot.copyWith(
        likes: 5,
        likedBy: const <String>['u1'],
      );

      expect(updated.id, 's1');
      expect(updated.title, 'Точка');
      expect(updated.likes, 5);
      expect(updated.likedBy, <String>['u1']);
    });
  });
}
