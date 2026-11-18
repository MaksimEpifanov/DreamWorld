/// Событие планеты: встреча, поездка или сбор, который создал участник.
///
/// Пример: «Рыбалка на Волгу» — нужно 2 человека, выезд 13 августа из Дубны.
/// Событие привязано к планете и общее для всех: его видят на сайте и в
/// приложении. Хранится в Firestore (`planets/{planetId}/events`).
///
/// Пользователи подают заявки ([applicantIds]), а организатор подтверждает
/// участников ([participantIds]) или отклоняет заявку.
class PlanetEvent {
  const PlanetEvent({
    required this.id,
    required this.planetId,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.description = '',
    this.emoji = '📅',
    this.date = '',
    this.place = '',
    this.seats = 0,
    this.applicantIds = const <String>[],
    this.participantIds = const <String>[],
  });

  final String id;
  final String planetId;
  final String title;
  final String description;

  /// Эмодзи-«обложка» события.
  final String emoji;

  /// Идентификатор и имя организатора.
  final String authorId;
  final String authorName;

  /// Время создания в формате ISO-8601 (для сортировки).
  final String createdAt;

  /// Дата события в формате `ГГГГ-ММ-ДД`; пустая строка — дата не указана.
  final String date;

  /// Место или точка сбора (например, «Выезд из Дубны»).
  final String place;

  /// Сколько человек нужно; `0` — без ограничения.
  final int seats;

  /// Заявки, ожидающие решения организатора.
  final List<String> applicantIds;

  /// Подтверждённые организатором участники.
  final List<String> participantIds;

  DateTime? get dateValue => DateTime.tryParse(date);

  /// Задано ли ограничение по числу участников.
  bool get hasLimit => seats > 0;

  /// Сколько участников уже подтверждено.
  int get taken => participantIds.length;

  /// Набрано ли нужное число участников.
  bool get isFull => hasLimit && participantIds.length >= seats;

  bool isAuthor(String userId) => userId.isNotEmpty && userId == authorId;

  bool hasApplied(String userId) =>
      userId.isNotEmpty && applicantIds.contains(userId);

  bool isParticipant(String userId) =>
      userId.isNotEmpty && participantIds.contains(userId);

  PlanetEvent copyWith({
    String? title,
    String? description,
    String? emoji,
    String? date,
    String? place,
    int? seats,
    List<String>? applicantIds,
    List<String>? participantIds,
  }) => PlanetEvent(
    id: id,
    planetId: planetId,
    title: title ?? this.title,
    description: description ?? this.description,
    emoji: emoji ?? this.emoji,
    authorId: authorId,
    authorName: authorName,
    createdAt: createdAt,
    date: date ?? this.date,
    place: place ?? this.place,
    seats: seats ?? this.seats,
    applicantIds: applicantIds ?? this.applicantIds,
    participantIds: participantIds ?? this.participantIds,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'planetId': planetId,
    'title': title,
    'description': description,
    'emoji': emoji,
    'authorId': authorId,
    'authorName': authorName,
    'createdAt': createdAt,
    'date': date,
    'place': place,
    'seats': seats,
    'applicantIds': applicantIds,
    'participantIds': participantIds,
  };

  factory PlanetEvent.fromJson(Map<String, dynamic> json) => PlanetEvent(
    id: '${json['id'] ?? ''}',
    planetId: '${json['planetId'] ?? ''}',
    title: '${json['title'] ?? ''}',
    description: '${json['description'] ?? ''}',
    emoji: '${json['emoji'] ?? '📅'}',
    authorId: '${json['authorId'] ?? ''}',
    authorName: '${json['authorName'] ?? ''}',
    createdAt: '${json['createdAt'] ?? ''}',
    date: '${json['date'] ?? ''}',
    place: '${json['place'] ?? ''}',
    seats: _toInt(json['seats']),
    applicantIds: _stringList(json['applicantIds']),
    participantIds: _stringList(json['participantIds']),
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
