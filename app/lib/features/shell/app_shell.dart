import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/cosmic_background.dart';

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
          shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Стеклянная нижняя панель навигации в стиле макета главного экрана.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String path = GoRouterState.of(context).uri.path;
    final int selectedIndex = path.contains('/news')
        ? 2
        : (currentIndex >= 2 ? currentIndex + 1 : currentIndex);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xE9081630),
            border: Border(
              top: BorderSide(color: const Color(0xFF2675C5).withValues(alpha: 0.55)),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(color: scheme.primary.withValues(alpha: 0.22), blurRadius: 24),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: scheme.primary.withValues(alpha: 0.17),
              indicatorShape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
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
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: _glowingIcon(Icons.chat_bubble_rounded, scheme),
                  label: 'Чаты',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline_rounded),
                  selectedIcon: _glowingIcon(Icons.people_rounded, scheme),
                  label: 'Контакты',
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
