import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app_router.dart';
import 'src/constants/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ChoreChampApp(),
    ),
  );
}

class ChoreChampApp extends StatelessWidget {
  const ChoreChampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChoreChamp',
      theme: appTheme,
      routerConfig: createAppRouter(),
    );
  }
}
