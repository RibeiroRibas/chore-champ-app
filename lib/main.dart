import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app_router.dart';
import 'src/constants/app_theme.dart';
import 'src/infra/session_storage.dart';
import 'src/providers/session_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(SessionStorage(prefs)),
      ],
      child: const ChoreChampApp(),
    ),
  );
}

class ChoreChampApp extends ConsumerWidget {
  const ChoreChampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    return sessionAsync.when(
      loading: () => MaterialApp(
        title: 'ChoreChamp',
        theme: appTheme,
        home: const _SplashScreen(),
      ),
      data: (_) => MaterialApp.router(
        title: 'ChoreChamp',
        theme: appTheme,
        routerConfig: ref.watch(appRouterProvider),
      ),
      error: (error, stackTrace) => MaterialApp.router(
        title: 'ChoreChamp',
        theme: appTheme,
        routerConfig: ref.watch(appRouterProvider),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cleaning_services,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
