import '../models/interest.dart';
import '../models/profile.dart';
import 'ai_service.dart';
import 'mock_ai_service.dart';

final class ScoredProfile {
  const ScoredProfile({required this.profile, required this.score});

  final Profile profile;
  final int score;
}

class ScoringService implements AiService {
  const ScoringService();

  static const double minCompleteness = 0.6;

  static const Map<String, String> _interestAliases = <String, String>{
    'кино': 'i_cinema',
    'фильмы': 'i_cinema',
    'фото': 'i_photo',
    'фотография': 'i_photo',
    'музыка': 'i_music',
    'путешествия': 'i_travel',
    'путешествие': 'i_travel',
    'спорт': 'i_sport',
    'искусство': 'i_art',
    'технологии': 'i_tech',
    'айти': 'i_tech',
    'кулинария': 'i_food',
    'готовка': 'i_food',
    'книги': 'i_books',
    'чтение': 'i_books',
    'игры': 'i_games',
    'гейминг': 'i_games',
    'природа': 'i_nature',
    'фитнес': 'i_fitness',
  };

  static const MockAiService _delegate = MockAiService();

  @override
  Future<int> computeCompatibility(Profile a, Profile b) async => score(a, b);

  @override
  Future<List<String>> suggestTopics(Profile a, Profile b) =>
      _delegate.suggestTopics(a, b);

  @override
  Future<String> translate(String text, String targetLang) =>
      _delegate.translate(text, targetLang);

  int score(Profile a, Profile b) {
    final double total = _interestScore(a, b) * 0.36 +
        _detailScore(a, b) * 0.16 +
        _intentScore(a, b) * 0.20 +
        _contextScore(a, b) * 0.14 +
        _activityScore(b) * 0.06 +
        completeness(b) * 0.08;
    return (total * 100).round().clamp(0, 100);
  }

  double completeness(Profile profile) {
    final List<bool> fields = <bool>[
      (profile.city ?? '').trim().isNotEmpty,
      (profile.country ?? '').trim().isNotEmpty,
      (profile.bio ?? '').trim().isNotEmpty,
      profile.interests.isNotEmpty,
      profile.detailedInterests.isNotEmpty,
      profile.goals.isNotEmpty,
      profile.values.isNotEmpty,
      profile.languages.isNotEmpty,
      (profile.photoUrl ?? '').trim().isNotEmpty || profile.photoUrls.isNotEmpty,
    ];
    return fields.where((bool value) => value).length / fields.length;
  }

  bool isCompleteEnough(Profile profile) =>
      completeness(profile) >= minCompleteness;

  List<ScoredProfile> rank(
    Profile me,
    Iterable<Profile> candidates, {
    bool onlyComplete = true,
  }) {
    final Set<String> contacts = me.contactIds.toSet();
    final List<ScoredProfile> result = <ScoredProfile>[];
    for (final Profile candidate in candidates) {
      if (candidate.id == me.id) continue;
      if (contacts.contains(candidate.id)) continue;
      if (onlyComplete && !isCompleteEnough(candidate)) continue;
      result.add(
        ScoredProfile(profile: candidate, score: score(me, candidate)),
      );
    }
    result.sort((ScoredProfile a, ScoredProfile b) => b.score.compareTo(a.score));
    return List<ScoredProfile>.unmodifiable(result);
  }

  double _interestScore(Profile a, Profile b) {
    final Set<String> aIds = a.interests.map(_normalizeInterest).toSet();
    final Set<String> bIds = b.interests.map(_normalizeInterest).toSet();
    if (aIds.isEmpty && bIds.isEmpty) return 0.15;

    final Set<String> aCategories = a.interests.map(_categoryOf).toSet();
    final Set<String> bCategories = b.interests.map(_categoryOf).toSet();
    return _jaccard(aIds, bIds) * 0.75 + _jaccard(aCategories, bCategories) * 0.25;
  }

  double _detailScore(Profile a, Profile b) {
    final Set<String> aTokens = _detailTokens(a);
    final Set<String> bTokens = _detailTokens(b);
    if (aTokens.isEmpty && bTokens.isEmpty) return 0.2;
    if (aTokens.isEmpty || bTokens.isEmpty) return 0.1;
    return _jaccard(aTokens, bTokens);
  }

  double _intentScore(Profile a, Profile b) {
    final double goals = _stringOverlap(a.goals, b.goals);
    final double values = _stringOverlap(a.values, b.values);
    final double goal = _goalScore(a.relationshipGoal, b.relationshipGoal);
    return goals * 0.4 + values * 0.35 + goal * 0.25;
  }

  double _contextScore(Profile a, Profile b) {
    final int ageDiff = (a.age - b.age).abs();
    final double age = ageDiff >= 15 ? 0 : 1 - ageDiff / 15;

    final String aCity = _normalizeText(a.city ?? '');
    final String bCity = _normalizeText(b.city ?? '');
    final String aCountry = _normalizeText(a.country ?? '');
    final String bCountry = _normalizeText(b.country ?? '');
    double geo = 0.15;
    if (aCity.isNotEmpty && bCity.isNotEmpty && aCity == bCity) {
      geo = 1;
    } else if (aCountry.isNotEmpty && bCountry.isNotEmpty && aCountry == bCountry) {
      geo = 0.5;
    }

    final Set<String> aLanguages = a.languages.map(_normalizeText).toSet();
    final Set<String> bLanguages = b.languages.map(_normalizeText).toSet();
    final double languages =
        aLanguages.isEmpty || bLanguages.isEmpty ? 0.4 : _jaccard(aLanguages, bLanguages);

    return age * 0.45 + geo * 0.3 + languages * 0.25;
  }

  double _activityScore(Profile profile) => profile.isOnline ? 1 : 0.4;

  double _goalScore(RelationshipGoal a, RelationshipGoal b) {
    if (a == b) return 1;
    if (a == RelationshipGoal.chat && b == RelationshipGoal.friendship) return 0.6;
    if (a == RelationshipGoal.friendship && b == RelationshipGoal.chat) return 0.6;
    if (a == RelationshipGoal.friendship && b == RelationshipGoal.dating) return 0.5;
    if (a == RelationshipGoal.dating && b == RelationshipGoal.friendship) return 0.5;
    if (a == RelationshipGoal.dating && b == RelationshipGoal.serious) return 0.7;
    if (a == RelationshipGoal.serious && b == RelationshipGoal.dating) return 0.7;
    return 0.15;
  }

  Set<String> _detailTokens(Profile profile) => <String>{
        for (final String item in profile.detailedInterests)
          _normalizeText(item),
        for (final String item in profile.joinedPlanetIds)
          _normalizeText(item),
      }..removeWhere((String item) => item.isEmpty);

  double _stringOverlap(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.3;
    return _jaccard(
      a.map(_normalizeText).toSet(),
      b.map(_normalizeText).toSet(),
    );
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 0.3;
    final Set<String> union = a.union(b);
    if (union.isEmpty) return 0.3;
    return a.intersection(b).length / union.length;
  }

  String _normalizeInterest(Interest interest) {
    final String id = _normalizeText(interest.id);
    if (id.startsWith('i_')) return id;
    final String name = _normalizeText(interest.name);
    if (_interestAliases.containsKey(name)) return _interestAliases[name]!;
    if (_interestAliases.containsKey(id)) return _interestAliases[id]!;
    for (final Interest item in InterestCatalog.all) {
      if (_normalizeText(item.name) == name) return item.id;
    }
    return id.isEmpty ? name : id;
  }

  String _categoryOf(Interest interest) {
    final String id = _normalizeInterest(interest);
    for (final Interest item in InterestCatalog.all) {
      if (item.id == id) return item.category.name;
    }
    return interest.category.name;
  }

  String _normalizeText(String value) {
    String result = value.trim().toLowerCase().replaceAll('ё', 'е');
    final int bracket = result.indexOf('(');
    if (bracket > 0) result = result.substring(0, bracket);
    result = result.replaceAll(RegExp(r'[^\p{L}\p{N} ]+', unicode: true), ' ');
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
