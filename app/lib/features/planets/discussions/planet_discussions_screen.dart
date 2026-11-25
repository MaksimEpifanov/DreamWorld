import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/planet_discussion.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import '../../../data/services/moderation_service.dart';

/// Список обсуждений планеты на темы, которые придумывают участники.
class PlanetDiscussionsScreen extends ConsumerStatefulWidget {
  const PlanetDiscussionsScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<PlanetDiscussionsScreen> createState() =>
      _PlanetDiscussionsScreenState();
}

class _PlanetDiscussionsScreenState
    extends ConsumerState<PlanetDiscussionsScreen> {
  String _topicFilter = 'все';

  @override
  Widget build(BuildContext context) {
    final Planet? planet = ref.watch(planetByIdProvider(widget.planetId));
    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Обсуждения',
          leading: BackButton(
            onPressed: () => context.go('/main/planet/${widget.planetId}'),
          ),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final AsyncValue<List<PlanetDiscussion>> async = ref.watch(
      planetDiscussionsProvider(planet.id),
    );
    final List<PlanetDiscussion> all =
        async.valueOrNull ?? const <PlanetDiscussion>[];
    final Set<String> topics = <String>{
      for (final PlanetDiscussion item in all)
        if (item.topic.trim().isNotEmpty) item.topic.trim(),
    };
    final List<String> topicFilters = topics.toList(growable: false)..sort();
    final List<PlanetDiscussion> discussions = _topicFilter == 'все'
        ? all
        : all
              .where(
                (PlanetDiscussion item) => item.topic.trim() == _topicFilter,
              )
              .toList(growable: false);
    final String viewerId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Обсуждения · ${planet.displayName}',
        leading: BackButton(
          onPressed: () => context.go('/main/planet/${planet.id}'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              _Intro(planet: planet, count: all.length),
              const SizedBox(height: AppSpacing.md),
              NeonButton(
                key: const ValueKey<String>('create-discussion-button'),
                label: 'Создать обсуждение',
                icon: Icons.add_comment_outlined,
                color: planet.secondary,
                expanded: true,
                onPressed: () => _createDiscussion(planet),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  ChoiceChip(
                    key: const ValueKey<String>('discussion-filter-all'),
                    label: const Text('Все темы'),
                    selected: _topicFilter == 'все',
                    onSelected: (bool selected) {
                      if (selected) setState(() => _topicFilter = 'все');
                    },
                  ),
                  for (final String topic in topicFilters)
                    ChoiceChip(
                      key: ValueKey<String>('discussion-filter-$topic'),
                      label: Text(topic),
                      selected: _topicFilter == topic,
                      onSelected: (bool selected) {
                        if (selected) setState(() => _topicFilter = topic);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (async.isLoading && all.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (discussions.isEmpty)
                _EmptyDiscussions(planet: planet)
              else
                for (final PlanetDiscussion discussion in discussions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _DiscussionCard(
                      discussion: discussion,
                      planet: planet,
                      canDelete: discussion.isAuthor(viewerId),
                      onOpen: () => context.go(
                        '/main/planet/${planet.id}/discussions/${discussion.id}',
                      ),
                      onDelete: () => _confirmDelete(planet, discussion),
                    ),
                  ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createDiscussion(Planet planet) async {
    final _DiscussionDraft? draft =
        await showModalBottomSheet<_DiscussionDraft>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext sheetContext) =>
              _DiscussionComposerSheet(planet: planet),
        );
    if (draft == null || !mounted) return;

    final String text = '${draft.title} ${draft.description}';
    final ModerationVerdict verdict = const MockModerationService().checkText(
      text,
    );
    if (verdict.flagged) {
      _showError('Обсуждение заблокировано: ${verdict.message}');
      return;
    }

    final String name =
        ref.read(currentProfileProvider).valueOrNull?.name.trim() ?? '';
    final PlanetDiscussion discussion = PlanetDiscussion(
      id: const Uuid().v4(),
      planetId: planet.id,
      title: draft.title,
      description: draft.description,
      topic: draft.topic,
      authorId: ref.read(currentUserIdProvider),
      authorName: name.isEmpty ? 'Вы' : name,
      createdAt: DateTime.now().toIso8601String(),
    );
    try {
      await ref
          .read(planetDiscussionRepositoryProvider)
          .addDiscussion(planet, discussion);
    } catch (_) {
      _showError('Не удалось создать обсуждение. Попробуйте ещё раз.');
      return;
    }
    if (!mounted) return;
    context.go('/main/planet/${planet.id}/discussions/${discussion.id}');
  }

  Future<void> _confirmDelete(
    Planet planet,
    PlanetDiscussion discussion,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Удалить обсуждение?'),
        content: Text(
          '«${discussion.title}» исчезнет у всех участников планеты.',
        ),
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
    try {
      await ref
          .read(planetDiscussionRepositoryProvider)
          .removeDiscussion(planet, discussion.id);
    } catch (_) {
      _showError('Не удалось удалить обсуждение. Попробуйте ещё раз.');
      return;
    }
    if (mounted) setState(() => _topicFilter = 'все');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.planet, required this.count});

  final Planet planet;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.forum_outlined, size: 22, color: planet.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                count == 0
                    ? 'Пока нет обсуждений — создайте первое.'
                    : '$count ${_plural(count)} планеты',
                style: AppTextStyles.bodyBold(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Придумайте свою тему в тематике планеты — участники будут '
          'писать отзывы и добавлять свои фото.',
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  static String _plural(int count) {
    final int mod10 = count % 10;
    final int mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'обсуждение';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'обсуждения';
    }
    return 'обсуждений';
  }
}

class _EmptyDiscussions extends StatelessWidget {
  const _EmptyDiscussions({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: <Widget>[
          Icon(Icons.chat_bubble_outline, size: 40, color: planet.accent),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Здесь появятся обсуждения участников',
            style: AppTextStyles.title(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Нажмите «Создать обсуждение» и придумайте тему.',
            style: AppTextStyles.caption(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  const _DiscussionCard({
    required this.discussion,
    required this.planet,
    required this.canDelete,
    required this.onOpen,
    required this.onDelete,
  });

  final PlanetDiscussion discussion;
  final Planet planet;
  final bool canDelete;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(discussion.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      discussion.title,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (discussion.topic.isNotEmpty)
                      Text(
                        discussion.topic,
                        style: AppTextStyles.caption(color: planet.accent),
                      ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  key: ValueKey<String>('delete-discussion-${discussion.id}'),
                  tooltip: 'Удалить обсуждение',
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textMuted,
                  onPressed: onDelete,
                ),
            ],
          ),
          if (discussion.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              discussion.description,
              style: AppTextStyles.body(color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(Icons.chat_bubble_outline, size: 15, color: planet.accent),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${discussion.messagesCount}',
                style: AppTextStyles.label(color: planet.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${discussion.authorName} · ${_formatDate(discussion.lastActivityAt)}',
                  style: AppTextStyles.caption(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscussionDraft {
  const _DiscussionDraft({
    required this.title,
    required this.description,
    required this.topic,
  });

  final String title;
  final String description;
  final String topic;
}

class _DiscussionComposerSheet extends StatefulWidget {
  const _DiscussionComposerSheet({required this.planet});

  final Planet planet;

  @override
  State<_DiscussionComposerSheet> createState() =>
      _DiscussionComposerSheetState();
}

class _DiscussionComposerSheetState extends State<_DiscussionComposerSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final String title = _titleController.text.trim();
    final String topic = _topicController.text.trim();
    if (title.isEmpty || topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите название и тему обсуждения')),
      );
      return;
    }
    Navigator.of(context).pop(
      _DiscussionDraft(
        title: title,
        description: _descriptionController.text.trim(),
        topic: topic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Новое обсуждение', style: AppTextStyles.title()),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const ValueKey<String>('discussion-title-field'),
              controller: _titleController,
              style: AppTextStyles.body(),
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например, «Парк Горького» или «Фильм „Прибытие“»',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const ValueKey<String>('discussion-topic-field'),
              controller: _topicController,
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                labelText: 'Тема обсуждения',
                hintText: 'Например, ${_topicHint(widget.planet)}',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const ValueKey<String>('discussion-description-field'),
              controller: _descriptionController,
              style: AppTextStyles.body(),
              decoration: const InputDecoration(
                labelText: 'О чём обсуждение',
                hintText: 'Коротко опишите предмет обсуждения',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            NeonButton(
              label: 'Создать обсуждение',
              icon: Icons.check_rounded,
              color: widget.planet.accent,
              expanded: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

String _topicHint(Planet planet) {
  final List<String> keywords = planet.keywords
      .where((String keyword) => keyword.trim().isNotEmpty)
      .toList(growable: false);
  if (keywords.isEmpty) return planet.shortName;
  return keywords.take(2).join(', ');
}

String _formatDate(String iso) {
  final DateTime? date = DateTime.tryParse(iso);
  if (date == null) return '';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}
