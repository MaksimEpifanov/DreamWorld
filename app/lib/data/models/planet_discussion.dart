/// Обсуждение внутри планеты на произвольную тему её тематики.
///
/// Создаётся участником планеты и общее для всех: его видят на сайте и в
/// приложении. Хранится в Firestore (`planets/{planetId}/discussions`).
class PlanetDiscussion {
  const PlanetDiscussion({
    required this.id,
    required this.planetId,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.description = '',
    this.topic = '',
    this.tags = const <String>[],
    this.messagesCount = 0,
    this.lastActivityAt = '',
  });

  final String id;
  final String planetId;
  final String title;
  final String description;

  /// Произвольная тема обсуждения, которую придумал пользователь.
  final String topic;

  /// Произвольные метки для поиска и подписей.
  final List<String> tags;

  /// Идентификатор и имя создателя обсуждения.
  final String authorId;
  final String authorName;

  /// Время создания в формате ISO-8601.
  final String createdAt;

  /// Число сообщений в обсуждении.
  final int messagesCount;

  /// Время последнего сообщения (для сортировки списка).
  final String lastActivityAt;

  DateTime? get createdAtValue => DateTime.tryParse(createdAt);

  DateTime? get lastActivityValue => DateTime.tryParse(lastActivityAt);

  String get emoji => '💬';

  bool isAuthor(String userId) => userId.isNotEmpty && userId == authorId;

  PlanetDiscussion copyWith({
    String? title,
    String? description,
    String? topic,
    List<String>? tags,
  }) => PlanetDiscussion(
    id: id,
    planetId: planetId,
    title: title ?? this.title,
    description: description ?? this.description,
    topic: topic ?? this.topic,
    tags: tags ?? this.tags,
    authorId: authorId,
    authorName: authorName,
    createdAt: createdAt,
    messagesCount: messagesCount,
    lastActivityAt: lastActivityAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'planetId': planetId,
    'title': title,
    'description': description,
    'topic': topic,
    'tags': tags,
    'authorId': authorId,
    'authorName': authorName,
    'createdAt': createdAt,
    'messagesCount': messagesCount,
    'lastActivityAt': lastActivityAt.isEmpty ? createdAt : lastActivityAt,
  };

  factory PlanetDiscussion.fromJson(Map<String, dynamic> json) =>
      PlanetDiscussion(
        id: '${json['id'] ?? ''}',
        planetId: '${json['planetId'] ?? ''}',
        title: '${json['title'] ?? ''}',
        description: '${json['description'] ?? ''}',
        topic: '${json['topic'] ?? json['category'] ?? ''}',
        tags: _stringList(json['tags']),
        authorId: '${json['authorId'] ?? ''}',
        authorName: '${json['authorName'] ?? ''}',
        createdAt: '${json['createdAt'] ?? ''}',
        messagesCount: _toInt(json['messagesCount']),
        lastActivityAt: '${json['lastActivityAt'] ?? ''}',
      );

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((Object? item) => '$item')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
