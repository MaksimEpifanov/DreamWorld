/// Новость ленты планеты (генерируется ИИ-сервисом).
class PlanetNewsItem {
  const PlanetNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.emoji,
    required this.sourceName,
    required this.tag,
    required this.publishedAt,
    required this.likes,
    this.sourceUrl = '',
  });

  final String id;
  final String title;
  final String summary;

  /// Эмодзи-иллюстрация новости.
  final String emoji;

  /// Источник / автор новости.
  final String sourceName;

  /// Тематический тег новости.
  final String tag;

  final DateTime publishedAt;
  final int likes;
  final String sourceUrl;

  factory PlanetNewsItem.fromJson(Map<String, dynamic> json) {
    return PlanetNewsItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      emoji: (json['emoji'] as String?) ?? '📰',
      sourceName: (json['sourceName'] as String?) ?? '',
      tag: (json['tag'] as String?) ?? 'Новости',
      publishedAt: DateTime.tryParse((json['publishedAt'] as String?) ?? '') ??
          DateTime.now(),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      sourceUrl: (json['sourceUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'summary': summary,
    'emoji': emoji,
    'sourceName': sourceName,
    'tag': tag,
    'publishedAt': publishedAt.toUtc().toIso8601String(),
    'likes': likes,
    'sourceUrl': sourceUrl,
  };
}
