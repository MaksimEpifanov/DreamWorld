import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/app_notification.dart';
import '../../data/providers/notification_providers.dart';

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
      notificationControllerProvider,
    );
    final List<AppNotification> visible = _unreadOnly
        ? notifications.where((AppNotification item) => !item.isRead).toList()
        : notifications;
    final int unreadCount = notifications.where((item) => !item.isRead).length;

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
                            .read(notificationControllerProvider.notifier)
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
                  child: visible.isEmpty
                      ? const _EmptyNotifications()
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (BuildContext context, int index) {
                            final AppNotification item = visible[index];
                            return _NotificationTile(
                              notification: item,
                              onTap: () {
                                ref
                                    .read(
                                      notificationControllerProvider.notifier,
                                    )
                                    .markRead(item.id);
                                if (item.route != null) {
                                  context.go(item.route!);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            'Здесь появятся новости о событиях и сообществах',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
