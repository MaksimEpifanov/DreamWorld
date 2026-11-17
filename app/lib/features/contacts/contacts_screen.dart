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

  Future<void> _acceptRequest(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    try {
      await ref
          .read(contactsControllerProvider)
          .acceptRequest(profile.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text('${profile.name} добавлен(а) в контакты')),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось принять запрос. Попробуйте ещё раз.'),
          ),
        );
    }
  }

  Future<void> _declineRequest(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    try {
      await ref
          .read(contactsControllerProvider)
          .declineRequest(profile.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Запрос отклонён')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Не удалось отклонить запрос. Попробуйте ещё раз.'),
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
    final AsyncValue<List<Profile>> discovery = ref.watch(
      discoveryProfilesProvider,
    );
    final Map<String, Profile> profiles = <String, Profile>{
      for (final Profile profile in discovery.asData?.value ?? const <Profile>[])
        profile.id: profile,
    };
    final List<Profile> contacts = <Profile>[
      for (final String id in contactIds)
        if (profiles[id] != null) profiles[id]!,
    ];
    // Контакты уже сохранены, но анкеты ещё подгружаются: не показываем
    // «Пока нет контактов», чтобы список не выглядел пустым.
    final bool isLoadingContacts =
        contacts.isEmpty && contactIds.isNotEmpty && discovery.isLoading;
    final List<String> requestIds = ref.watch(incomingContactRequestIdsProvider);
    final List<Profile> requests = <Profile>[
      for (final String id in requestIds)
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
              if (requests.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Запросы в контакты', style: AppTextStyles.title()),
                    const Spacer(),
                    Text('${requests.length}', style: AppTextStyles.caption()),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                for (int i = 0; i < requests.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ContactRequestTile(
                      profile: requests[i],
                      index: i,
                      onOpenProfile: () =>
                          context.push('/user/${requests[i].id}'),
                      onAccept: () => _acceptRequest(context, ref, requests[i]),
                      onDecline: () =>
                          _declineRequest(context, ref, requests[i]),
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Text('Мои контакты', style: AppTextStyles.title()),
                  const Spacer(),
                  Text('${contacts.length}', style: AppTextStyles.caption()),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (isLoadingContacts)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (contacts.isEmpty)
                _EmptyContacts()
              else
                for (int i = 0; i < contacts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ContactTile(
                      profile: contacts[i],
                      index: i,
                      onOpenProfile: () =>
                          context.push('/user/${contacts[i].id}'),
                      onOpenChat: () => _openChat(context, ref, contacts[i].id),
                      onRemove: () =>
                          ref.read(contactsControllerProvider).remove(
                            contacts[i].id,
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

class _ContactRequestTile extends StatelessWidget {
  const _ContactRequestTile({
    required this.profile,
    required this.index,
    required this.onOpenProfile,
    required this.onAccept,
    required this.onDecline,
  });

  final Profile profile;
  final int index;
  final VoidCallback onOpenProfile;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: <Widget>[
              InkWell(
                borderRadius: AppRadius.mdAll,
                onTap: onOpenProfile,
                child: Row(
                  children: <Widget>[
                    AuraAvatar(
                      photoUrl: profile.photoUrl,
                      size: 48,
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
                            'Хочет добавить вас в контакты',
                            style: AppTextStyles.caption(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: NeonButton(
                      label: 'Добавить',
                      icon: Icons.person_add_alt_1_rounded,
                      expanded: true,
                      onPressed: onAccept,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: NeonButton(
                      label: 'Отклонить',
                      icon: Icons.close_rounded,
                      variant: NeonButtonVariant.outlined,
                      expanded: true,
                      onPressed: onDecline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.profile,
    required this.index,
    required this.onOpenProfile,
    required this.onOpenChat,
    required this.onRemove,
  });

  final Profile profile;
  final int index;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenChat;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onOpenProfile,
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
                  tooltip: 'Профиль',
                  icon: const Icon(Icons.person_outline_rounded),
                  color: AppColors.textMuted,
                  onPressed: onOpenProfile,
                ),
                IconButton(
                  tooltip: 'Написать',
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: onOpenChat,
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
