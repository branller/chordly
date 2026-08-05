import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chordly/core/theme/app_theme.dart';
import 'package:chordly/features/songs/presentation/screens/songs_list_screen.dart';

/// Provider to toggle between light and dark theme.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Root widget of the Chordly application.
class ChordlyApp extends ConsumerWidget {
  const ChordlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Chordly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SongsListScreen(),
    );
  }
}
