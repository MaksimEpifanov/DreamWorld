import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/index.dart';
import 'core/widgets/index.dart';
import 'features/notifications/chat_notification_listener.dart';

class DreemWorldApp extends ConsumerWidget {
  const DreemWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeName themeName = ref.watch(themeControllerProvider);
    final GoRouter router = ref.watch(routerProvider);
    final ThemeData theme = AppTheme.of(themeName);

    return ChatNotificationListener(
      child: MaterialApp.router(
        title: 'Dreem World',
        debugShowCheckedModeBanner: false,
        theme: theme.copyWith(
          scaffoldBackgroundColor: Colors.transparent,
        ),
        routerConfig: router,
        builder: (context, child) {
          return AnimatedGradientBackgroundLayer(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
