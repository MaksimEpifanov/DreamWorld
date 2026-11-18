import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../data/providers/auth_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chat/conversations_list_screen.dart';
import '../../features/contacts/contacts_screen.dart';
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
import '../../features/planets/events/planet_events_screen.dart';
import '../../features/planets/home/planet_home_screen.dart';
import '../../features/planets/map/planet_map_screen.dart';
import '../../features/planets/news/planet_news_screen.dart';
import '../../features/profile/profile_setup_screen.dart';
import '../../features/profile/profile_view_edit_screen.dart';
import '../../features/profile/user_profile_screen.dart';
import '../../features/reviews/reviews_screen.dart';
import '../../features/safety/safety_center_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';

/// Публичные маршруты, доступные без аутентификации.
const Set<String> _publicRoutes = <String>{
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
  '/auth/callback',
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

      // Аккаунт создан, но почта не подтверждена.
      if (auth.isAwaitingEmailVerification) {
        return location == '/verify-email' ? null : '/verify-email';
      }

      // Не авторизован.
      if (!auth.isAuthenticated) {
        if (location == '/splash') return '/onboarding';
        if (_publicRoutes.contains(location)) return null;
        return '/login';
      }

      // Авторизован: со вход/регистрации — сначала проверяем анкету.
      if (location == '/verify-email') {
        // Пользователь вошёл без подтверждения — экран ему ещё доступен.
        return auth.pendingEmailVerification ? null : '/splash';
      }
      if (isLogin) return '/splash';

      // Авторизован: со сплэша — на главную (или к анкете, если её нет).
      if (location == '/splash') {
        final AsyncValue<bool> saved = ref.read(hasSavedProfileProvider);
        if (!saved.hasValue || saved.isLoading) {
          // Анкета ещё восстанавливается — держимся на сплэше.
          return '/splash';
        }
        return saved.value! ? '/main' : '/profile-setup';
      }

      // Анкета уже есть — уводим с экрана создания на главную. Нужно из-за
      // гонки холодной загрузки: при первом переходе анкета ещё могла не
      // определиться, а без этого правила пользователь навсегда оставался
      // на полноэкранном /profile-setup без нижней навигации.
      if (location == '/profile-setup') {
        final AsyncValue<bool> saved = ref.read(hasSavedProfileProvider);
        if (!saved.isLoading && saved.hasValue && saved.value == true) {
          return '/main';
        }
        return null;
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
        path: '/verify-email',
        name: 'verify-email',
        builder: (BuildContext context, GoRouterState state) {
          return const VerifyEmailScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        name: 'auth-callback',
        builder: (BuildContext context, GoRouterState state) =>
            const AuthCallbackScreen(),
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
                        path: 'events',
                        name: 'planet-events',
                        builder: (BuildContext context, GoRouterState state) {
                          final String id = state.pathParameters['id'] ?? '';
                          return PlanetEventsScreen(planetId: id);
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
              ),
            ],
          ),
        ],
      ),
      // Полноэкранные маршруты поверх оболочки.
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (BuildContext context, GoRouterState state) {
          return const SearchScreen();
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileViewEditScreen();
        },
      ),
      GoRoute(
        path: '/user/:id',
        name: 'user-profile',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          return UserProfileScreen(userId: id);
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
        path: '/reviews',
        name: 'reviews',
        builder: (BuildContext context, GoRouterState state) {
          return const ReviewsScreen();
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
