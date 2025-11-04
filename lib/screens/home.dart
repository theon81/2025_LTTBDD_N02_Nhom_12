import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/sample_songs.dart';
import '../models/playback_settings.dart';
import '../services/playback_manager.dart';
import 'player.dart';

/// home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  Text('Spoofify', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                  const Spacer(),
                  // placeholder actions
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // song list
            Expanded(
              child: ListView.separated(
                itemCount: sampleSongs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final Song s = sampleSongs[index];
                  final settings = PlaybackSettingsProvider.of(context);
                  final selected = settings.currentSongId == s.id;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(s.title.characters.first),
                    ),
                    title: Text(s.title, style: TextStyle(color: selected ? theme.colorScheme.secondary : null)),
                    subtitle: Text(s.artist, style: TextStyle(color: selected ? theme.colorScheme.secondary : null)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      settings.setCurrentSong(s.id);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: s)));
                    },
                  );
                },
              ),
            ),
            // Mini player bar (Spotify-style) shown when a track is available
            _MiniPlayer(),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final manager = PlaybackManagerProvider.of(context);

    final idx = manager.currentIndex;
    if (idx == null || idx < 0 || idx >= sampleSongs.length) {
      return const SizedBox.shrink();
    }

    final song = sampleSongs[idx];
    final position = manager.position;
    final dur = manager.duration ?? Duration.zero;
    final progress = (dur.inMilliseconds > 0) ? (position.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: song))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
          ),
          Container(
            height: 72,
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // cover
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text(song.title.characters.first, style: const TextStyle(color: Colors.white))),
                ),
                const SizedBox(width: 12),
                // title + artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(song.artist, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // controls
                IconButton(
                  onPressed: () => manager.previous(),
                  icon: Icon(Icons.skip_previous, color: theme.colorScheme.onSurface),
                ),
                Material(
                  shape: const CircleBorder(),
                  color: theme.colorScheme.primary,
                  child: IconButton(
                    onPressed: () => manager.togglePlay(),
                    icon: Icon(manager.playing ? Icons.pause : Icons.play_arrow, color: theme.colorScheme.onPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () => manager.next(),
                  icon: Icon(Icons.skip_next, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
