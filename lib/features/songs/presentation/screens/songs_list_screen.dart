import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chordly/app/app.dart';
import 'package:chordly/features/chordpro/models/parsed_song.dart';
import 'package:chordly/features/songs/presentation/providers/songs_provider.dart';
import 'package:chordly/features/songs/presentation/widgets/song_card.dart';
import 'package:chordly/features/songs/presentation/screens/song_detail_screen.dart';

/// The main screen showing all available songs.
///
/// Loads songs from assets via [songsProvider] and displays them
/// in a scrollable list of [SongCard]s.
class SongsListScreen extends ConsumerWidget {
  const SongsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_music_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Chordly',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          // ── Theme toggle ──────────────────────────────────────
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Cambiar tema',
            onPressed: () {
              final currentMode = ref.read(themeModeProvider);
              ref
                  .read(themeModeProvider.notifier)
                  .state = currentMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar canciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        data: (songs) => _SongsList(songs: songs),
      ),
    );
  }
}

class _SongsList extends StatelessWidget {
  final List<ParsedSong> songs;

  const _SongsList({required this.songs});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay canciones disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SongCard(
            song: song,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)),
              );
            },
          ),
        );
      },
    );
  }
}
