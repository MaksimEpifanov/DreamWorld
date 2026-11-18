import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/safety.dart';
import '../../data/providers/app_providers.dart';

/// Состояние системы безопасности: поданные жалобы и заблокированные.
class SafetyState {
  const SafetyState({this.reports = const <Report>[], this.blocked = const <BlockedUser>[]});

  final List<Report> reports;
  final List<BlockedUser> blocked;

  bool isBlocked(String userId) =>
      blocked.any((BlockedUser b) => b.userId == userId);

  SafetyState copyWith({List<Report>? reports, List<BlockedUser>? blocked}) {
    return SafetyState(
      reports: reports ?? this.reports,
      blocked: blocked ?? this.blocked,
    );
  }
}

/// Контроллер безопасности: жалобы, блокировки и демо-модерация.
///
/// Логика намеренно «демонстрационная»: жалобы с высокой серьёзностью
/// мгновенно скрывают объект и получают статус «Принята», остальные —
/// «На проверке». Реальный конвейер модераторов подключается позже.
///
/// Список заблокированных сохраняется локально ([storageKey]), чтобы заметки
/// нарушителя оставались скрытыми и после перезапуска приложения.
class SafetyController extends StateNotifier<SafetyState> {
  SafetyController({this.storageKey = ''}) : super(const SafetyState()) {
    if (storageKey.isNotEmpty) {
      _load();
    }
  }

  final Random _random = Random();

  /// Ключ локального хранилища; пустой — не сохранять (например, в тестах).
  final String storageKey;

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(storageKey);
      if (raw == null || raw.isEmpty || !mounted) return;
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final List<BlockedUser> blocked = <BlockedUser>[
        for (final Object? item in decoded)
          if (item is Map) _blockedFromJson(item.cast<String, dynamic>()),
      ];
      if (blocked.isEmpty || !mounted) return;
      state = state.copyWith(blocked: blocked);
    } catch (_) {
      // Локальное хранилище недоступно — работаем без сохранения.
    }
  }

  Future<void> _persist() async {
    if (storageKey.isEmpty) return;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        storageKey,
        jsonEncode(
          state.blocked.map(_blockedToJson).toList(growable: false),
        ),
      );
    } catch (_) {
      // Не критично: блокировки применятся только на текущую сессию.
    }
  }

  Map<String, dynamic> _blockedToJson(BlockedUser user) => <String, dynamic>{
    'userId': user.userId,
    'name': user.name,
    'blockedAt': user.blockedAt.toIso8601String(),
    if (user.reason != null) 'reason': user.reason,
  };

  BlockedUser _blockedFromJson(Map<String, dynamic> json) => BlockedUser(
    userId: '${json['userId'] ?? ''}',
    name: '${json['name'] ?? ''}',
    blockedAt: DateTime.tryParse('${json['blockedAt'] ?? ''}') ?? DateTime.now(),
    reason: json['reason'] is String ? json['reason'] as String : null,
  );

  /// Подаёт жалобу. Возвращает созданную жалобу с итоговым статусом.
  Report submitReport({
    required String targetId,
    required String targetName,
    required ReportTarget target,
    required ReportReason reason,
    String comment = '',
  }) {
    final bool autoAction = reason.severity >= 3;
    final Report report = Report(
      id: 'r_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      targetId: targetId,
      targetName: targetName,
      target: target,
      reason: reason,
      comment: comment,
      createdAt: DateTime.now(),
      status: autoAction ? ReportStatus.actionTaken : ReportStatus.underReview,
      autoHidden: autoAction,
    );
    state = state.copyWith(
      reports: <Report>[report, ...state.reports],
    );
    return report;
  }

  /// Меняет статус жалобы (имитация решения модератора).
  void updateStatus(String reportId, ReportStatus status) {
    state = state.copyWith(
      reports: state.reports
          .map(
            (Report r) => r.id == reportId ? r.copyWith(status: status) : r,
          )
          .toList(growable: false),
    );
  }

  /// Блокирует пользователя.
  void block({
    required String userId,
    required String name,
    String? reason,
  }) {
    if (state.isBlocked(userId)) return;
    state = state.copyWith(
      blocked: <BlockedUser>[
        ...state.blocked,
        BlockedUser(
          userId: userId,
          name: name,
          blockedAt: DateTime.now(),
          reason: reason,
        ),
      ],
    );
    _persist();
  }

  /// Снимает блокировку.
  void unblock(String userId) {
    state = state.copyWith(
      blocked: state.blocked
          .where((BlockedUser b) => b.userId != userId)
          .toList(growable: false),
    );
    _persist();
  }
}

/// Провайдер безопасности. Блокировки хранятся локально для текущего пользователя.
final StateNotifierProvider<SafetyController, SafetyState> safetyProvider =
    StateNotifierProvider<SafetyController, SafetyState>(
      (Ref ref) => SafetyController(
        storageKey: 'blocked_users_${ref.watch(currentUserIdProvider)}',
      ),
    );
