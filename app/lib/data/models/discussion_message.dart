/// Сообщение внутри обсуждения планеты.
///
/// Один участник может писать несколько сообщений: идентификатор сообщения —
/// uuid, а не UID. К каждому сообщению можно приложить до трёх фото и
/// опциональную оценку от 1 до 5.
class DiscussionMessage {
  const DiscussionMessage({
    required this.id,
    required this.discussionId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.rating,
    this.photoUrls = const <String>[],
    this.likedBy = const <String>[],
  });

  final String id;
  final String discussionId;
  final String authorId;
  final String authorName;
  final String text;

  /// Оценка от 1 до 5 или `null`, если автор не ставил оценку.
  final int? rating;

  /// Ссылки на фото в Firebase Storage (в мок-режиме — data URI).
  final List<String> photoUrls;

  /// Кто поставил лайк.
  final List<String> likedBy;

  final String createdAt;

  DateTime? get createdAtValue => DateTime.tryParse(createdAt);

  bool isAuthor(String userId) => userId.isNotEmpty && userId == authorId;

  bool isLikedBy(String userId) =>
      userId.isNotEmpty && likedBy.contains(userId);

  DiscussionMessage copyWith({
    String? text,
    int? rating,
    List<String>? photoUrls,
    List<String>? likedBy,
  }) => DiscussionMessage(
    id: id,
    discussionId: discussionId,
    authorId: authorId,
    authorName: authorName,
    text: text ?? this.text,
    rating: rating ?? this.rating,
    photoUrls: photoUrls ?? this.photoUrls,
    likedBy: likedBy ?? this.likedBy,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'discussionId': discussionId,
    'authorId': authorId,
    'authorName': authorName,
    'text': text,
    'rating': rating,
    'photoUrls': photoUrls,
    'likedBy': likedBy,
    'createdAt': createdAt,
  };

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) =>
      DiscussionMessage(
        id: '${json['id'] ?? ''}',
        discussionId: '${json['discussionId'] ?? ''}',
        authorId: '${json['authorId'] ?? ''}',
        authorName: '${json['authorName'] ?? ''}',
        text: '${json['text'] ?? ''}',
        rating: _toIntOrNull(json['rating']),
        photoUrls: _stringList(json['photoUrls']),
        likedBy: _stringList(json['likedBy']),
        createdAt: '${json['createdAt'] ?? ''}',
      );

  static int? _toIntOrNull(Object? value) {
    if (value is num) {
      final int result = value.toInt();
      return result >= 1 && result <= 5 ? result : null;
    }
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((Object? item) => '$item')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
