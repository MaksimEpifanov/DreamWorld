import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/profile.dart';
import '../../data/providers/notification_providers.dart';
import '../contacts/contacts_controller.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final List<AppNotification> notifications = ref.watch(
      notificationsProvider,
    );
    final List<AppNotification> visible = _unreadOnly
        ? notifications.where((AppNotification item) => !item.isRead).toList()
        : notifications;
    final List<Profile> requests = ref.watch(
      incomingContactRequestProfilesProvider,
    );
    final int unreadCount =
        notifications.where((item) => !item.isRead).length + requests.length;

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Уведомления',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        unreadCount == 0
                            ? 'Ты всё посмотрел'
                            : _unreadLabel(unreadCount),
                        style: AppTextStyles.bodyBold(),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton.icon(
                        onPressed: () => ref
                            .read(notificationsControllerProvider)
                            .markAllRead(),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Прочитать все'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: <Widget>[
                    _FilterChip(
                      label: 'Все',
                      selected: !_unreadOnly,
                      onSelected: () => setState(() => _unreadOnly = false),
                    ),
                    _FilterChip(
                      label: 'Непрочитанные',
                      selected: _unreadOnly,
                      onSelected: () => setState(() => _unreadOnly = true),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: (visible.isEmpty && requests.isEmpty)
                      ? const _EmptyNotifications()
                      : ListView(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          children: <Widget>[
                            if (requests.isNotEmpty) ...<Widget>[
                              _ContactRequestsHeader(count: requests.length),
                              const SizedBox(height: AppSpacing.sm),
                              for (int i = 0; i < requests.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: _ContactRequestNotification(
                                    profile: requests[i],
                                    onOpenProfile: () =>
                                        context.push('/user/${requests[i].id}'),
                                    onAccept: () => _handleRequest(
                                      context,
                                      () => ref
                                          .read(contactsControllerProvider)
                                          .acceptRequest(requests[i].id),
                                      'Запрос принят — ${requests[i].name} в контактах',
                                    ),
                                    onDecline: () => _handleRequest(
                                      context,
                                      () => ref
                                          .read(contactsControllerProvider)
                                          .declineRequest(requests[i].id),
                                      'Запрос отклонён',
                                    ),
                                  ),
                                ),
                              if (visible.isNotEmpty)
                                const SizedBox(height: AppSpacing.sm),
                            ],
                            for (int i = 0; i < visible.length; i++) ...<Widget>[
                              if (i > 0) const SizedBox(height: AppSpacing.sm),
                              _NotificationTile(
                                notification: visible[i],
                                onTap: () {
                                  ref
                                      .read(notificationsControllerProvider)
                                      .markRead(visible[i].id);
                                  final String? route = visible[i].route;
                                  if (route != null) context.go(route);
                                },
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRequest(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
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

  String _unreadLabel(int count) {
    final int lastTwo = count % 100;
    final int last = count % 10;
    if (last == 1 && lastTwo != 11) return '$count новое уведомление';
    if (last >= 2 && last <= 4 && (lastTwo < 12 || lastTwo > 14)) {
      return '$count новых уведомления';
    }
    return '$count новых уведомлений';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF183D73),
      side: BorderSide(
        color: selected ? const Color(0xFF38BDF8) : const Color(0xFF315477),
      ),
      labelStyle: AppTextStyles.caption(
        color: selected ? Colors.white : AppColors.textSecondary,
      ),
    );
  }
}

class _ContactRequestsHeader extends StatelessWidget {
  const _ContactRequestsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(Icons.person_add_alt_1_rounded, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Text('Запросы в контакты', style: AppTextStyles.bodyBold()),
        const Spacer(),
        Text('$count', style: AppTextStyles.caption()),
      ],
    );
  }
}

class _ContactRequestNotification extends StatelessWidget {
  const _ContactRequestNotification({
    required this.profile,
    required this.onOpenProfile,
    required this.onAccept,
    required this.onDecline,
  });

  final Profile profile;
  final VoidCallback onOpenProfile;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onOpenProfile,
            child: Row(
              children: <Widget>[
                AuraAvatar(
                  photoUrl: profile.photoUrl,
                  size: 44,
                  fallbackText: profile.name,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(profile.name, style: AppTextStyles.bodyBold()),
                      const SizedBox(height: 4),
                      Text(
                        'Хочет добавить вас в контакты',
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ),
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
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (IconData, Color) appearance = switch (notification.kind) {
      AppNotificationKind.community => (
        Icons.public_rounded,
        const Color(0xFF43C7FF),
      ),
      AppNotificationKind.event => (
        Icons.event_available_rounded,
        const Color(0xFFFFB84D),
      ),
      AppNotificationKind.recommendation => (
        Icons.auto_awesome_rounded,
        const Color(0xFFA98BFF),
      ),
      AppNotificationKind.social => (
        Icons.people_alt_rounded,
        const Color(0xFF55E1B1),
      ),
      AppNotificationKind.update => (
        Icons.notifications_active_rounded,
        const Color(0xFFFF73D1),
      ),
    };

    return NeonCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appearance.$2.withValues(alpha: 0.16),
                    border: Border.all(
                      color: appearance.$2.withValues(alpha: 0.7),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: appearance.$2.withValues(alpha: 0.22),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(appearance.$1, color: appearance.$2, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyBold(),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF48CFFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.description,
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.timeLabel,
                        style: AppTextStyles.caption(
                          color: const Color(0xFF72B9E6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: Color(0xFF71BFFF),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Новых уведомлений пока нет', style: AppTextStyles.bodyBold()),
          const SizedBox(height: 4),
          Text(
            'Здесь появятся заявки в контакты, новые сообщения и события планет',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
