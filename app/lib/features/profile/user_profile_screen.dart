import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import '../../data/services/user_code.dart';
import '../contacts/contacts_controller.dart';
import '../safety/widgets/report_sheet.dart';

/// Экран просмотра анкеты другого пользователя.
///
/// Открывается из контактов и из результатов поиска по ID. Позволяет
/// написать человеку и добавить его в контакты (или убрать).
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  /// Идентификатор пользователя, чью анкету показываем.
  final String userId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main');
    }
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    try {
      final Conversation conversation = await ref
          .read(chatRepositoryProvider)
          .getOrCreateConversation(userId);
      if (context.mounted) context.push('/chat/${conversation.id}');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть чат. Попробуйте ещё раз.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Profile?> profile = ref.watch(userProfileProvider(userId));
    final bool inContacts = ref.watch(contactsProvider).contains(userId);
    final bool hasIncoming = ref
        .watch(incomingContactRequestIdsProvider)
        .contains(userId);
    final bool hasOutgoing = ref
        .watch(outgoingContactRequestIdsProvider)
        .contains(userId);

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Профиль',
        leading: BackButton(onPressed: () => _back(context)),
        actions: <Widget>[
          IconButton(
            tooltip: 'Пожаловаться',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => showReportSheet(
              context,
              ref,
              targetId: userId,
              targetName: profile.valueOrNull?.name ?? 'Пользователь',
              target: ReportTarget.user,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: profile.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) =>
                const _NotFound(),
            data: (Profile? value) {
              if (value == null) return const _NotFound();
              return _ProfileBody(
                profile: value,
                inContacts: inContacts,
                hasIncoming: hasIncoming,
                hasOutgoing: hasOutgoing,
                onOpenChat: () => _openChat(context, ref),
                onContactPressed: () => _handleContact(context, ref, value),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleContact(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final bool inContacts = ref.read(contactsProvider).contains(profile.id);
    final bool hasIncoming = ref
        .read(incomingContactRequestIdsProvider)
        .contains(profile.id);
    final bool hasOutgoing = ref
        .read(outgoingContactRequestIdsProvider)
        .contains(profile.id);
    final ContactsController controller = ref.read(contactsControllerProvider);
    final String message;
    try {
      if (inContacts) {
        await controller.remove(profile.id);
        message = '${profile.name} убран(а) из контактов';
      } else if (hasIncoming) {
        await controller.acceptRequest(profile.id);
        message = 'Запрос принят — ${profile.name} в контактах';
      } else if (hasOutgoing) {
        await controller.cancelRequest(profile.id);
        message = 'Запрос отменён';
      } else {
        await controller.sendRequest(profile.id);
        message = 'Запрос отправлен: ${profile.name}';
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось обновить контакты. Попробуйте ещё раз.'),
          ),
        );
    }
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.inContacts,
    required this.hasIncoming,
    required this.hasOutgoing,
    required this.onOpenChat,
    required this.onContactPressed,
  });

  final Profile profile;
  final bool inContacts;
  final bool hasIncoming;
  final bool hasOutgoing;
  final VoidCallback onOpenChat;
  final VoidCallback onContactPressed;

  @override
  Widget build(BuildContext context) {
    final List<String> interests = <String>[
      ...profile.interestNames,
      ...profile.detailedInterests,
    ];
    final (String, IconData) contactButton = inContacts
        ? ('В контактах', Icons.check_circle_outline)
        : hasIncoming
        ? ('Принять запрос', Icons.person_add_alt_1_rounded)
        : hasOutgoing
        ? ('Запрос отправлен', Icons.hourglass_top_rounded)
        : ('В контакты', Icons.person_add_alt_1_rounded);

    return ListView(
      padding: AppSpacing.page,
      children: <Widget>[
        _Header(profile: profile)
            .animate()
            .fadeIn(duration: 360.ms)
            .slideY(begin: 0.08),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: NeonButton(
                label: 'Написать',
                icon: Icons.chat_bubble_outline_rounded,
                expanded: true,
                onPressed: onOpenChat,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: NeonButton(
                label: contactButton.$1,
                icon: contactButton.$2,
                variant: NeonButtonVariant.outlined,
                expanded: true,
                onPressed: onContactPressed,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if ((profile.bio ?? '').trim().isNotEmpty)
          _Section(
            title: 'О себе',
            icon: Icons.notes_rounded,
            child: Text(
              profile.bio!,
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ),
        if (interests.isNotEmpty)
          _Section(
            title: 'Интересы',
            icon: Icons.interests_outlined,
            child: _Chips(items: interests),
          ),
        if (profile.goals.isNotEmpty)
          _Section(
            title: 'Цели знакомства',
            icon: Icons.flag_outlined,
            child: _Chips(items: profile.goals),
          ),
        if (profile.values.isNotEmpty)
          _Section(
            title: 'Ценности',
            icon: Icons.favorite_outline_rounded,
            child: _Chips(items: profile.values),
          ),
        if (profile.languages.isNotEmpty)
          _Section(
            title: 'Языки',
            icon: Icons.translate_rounded,
            child: _Chips(items: profile.languages),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final Profile profile;

  Future<void> _copyId(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('ID скопирован')));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String code = UserCode.fromUserId(profile.id);
    final List<String> subtitle = <String>[
      '${profile.age} лет',
      if ((profile.city ?? '').isNotEmpty) profile.city!,
    ];

    return GlassCard(
      child: Column(
        children: <Widget>[
          AuraAvatar(
            photoUrl: profile.photoUrl,
            size: 104,
            fallbackText: profile.name,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline(),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle.join(' • '),
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    code,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Скопировать ID',
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () => _copyId(context, code),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.title()),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final String item in items)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Text(item, style: AppTextStyles.label()),
          ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: scheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Профиль недоступен', style: AppTextStyles.title()),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Пользователь не найден или удалил анкету.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
