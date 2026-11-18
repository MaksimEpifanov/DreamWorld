import 'package:dreem_world/data/models/planet_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanetEvent: сериализация', () {
    test('toJson/fromJson сохраняют поля события', () {
      const PlanetEvent event = PlanetEvent(
        id: 'e1',
        planetId: 'p_fishing',
        title: 'Рыбалка на Волгу',
        description: 'Выезд из Дубны',
        emoji: '🎣',
        authorId: 'u1',
        authorName: 'Иван',
        createdAt: '2026-11-18T10:00:00.000Z',
        date: '2026-08-13',
        place: 'Дубна',
        seats: 2,
        applicantIds: <String>['u2'],
        participantIds: <String>['u3'],
      );

      final PlanetEvent restored = PlanetEvent.fromJson(event.toJson());

      expect(restored.id, 'e1');
      expect(restored.planetId, 'p_fishing');
      expect(restored.title, 'Рыбалка на Волгу');
      expect(restored.description, 'Выезд из Дубны');
      expect(restored.emoji, '🎣');
      expect(restored.authorId, 'u1');
      expect(restored.authorName, 'Иван');
      expect(restored.date, '2026-08-13');
      expect(restored.place, 'Дубна');
      expect(restored.seats, 2);
      expect(restored.applicantIds, <String>['u2']);
      expect(restored.participantIds, <String>['u3']);
      expect(restored.dateValue, isNotNull);
    });

    test('fromJson терпим к отсутствующим полям', () {
      final PlanetEvent event = PlanetEvent.fromJson(<String, dynamic>{
        'id': 'x',
      });
      expect(event.id, 'x');
      expect(event.title, '');
      expect(event.seats, 0);
      expect(event.applicantIds, isEmpty);
      expect(event.participantIds, isEmpty);
      expect(event.emoji, '📅');
    });
  });

  group('PlanetEvent: состояние', () {
    test('лимит мест и полнота', () {
      const PlanetEvent event = PlanetEvent(
        id: 'e',
        planetId: 'p',
        title: 't',
        authorId: 'a',
        authorName: 'A',
        createdAt: '',
        seats: 2,
        participantIds: <String>['x', 'y'],
      );

      expect(event.hasLimit, isTrue);
      expect(event.taken, 2);
      expect(event.isFull, isTrue);
      expect(event.isAuthor('a'), isTrue);
      expect(event.isAuthor('b'), isFalse);
      expect(event.isParticipant('x'), isTrue);
      expect(event.hasApplied('x'), isFalse);
    });

    test('без ограничения по числу участников', () {
      const PlanetEvent event = PlanetEvent(
        id: 'e',
        planetId: 'p',
        title: 't',
        authorId: 'a',
        authorName: 'A',
        createdAt: '',
        applicantIds: <String>['u'],
      );

      expect(event.hasLimit, isFalse);
      expect(event.isFull, isFalse);
      expect(event.hasApplied('u'), isTrue);
      expect(event.hasApplied(''), isFalse);
    });
  });
}
