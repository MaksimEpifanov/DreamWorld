import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../data/providers/auth_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chat/conversations_list_screen.dart';
import '../../features/contacts/contacts_screen.dart';
import '../../features/contacts/my_qr_screen.dart';
import '../../features/contacts/scan_qr_screen.dart';
import '../../features/discovery/discovery_screen.dart';
import '../../features/match/match_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/minigames/games/match_three_game_screen.dart';
import '../../features/minigames/games/memory_game_screen.dart';
import '../../features/minigames/games/quiz_game_screen.dart';
import '../../features/minigames/mini_games_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/planets/catalog/other_interests_screen.dart';
import '../../features/planets/catalog/planets_catalog_screen.dart';
import '../../features/planets/detail/planet_detail_screen.dart';
import '../../features/planets/home/planet_home_screen.dart';
import '../../features/planets/map/planet_map_screen.dart';
import '../../features/planets/news/planet_news_screen.dart';
import '../../features/profile/profile_setup_screen.dart';
import '../../features/profile/profile_view_edit_screen.dart';
import '../../features/safety/safety_center_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';

/// Публичные маршруты, доступные без аутентификации.
const Set<String> _publicRoutes = <String>{
  '/login',
  '/register',
  '/onboarding',
  '/splash',
};

/// Слушатель состояния аутентификации для `GoRouter.refreshListenable`.
///
/// При смене состояния вызывает [notifyListeners], из-за чего `GoRouter`
/// пересчитывает `redirect` без пересоздания (стек сохраняется).
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authControllerProvider,
      (AuthState? previous, AuthState next) => notifyListeners(),
    );
    // Когда восстановление профиля завершится, пересчитываем redirect.
    _profileSubscription = ref.listen<AsyncValue<bool>>(
      hasSavedProfileProvider,
      (AsyncValue<bool>? previous, AsyncValue<bool> next) => notifyListeners(),
    );
  }

  ProviderSubscription<AuthState>? _subscription;
  ProviderSubscription<AsyncValue<bool>>? _profileSubscription;

  @override
  void dispose() {
    _subscription?.close();
    _subscription = null;
    _profileSubscription?.close();
    _profileSubscription = null;
    super.dispose();
  }
}

/// Провайдер роутера приложения.
///
/// Создаётся один раз и живёт вместе с приложением; реагирует на изменение
/// статуса аутентификации через [RouterNotifier].
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final RouterNotifier notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String location = state.matchedLocation;
      final bool isLogin = location == '/login' || location == '/register';

      // Восстановление сессии: держимся на сплэше.
      if (auth.isUnknown) {
        return location == '/splash' ? null : '/splash';
      }

      // Не авторизован.
      if (!auth.isAuthenticated) {
        if (location == '/splash') return '/onboarding';
        if (_publicRoutes.contains(location)) return null;
        return '/login';
      }

      // Авторизован: со вход/регистрации — на главную.
      if (isLogin) return '/main';

      // Авторизован: со сплэша — на главную (или к анкете, если профиля нет).
      if (location == '/splash') {
        final AsyncValue<bool> saved = ref.read(hasSavedProfileProvider);
        if (!saved.hasValue) {
          // Профиль ещё восстанавливается — держимся на сплэше.
          return '/splash';
        }
        return saved.value! ? '/main' : '/profile-setup';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupScreen();
        },
      ),
      // Оболочка с нижней навигацией: главная, подбор, чаты, контакты.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AppShell(shell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/main',
                name: 'main',
                builder: (BuildContext context, GoRouterState state) {
                  return const PlanetHomeScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'planets',
                    name: 'planets',
                    builder: (BuildContext context, GoRouterState state) {
                      return const PlanetsCatalogScreen();
                    },
                  ),
                  GoRoute(
                    path: 'other-interests',
                    name: 'other-interests',
                    builder: (BuildContext context, GoRouterState state) {
                      return const OtherInterestsScreen();
                    },
                  ),
                  GoRoute(
                    path: 'planet/:id',
                    name: 'planet',
                    builder: (BuildContext context, GoRouterState state) {
                      final String id = state.pathParameters['id'] ?? '';
                      return PlanetDetailScreen(planetId: id);
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'map',
                        name: 'planet-map',
                        builder: (BuildContext context, GoRouterState state) {
                          final String id = state.pathParameters['id'] ?? '';
                          return PlanetMapScreen(planetId: id);
                        },
                      ),
                      GoRoute(
                        path: 'news',
                        name: 'planet-news',
                        builder: (BuildContext context, GoRouterState state) {
                          final String id = state.pathParameters['id'] ?? '';
                          return PlanetNewsScreen(planetId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/discovery',
                name: 'discovery',
                builder: (BuildContext context, GoRouterState state) {
                  return const DiscoveryScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/chats',
                name: 'chats',
                builder: (BuildContext context, GoRouterState state) {
                  return const ConversationsListScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/contacts',
                name: 'contacts',
                builder: (BuildContext context, GoRouterState state) {
                  return const ContactsScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'my-qr',
                    name: 'contacts-my-qr',
                    builder: (BuildContext context, GoRouterState state) {
                      return const MyQrScreen();
                    },
                  ),
                  GoRoute(
                    path: 'scan',
                    name: 'contacts-scan',
                    builder: (BuildContext context, GoRouterState state) {
                      return const ScanQrScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Полноэкранные маршруты поверх оболочки.
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileViewEditScreen();
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: '/safety',
        name: 'safety',
        builder: (BuildContext context, GoRouterState state) {
          return const SafetyCenterScreen();
        },
      ),
      GoRoute(
        path: '/minigames',
        name: 'minigames',
        builder: (BuildContext context, GoRouterState state) {
          return const MiniGamesScreen();
        },
      ),
      GoRoute(
        path: '/minigames/quiz',
        name: 'minigame-quiz',
        builder: (BuildContext context, GoRouterState state) {
          return const QuizGameScreen();
        },
      ),
      GoRoute(
        path: '/minigames/match3',
        name: 'minigame-match3',
        builder: (BuildContext context, GoRouterState state) {
          return const MatchThreeGameScreen();
        },
      ),
      GoRoute(
        path: '/minigames/memory',
        name: 'minigame-memory',
        builder: (BuildContext context, GoRouterState state) {
          return const MemoryGameScreen();
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/match',
        name: 'match',
        builder: (BuildContext context, GoRouterState state) {
          final String? userId = state.uri.queryParameters['userId'];
          return MatchScreen(userId: userId);
        },
      ),
    ],
  );
});
