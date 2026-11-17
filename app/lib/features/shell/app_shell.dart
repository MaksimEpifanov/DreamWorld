import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/cosmic_background.dart';
import '../../data/models/conversation.dart';
import '../../data/models/profile.dart';
import '../../data/providers/app_providers.dart';
import '../contacts/contacts_controller.dart';

/// Каркас основного интерфейса с нижней навигацией по разделам.
///
/// Оборачивает [StatefulNavigationShell] из `StatefulShellRoute.indexedStack`:
/// каждая вкладка хранит собственную историю переходов.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  /// Навигационная оболочка ветки StatefulShellRoute.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Создаёт анкету в Firestore, если её ещё нет: без неё не работают
    // участники планет, поиск по ID и чаты.
    ref.watch(profileBootstrapProvider);

    // Показывает уведомление о новом сообщении, пока приложение открыто.
    ref.listen<AsyncValue<List<Conversation>>>(conversationsProvider, (
      AsyncValue<List<Conversation>>? previous,
      AsyncValue<List<Conversation>> next,
    ) {
      final List<Conversation>? before = previous?.valueOrNull;
      final List<Conversation>? after = next.valueOrNull;
      if (before == null || after == null) return;
      for (final Conversation conversation in after) {
        final int oldUnread = before
            .where((Conversation item) => item.id == conversation.id)
            .map((Conversation item) => item.unreadCount)
            .fold<int>(0, (int max, int value) => value > max ? value : max);
        if (conversation.unreadCount <= oldUnread) continue;
        final String text = conversation.lastMessage?.text ?? '';
        final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
          context,
        );
        messenger
          ?..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                text.isEmpty ? 'Новое сообщение' : 'Новое сообщение: $text',
              ),
            ),
          );
        break;
      }
    });

    // Показывает уведомление, когда собеседник отправляет запрос в контакты.
    ref.listen<List<String>>(incomingContactRequestIdsProvider, (
      List<String>? previous,
      List<String> next,
    ) {
      if (previous == null) return;
      final List<String> added = next
          .where((String id) => !previous.contains(id))
          .toList(growable: false);
      if (added.isEmpty) return;
      final List<Profile> live =
          ref.read(discoveryProfilesProvider).valueOrNull ??
          const <Profile>[];
      String name = 'Пользователь';
      for (final Profile profile in live) {
        if (profile.id == added.first) {
          name = profile.name;
          break;
        }
      }
      final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
        context,
      );
      messenger
        ?..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text('$name хочет добавить вас в контакты')),
        );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const CosmicBackground(),
          SizedBox.expand(child: shell),
        ],
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: shell.currentIndex,
        onDestinationSelected: (int index) {
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
    );
  }
}

/// Стеклянная нижняя панель навигации в стиле макета главного экрана.
class AppNavigationBar extends ConsumerWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String path = GoRouterState.of(context).uri.path;
    final int selectedIndex = path.contains('/news')
        ? 2
        : (currentIndex >= 2 ? currentIndex + 1 : currentIndex);
    final int unreadCount =
        ref
            .watch(conversationsProvider)
            .valueOrNull
            ?.fold<int>(
              0,
              (int sum, Conversation item) => sum + item.unreadCount,
            ) ??
        0;
    final int contactRequestCount = ref
        .watch(incomingContactRequestIdsProvider)
        .length;

    final Widget bar = Container(
      decoration: BoxDecoration(
        // На web размытие фона на части устройств даёт серый прямоугольник,
        // поэтому используем плотный непрозрачный фон без BackdropFilter.
        color: kIsWeb ? const Color(0xFF0A1B33) : const Color(0xE9081630),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2675C5).withValues(alpha: 0.55),
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.22),
            blurRadius: 24,
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: scheme.primary.withValues(alpha: 0.17),
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: AppRadius.pillAll,
          ),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (Set<WidgetState> states) => AppTextStyles.label(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF58CFFF)
                  : const Color(0xFF91A5C8),
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (Set<WidgetState> states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF58CFFF)
                  : const Color(0xFF91A5C8),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex.clamp(0, 4),
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                onDestinationSelected(0);
                break;
              case 1:
                onDestinationSelected(1);
                break;
              case 2:
                context.go('/main/planet/p_travel/news');
                break;
              case 3:
                onDestinationSelected(2);
                break;
              case 4:
                onDestinationSelected(3);
                break;
            }
          },
          height: 76,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          backgroundColor: Colors.transparent,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.public_outlined),
              selectedIcon: _glowingIcon(Icons.public, scheme),
              label: 'Планеты',
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: _glowingIcon(Icons.explore, scheme),
              label: 'Поиск',
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_fire_department_outlined),
              selectedIcon: _glowingIcon(Icons.local_fire_department, scheme),
              label: 'События',
            ),
            NavigationDestination(
              icon: _badge(
                const Icon(Icons.chat_bubble_outline_rounded),
                unreadCount,
              ),
              selectedIcon: _badge(
                _glowingIcon(Icons.chat_bubble_rounded, scheme),
                unreadCount,
              ),
              label: 'Чаты',
            ),
            NavigationDestination(
              icon: _badge(
                const Icon(Icons.people_outline_rounded),
                contactRequestCount,
              ),
              selectedIcon: _badge(
                _glowingIcon(Icons.people_rounded, scheme),
                contactRequestCount,
              ),
              label: 'Контакты',
            ),
          ],
        ),
      ),
    );

    if (kIsWeb) return bar;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: bar,
      ),
    );
  }

  Widget _badge(Widget icon, int count) {
    if (count <= 0) return icon;
    return Badge.count(count: count, child: icon);
  }

  Icon _glowingIcon(IconData icon, ColorScheme scheme) {
    return Icon(
      icon,
      color: const Color(0xFF58CFFF),
      shadows: <Shadow>[
        Shadow(color: scheme.primary.withValues(alpha: 0.85), blurRadius: 15),
        Shadow(color: scheme.primary.withValues(alpha: 0.5), blurRadius: 25),
      ],
    );
  }
}
