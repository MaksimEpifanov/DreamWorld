import 'spot_report_repository.dart';

/// Счётчик жалоб на авторов заметок в памяти (демо-режим без Firebase).
class MockSpotReportRepository implements SpotReportRepository {
  MockSpotReportRepository({
    this.currentUserId = '',
    Map<String, Set<String>>? store,
  }) : _reporters = store ?? <String, Set<String>>{};

  final String currentUserId;

  /// Общее хранилище (для тестов можно передать, чтобы делиться между
  /// экземплярами с разными пользователями).
  final Map<String, Set<String>> _reporters;

  @override
  Future<int> registerReport({
    required String authorId,
    required String authorName,
  }) async {
    if (authorId.isEmpty) return 0;
    final Set<String> reporters = _reporters.putIfAbsent(
      authorId,
      () => <String>{},
    );
    if (currentUserId.isNotEmpty) reporters.add(currentUserId);
    return reporters.length;
  }
}
