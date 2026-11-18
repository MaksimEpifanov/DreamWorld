import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/planet_event.dart';
import '../../../data/models/profile.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';

/// События планеты: встречи, поездки и сборы, которые создают участники.
///
/// Любой вошедший может создать своё событие (например, «Рыбалка на Волгу»),
/// а остальные — подать заявку на участие. Организатор подтверждает заявки.
class PlanetEventsScreen extends ConsumerStatefulWidget {
  const PlanetEventsScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<PlanetEventsScreen> createState() => _PlanetEventsScreenState();
}

class _PlanetEventsScreenState extends ConsumerState<PlanetEventsScreen> {
  @override
  Widget build(BuildContext context) {
    final Planet? planet = ref.watch(planetByIdProvider(widget.planetId));

    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'События',
          leading: BackButton(
            onPressed: () => context.go('/main/planet/${widget.planetId}'),
          ),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final AsyncValue<List<PlanetEvent>> eventsAsync = ref.watch(
      planetEventsProvider(planet.id),
    );
    final List<PlanetEvent> events =
        eventsAsync.valueOrNull ?? const <PlanetEvent>[];
    final String viewerId = ref.watch(currentUserIdProvider);
    final List<Profile> profiles =
        ref.watch(communityProfilesProvider).valueOrNull ?? const <Profile>[];
    final Map<String, String> names = <String, String>{
      for (final Profile profile in profiles)
        if (profile.name.trim().isNotEmpty) profile.id: profile.name.trim(),
    };

    return Scaffold(
      appBar: NeonAppBar(
        title: 'События · ${planet.displayName}',
        leading: BackButton(
          onPressed: () => context.go('/main/planet/${planet.id}'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              _EventsIntro(planet: planet, count: events.length),
              const SizedBox(height: AppSpacing.md),
              NeonButton(
                label: 'Создать событие',
                icon: Icons.event_available_outlined,
                color: planet.secondary,
                expanded: true,
                onPressed: () => _createEvent(planet),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (eventsAsync.isLoading && events.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (events.isEmpty)
                _EmptyEvents(planet: planet)
              else
                for (final PlanetEvent event in events)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _EventCard(
                      event: event,
                      planet: planet,
                      viewerId: viewerId,
                      nameOf: (String id) => names[id] ?? 'Участник',
                      onApply: () => _run(
                        () => ref
                            .read(planetEventRepositoryProvider)
                            .apply(planet, event.id),
                      ),
                      onWithdraw: () => _run(
                        () => ref
                            .read(planetEventRepositoryProvider)
                            .withdraw(planet, event.id),
                      ),
                      onApprove: (String userId) => _run(
                        () => ref
                            .read(planetEventRepositoryProvider)
                            .approve(planet, event.id, userId),
                      ),
                      onDecline: (String userId) => _run(
                        () => ref
                            .read(planetEventRepositoryProvider)
                            .decline(planet, event.id, userId),
                      ),
                      onDelete: () => _confirmDelete(planet, event),
                    ),
                  ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  /// Выполняет действие и показывает сообщение об ошибке, если оно не удалось.
  Future<bool> _run(
    Future<void> Function() action, {
    String error = 'Не удалось выполнить действие. Попробуйте ещё раз.',
  }) async {
    try {
      await action();
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(error)));
      return false;
    }
  }

  Future<void> _createEvent(Planet planet) async {
    final _EventDraft? draft = await showModalBottomSheet<_EventDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => _EventComposerSheet(planet: planet),
    );
    if (draft == null || !mounted) return;

    final String name =
        ref.read(currentProfileProvider).valueOrNull?.name.trim() ?? '';
    final PlanetEvent event = PlanetEvent(
      id: const Uuid().v4(),
      planetId: planet.id,
      title: draft.title,
      description: draft.description,
      emoji: draft.emoji,
      date: draft.date,
      place: draft.place,
      seats: draft.seats,
      authorId: ref.read(currentUserIdProvider),
      authorName: name.isEmpty ? 'Вы' : name,
      createdAt: DateTime.now().toIso8601String(),
    );
    final bool ok = await _run(
      () => ref.read(planetEventRepositoryProvider).addEvent(planet, event),
      error: 'Не удалось создать событие. Попробуйте ещё раз.',
    );
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Событие создано')));
  }

  Future<void> _confirmDelete(Planet planet, PlanetEvent event) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Удалить событие?'),
        content: Text('«${event.title}» исчезнет у всех участников планеты.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => ref.read(planetEventRepositoryProvider).removeEvent(planet, event.id),
      error: 'Не удалось удалить событие. Попробуйте ещё раз.',
    );
  }
}

/// Короткая шапка экрана событий.
class _EventsIntro extends StatelessWidget {
  const _EventsIntro({required this.planet, required this.count});

  final Planet planet;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.event_outlined, size: 22, color: planet.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                count == 0
                    ? 'Пока нет событий — создайте первое.'
                    : '$count ${_plural(count)} планеты',
                style: AppTextStyles.bodyBold(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Договоритесь о встрече, поездке или сборе: укажите дату, место и '
          'сколько человек нужно. Остальные подадут заявки.',
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  static String _plural(int count) {
    final int mod10 = count % 10;
    final int mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'событие';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'события';
    }
    return 'событий';
  }
}

/// Карточка одного события с заявками и действиями.
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.planet,
    required this.viewerId,
    required this.nameOf,
    required this.onApply,
    required this.onWithdraw,
    required this.onApprove,
    required this.onDecline,
    required this.onDelete,
  });

  final PlanetEvent event;
  final Planet planet;
  final String viewerId;
  final String Function(String id) nameOf;
  final VoidCallback onApply;
  final VoidCallback onWithdraw;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onDecline;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isAuthor = event.isAuthor(viewerId);
    final bool isParticipant = event.isParticipant(viewerId);
    final bool applied = event.hasApplied(viewerId);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(event.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(event.title, style: AppTextStyles.bodyBold()),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        if (event.date.isNotEmpty)
                          _MetaChip(
                            icon: Icons.event_outlined,
                            label: _formatDate(event.date),
                            color: planet.accent,
                          ),
                        if (event.place.isNotEmpty)
                          _MetaChip(
                            icon: Icons.place_outlined,
                            label: event.place,
                            color: planet.secondary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (event.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              event.description,
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  'Организатор: ${event.authorName.isEmpty ? 'участник' : event.authorName}',
                  style: AppTextStyles.caption(),
                ),
              ),
              _SeatsChip(event: event, planet: planet),
            ],
          ),
          if (event.participantIds.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _PeopleList(
              title: 'Участники (${event.participantIds.length})',
              ids: event.participantIds,
              nameOf: nameOf,
              trailing: isAuthor
                  ? (String id) => IconButton(
                      tooltip: 'Убрать участника',
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onDecline(id),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                      ),
                    )
                  : null,
            ),
          ],
          if (isAuthor) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Заявки (${event.applicantIds.length})',
              style: AppTextStyles.label(color: planet.accent),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (event.applicantIds.isEmpty)
              Text(
                'Пока нет заявок.',
                style: AppTextStyles.caption(color: AppColors.textMuted),
              )
            else
              for (final String id in event.applicantIds)
                _PersonRow(
                  name: nameOf(id),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Принять',
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onApprove(id),
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Отклонить',
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onDecline(id),
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _EventActions(
            event: event,
            planet: planet,
            isAuthor: isAuthor,
            isParticipant: isParticipant,
            applied: applied,
            onApply: onApply,
            onWithdraw: onWithdraw,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Кнопки и статусы события для текущего пользователя.
class _EventActions extends StatelessWidget {
  const _EventActions({
    required this.event,
    required this.planet,
    required this.isAuthor,
    required this.isParticipant,
    required this.applied,
    required this.onApply,
    required this.onWithdraw,
    required this.onDelete,
  });

  final PlanetEvent event;
  final Planet planet;
  final bool isAuthor;
  final bool isParticipant;
  final bool applied;
  final VoidCallback onApply;
  final VoidCallback onWithdraw;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isAuthor) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Удалить событие'),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
        ),
      );
    }
    if (isParticipant) {
      return _StatusChip(
        icon: Icons.check_circle_outline_rounded,
        label: 'Вы записаны',
        color: AppColors.success,
      );
    }
    if (applied) {
      return Row(
        children: <Widget>[
          const _StatusChip(
            icon: Icons.hourglass_top_rounded,
            label: 'Заявка отправлена',
            color: AppColors.warning,
          ),
          const Spacer(),
          TextButton(onPressed: onWithdraw, child: const Text('Отменить')),
        ],
      );
    }
    if (event.isFull) {
      return const _StatusChip(
        icon: Icons.lock_outline_rounded,
        label: 'Набор закрыт',
        color: AppColors.textMuted,
      );
    }
    return NeonButton(
      label: 'Подать заявку',
      icon: Icons.how_to_reg_outlined,
      color: planet.accent,
      expanded: true,
      onPressed: onApply,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.label(color: color)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: AppTextStyles.label(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SeatsChip extends StatelessWidget {
  const _SeatsChip({required this.event, required this.planet});

  final PlanetEvent event;
  final Planet planet;

  @override
  Widget build(BuildContext context) {
    final String label = event.hasLimit
        ? '${event.taken} из ${event.seats}'
        : '${event.taken}';
    final Color color = event.isFull ? AppColors.warning : planet.accent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.groups_outlined, size: 14, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: AppTextStyles.label(color: color)),
        ],
      ),
    );
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.title,
    required this.ids,
    required this.nameOf,
    this.trailing,
  });

  final String title;
  final List<String> ids;
  final String Function(String id) nameOf;
  final Widget Function(String id)? trailing;

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.label()),
        const SizedBox(height: AppSpacing.xxs),
        for (final String id in ids)
          _PersonRow(name: nameOf(id), trailing: trailing?.call(id)),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.name, this.trailing});

  final String name;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AuraAvatar(size: 28, fallbackText: name),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.body(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: <Widget>[
          Icon(Icons.event_outlined, size: 40, color: planet.accent),
          const SizedBox(height: AppSpacing.sm),
          Text('Событий пока нет', style: AppTextStyles.bodyBold()),
          const SizedBox(height: 4),
          Text(
            'Создайте своё событие — например, поездку или встречу, — и '
            'участники планеты смогут подать заявку.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Черновик события, который возвращает форма создания.
class _EventDraft {
  const _EventDraft({
    required this.title,
    required this.description,
    required this.emoji,
    required this.date,
    required this.place,
    required this.seats,
  });

  final String title;
  final String description;
  final String emoji;
  final String date;
  final String place;
  final int seats;
}

/// Форма создания события.
class _EventComposerSheet extends StatefulWidget {
  const _EventComposerSheet({required this.planet});

  final Planet planet;

  @override
  State<_EventComposerSheet> createState() => _EventComposerSheetState();
}

class _EventComposerSheetState extends State<_EventComposerSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _place = TextEditingController();
  final TextEditingController _seats = TextEditingController();

  static const List<String> _emojis = <String>[
    '📅',
    '🎣',
    '🏕️',
    '🚗',
    '🎉',
    '⚽',
    '🎸',
    '📸',
    '🍕',
    '🚴',
  ];

  String _emoji = '📅';
  DateTime? _date;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _place.dispose();
    _seats.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final String title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      _EventDraft(
        title: title,
        description: _description.text.trim(),
        emoji: _emoji,
        date: _date == null ? '' : _isoDate(_date!),
        place: _place.text.trim(),
        seats: int.tryParse(_seats.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.planet.accent;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Новое событие', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Например: «Рыбалка на Волгу», нужно 2 человека, выезд 13 '
                  'августа из Дубны.',
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    for (final String emoji in _emojis)
                      InkWell(
                        borderRadius: AppRadius.mdAll,
                        onTap: () => setState(() => _emoji = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: _emoji == emoji
                                ? accent.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(
                              color: _emoji == emoji
                                  ? accent
                                  : AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _title,
                  autofocus: true,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Название события',
                    hintText: 'Рыбалка на Волгу',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 400,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    hintText: 'Что за событие и что взять с собой',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: Text(
                          _date == null
                              ? 'Дата не выбрана'
                              : _formatDate(_isoDate(_date!)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _seats,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Нужно чел.',
                          hintText: '0 — без лимита',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _place,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Место или точка сбора',
                    hintText: 'Выезд из Дубны',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                NeonButton(
                  label: 'Создать событие',
                  icon: Icons.check_rounded,
                  expanded: true,
                  color: accent,
                  onPressed: _title.text.trim().isEmpty ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _isoDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

String _formatDate(String iso) {
  final DateTime? date = DateTime.tryParse(iso);
  if (date == null) return iso;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}
