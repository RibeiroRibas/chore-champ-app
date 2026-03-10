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
    loc == '/' || loc == '/chores' || loc == '/achievements' || loc == '/rewards' || loc == '/family';

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final session = container.read(sessionProvider);
      final loc = state.matchedLocation;
      if (session.accessToken != null && session.needFirstAccess && loc != '/create-user-first-access') {
        return '/create-user-first-access';
      }
      if (session.accessToken == null && _isShellPath(loc)) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/create-account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/create-account-code',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CreateAccountCodePage(),
      ),
      GoRoute(
        path: '/create-user-first-access',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CreateUserFirstAccessPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ForgotPasswordPage(),
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
            pageBuilder: (_, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/chores',
            pageBuilder: (_, state) => const NoTransitionPage(child: ChoresPage()),
          ),
          GoRoute(
            path: '/achievements',
            pageBuilder: (_, state) => const NoTransitionPage(child: AchievementsPage()),
          ),
          GoRoute(
            path: '/rewards',
            pageBuilder: (_, state) => NoTransitionPage(child: const RewardsPage()),
          ),
          GoRoute(
            path: '/family',
            pageBuilder: (_, state) => const NoTransitionPage(child: FamilyPage()),
          ),
        ],
      ),
    ],
    errorBuilder: (_, __) => const NotFoundPage(),
  );
}
