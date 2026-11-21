import 'package:dreem_world/data/models/interest.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/data/services/scoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ScoringService scoring = ScoringService();
  final Profile me = MockProfileRepository.seedProfiles.first;
  final Profile anna = MockProfileRepository.seedProfiles[1];

  test('оценка в диапазоне 0..100 и детерминирована', () async {
    final int first = await scoring.computeCompatibility(me, anna);
    final int second = await scoring.computeCompatibility(me, anna);

    expect(first, inInclusiveRange(0, 100));
    expect(first, second);
    expect(await scoring.computeCompatibility(me, me), greaterThan(first));
  });

  test('ранжирование ставит наиболее похожую анкету первой', () {
    final List<ScoredProfile> ranked = scoring.rank(
      me,
      MockProfileRepository.seedProfiles.skip(1),
    );

    expect(ranked.first.profile.id, 'p_anna');
    for (int i = 1; i < ranked.length; i++) {
      expect(ranked[i - 1].score, greaterThanOrEqualTo(ranked[i].score));
    }
  });

  test('незаполненная анкета и текущий пользователь не попадают в подбор', () {
    const Profile empty = Profile(id: 'empty', name: 'Пусто', age: 20);
    final List<ScoredProfile> ranked = scoring.rank(
      me,
      <Profile>[me, empty, anna],
    );

    expect(ranked.map((ScoredProfile item) => item.profile.id), <String>[
      'p_anna',
    ]);
    expect(scoring.isCompleteEnough(empty), isFalse);
    expect(scoring.isCompleteEnough(anna), isTrue);
  });

  test('названия интересов нормализуются до каталожных идентификаторов', () async {
    final Profile canonical = anna.copyWith(
      id: 'canonical',
      interests: <Interest>[InterestCatalog.cinema, InterestCatalog.music],
    );
    final Profile alias = canonical.copyWith(
      id: 'alias',
      interests: <Interest>[
        const Interest(id: 'фильмы', name: 'Фильмы'),
        const Interest(id: 'Музыка', name: 'Музыка'),
      ],
    );
    final Profile unrelated = canonical.copyWith(
      id: 'unrelated',
      interests: <Interest>[InterestCatalog.sport, InterestCatalog.food],
    );

    final int aliasScore = await scoring.computeCompatibility(canonical, alias);
    final int unrelatedScore =
        await scoring.computeCompatibility(canonical, unrelated);

    expect(aliasScore, greaterThan(unrelatedScore));
  });

  test('существующие темы и перевод сохраняются', () async {
    expect(await scoring.suggestTopics(me, anna), isNotEmpty);
    expect(await scoring.translate('Привет', 'en'), '[en] Привет');
  });
}
