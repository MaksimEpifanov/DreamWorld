/// Отзыв пользователя о сайте и приложении DreamWorld.
///
/// Отзывы общие: написанный одним пользователем отзыв видят остальные.
/// В рабочей версии они хранятся в Firestore (коллекция `reviews`).
class Review {
  const Review({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.rating = 5,
  });

  final String id;

  /// Идентификатор автора отзыва.
  final String authorId;

  /// Имя автора на момент написания отзыва.
  final String authorName;

  /// Текст отзыва.
  final String text;

  /// Оценка от 1 до 5.
  final int rating;

  /// Время создания в формате ISO-8601 (сортируется как дата).
  final String createdAt;

  DateTime? get createdDate => DateTime.tryParse(createdAt);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'authorId': authorId,
    'authorName': authorName,
    'text': text,
    'rating': rating,
    'createdAt': createdAt,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: '${json['id'] ?? ''}',
    authorId: '${json['authorId'] ?? ''}',
    authorName: '${json['authorName'] ?? ''}',
    text: '${json['text'] ?? ''}',
    rating: _clampRating(json['rating']),
    createdAt: '${json['createdAt'] ?? ''}',
  );

  static int _clampRating(Object? value) {
    final int rating = value is num
        ? value.toInt()
        : int.tryParse('$value') ?? 5;
    if (rating < 1) return 1;
    if (rating > 5) return 5;
    return rating;
  }
}
