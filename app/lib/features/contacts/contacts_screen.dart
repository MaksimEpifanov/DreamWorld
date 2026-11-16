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
import '../safety/widgets/report_sheet.dart';
import 'contacts_controller.dart';

/// Экран контактов: свой ID для поиска и список знакомых.
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  Future<void> _copyId(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Ваш ID скопирован')));
  }

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    String otherUserId,
  ) async {
    try {
      final Conversation conversation = await ref
          .read(chatRepositoryProvider)
          .getOrCreateConversation(otherUserId);
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String userCode = UserCode.fromUserId(
      ref.watch(currentUserIdProvider),
    );
    final List<String> contactIds = ref.watch(contactsProvider);
    final Map<String, Profile> profiles = <String, Profile>{
      for (final Profile profile
          in ref.watch(discoveryProfilesProvider).asData?.value ??
              const <Profile>[])
        profile.id: profile,
    };
    final List<Profile> contacts = <Profile>[
      for (final String id in contactIds)
        if (profiles[id] != null) profiles[id]!,
    ];

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Контакты',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.badge_outlined,
                          size: 40,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Ваш ID', style: AppTextStyles.title()),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Поделитесь им, чтобы вас нашли в поиске.',
                                style: AppTextStyles.caption(),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              userCode,
                              style: AppTextStyles.bodyBold(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Скопировать ID',
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            onPressed: () => _copyId(context, userCode),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NeonButton(
                      label: 'Найти по ID',
                      icon: Icons.search_rounded,
                      expanded: true,
                      onPressed: () => context.go('/search'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Text('Мои контакты', style: AppTextStyles.title()),
                  const Spacer(),
                  Text('${contacts.length}', style: AppTextStyles.caption()),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (contacts.isEmpty)
                _EmptyContacts()
              else
                for (int i = 0; i < contacts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ContactTile(
                      profile: contacts[i],
                      index: i,
                      onOpenChat: () => _openChat(context, ref, contacts[i].id),
                      onRemove: () => ref
                          .read(contactsProvider.notifier)
                          .remove(contacts[i].id),
                      onReport: () => showReportSheet(
                        context,
                        ref,
                        targetId: contacts[i].id,
                        targetName: contacts[i].name,
                        target: ReportTarget.user,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Icon(Icons.people_alt_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Пока нет контактов', style: AppTextStyles.title()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Найдите знакомых по ID — они появятся здесь.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.profile,
    required this.index,
    required this.onOpenChat,
    required this.onRemove,
    required this.onReport,
  });

  final Profile profile;
  final int index;
  final VoidCallback onOpenChat;
  final VoidCallback onRemove;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onOpenChat,
            child: Row(
              children: <Widget>[
                AuraAvatar(
                  photoUrl: profile.photoUrl,
                  size: 52,
                  fallbackText: profile.name,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(profile.name, style: AppTextStyles.bodyBold()),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        <String>[
                          if ((profile.city ?? '').isNotEmpty) profile.city!,
                          if (profile.interestNames.isNotEmpty)
                            profile.interestNames.take(2).join(', '),
                        ].join(' • '),
                        style: AppTextStyles.caption(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Написать',
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: onOpenChat,
                ),
                IconButton(
                  tooltip: 'Пожаловаться',
                  icon: const Icon(Icons.flag_outlined),
                  color: AppColors.textMuted,
                  onPressed: onReport,
                ),
                IconButton(
                  tooltip: 'Удалить',
                  icon: const Icon(Icons.person_remove_outlined),
                  color: AppColors.error,
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
