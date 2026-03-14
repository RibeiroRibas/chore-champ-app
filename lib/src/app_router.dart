import 'package:chore_champ_app/src/providers/states/session_state.dart';
import 'package:chore_champ_app/src/views/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/session_provider.dart';
import 'views/achievements/pages/achievements_page.dart';
import 'views/widgets/app_header.dart';
import 'views/auth/pages/create_account_code_page.dart';
import 'views/auth/pages/create_account_page.dart';
import 'views/user/create_user_first_access_page.dart';
import 'views/auth/pages/forgot_password_page.dart';
import 'views/auth/pages/login_page.dart';
import 'views/widgets/bottom_nav.dart';
import 'views/chores/pages/chores_page.dart';
import 'views/family/pages/family_page.dart';
import 'views/widgets/not_found_page.dart';
import 'views/rewards/pages/rewards_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

bool _isShellPath(String loc) =>
    loc == '/' ||
    loc == '/chores' ||
    loc == '/achievements' ||
    loc == '/rewards' ||
    loc == '/family';

GoRouter _createGoRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      return _handleRedirect(context, state);
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/create-account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/create-account-code',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateAccountCodePage(),
      ),
      GoRoute(
        path: '/create-user-first-access',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateUserFirstAccessPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => Scaffold(
          body: Column(
            children: [
              const AppHeader(),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: const BottomNav(),
        ),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/chores',
            pageBuilder: (_, state) =>
                const NoTransitionPage(child: ChoresPage()),
          ),
          GoRoute(
            path: '/achievements',
            pageBuilder: (_, state) =>
                const NoTransitionPage(child: AchievementsPage()),
          ),
          GoRoute(
            path: '/rewards',
            pageBuilder: (_, state) =>
                NoTransitionPage(child: const RewardsPage()),
          ),
          GoRoute(
            path: '/family',
            pageBuilder: (_, state) =>
                const NoTransitionPage(child: FamilyPage()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}

String? _handleRedirect(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context);
  final sessionAsync = container.read(sessionProvider);
  final currentRoute = state.matchedLocation;
  if (sessionAsync.isLoading) return null;
  final session = sessionAsync.valueOrNull;
  if (session == null) {
    if (_isShellPath(currentRoute)) return '/login';
    return null;
  }
  if (_isAuthenticatedAndNeedDoFirstAccess(session, currentRoute)) {
    return '/create-user-first-access';
  }
  if (_isAuthenticatedAndCanGoHomePage(session, currentRoute)) {
    return '/';
  }
  if (_needAuthenticate(session, currentRoute)) {
    return '/login';
  }
  return null;
}

bool _isAuthenticatedAndNeedDoFirstAccess(SessionState session, String currentRoute) {
  return session.accessToken != null &&
    session.needFirstAccess &&
    currentRoute != '/create-user-first-access';
}

bool _isAuthenticatedAndCanGoHomePage(SessionState session, String currentRoute) {
  return session.accessToken != null &&
    !session.needFirstAccess &&
    (currentRoute == '/login' ||
        currentRoute == '/create-user-first-access');
}

bool _needAuthenticate(SessionState session, String currentRoute) =>
    session.accessToken == null && _isShellPath(currentRoute);

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = _createGoRouter();
  ref.onDispose(router.dispose);
  return router;
});
