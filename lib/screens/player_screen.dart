import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';

/// Full-screen player with album art and controls
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final song = playerProvider.currentSong;
        
        if (song == null) {
          return const Scaffold(
            body: Center(
              child: Text('No song playing'),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryRed.withOpacity(0.3),
                  AppTheme.backgroundDark,
                  AppTheme.backgroundDark,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App bar
                  _PlayerAppBar(playerProvider: playerProvider),
                  
                  // Album art
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _AlbumArt(imageUrl: song.imageUrl),
                    ),
                  ),
                  
                  // Song info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _SongInfo(song: song),
                  ),
                  
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: _ProgressBar(playerProvider: playerProvider),
                  ),
                  
                  // Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _PlayerControls(playerProvider: playerProvider),
                  ),
                  
                  // Extra controls
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: _ExtraControls(playerProvider: playerProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Player app bar with collapse and menu buttons
class _PlayerAppBar extends StatelessWidget {
  final PlayerProvider playerProvider;

  const _PlayerAppBar({required this.playerProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'PLAYING FROM PLAYLIST',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1,
                      color: AppTheme.textSecondaryDark,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                playerProvider.currentSong?.album ?? 'Unknown',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final song = playerProvider.currentSong;
    if (song == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundDarkSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiaryDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Consumer<LibraryProvider>(
              builder: (context, library, child) {
                final isLiked = library.isLiked(song);
                return Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppTheme.primaryRed : null,
                );
              },
            ),
            title: const Text('Like'),
            onTap: () {
              context.read<LibraryProvider>().toggleLike(song);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to playlist'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: const Text('View queue'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View artist'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.album),
            title: const Text('View album'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Album art display
class _AlbumArt extends StatelessWidget {
  final String? imageUrl;

  const _AlbumArt({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.backgroundDarkTertiary,
                    child: const Icon(
                      Icons.music_note,
                      size: 100,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                )
              : Container(
                  color: AppTheme.backgroundDarkTertiary,
                  child: const Icon(
                    Icons.music_note,
                    size: 100,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Song info with like button
class _SongInfo extends StatelessWidget {
  final dynamic song;

  const _SongInfo({required this.song});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryDark,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Consumer<LibraryProvider>(
          builder: (context, library, child) {
            final isLiked = library.isLiked(song);
            return IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppTheme.primaryRed : null,
              ),
              onPressed: () => library.toggleLike(song),
            );
          },
        ),
      ],
    );
  }
}

/// Progress bar with timestamps
class _ProgressBar extends StatelessWidget {
  final PlayerProvider playerProvider;

  const _ProgressBar({required this.playerProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: playerProvider.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              playerProvider.seekToPercent(value);
            },
            activeColor: AppTheme.textPrimaryDark,
            inactiveColor: AppTheme.textTertiaryDark.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(playerProvider.position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(playerProvider.duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Main player controls (Spotify-like)
class _PlayerControls extends StatelessWidget {
  final PlayerProvider playerProvider;

  const _PlayerControls({required this.playerProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: playerProvider.shuffle
                ? AppTheme.primaryRed
                : AppTheme.textSecondaryDark,
            size: 24,
          ),
          onPressed: () => playerProvider.toggleShuffle(),
        ),
        
        // Previous
        IconButton(
          icon: Icon(
            Icons.skip_previous_rounded, 
            size: 44,
            color: playerProvider.hasPrevious 
                ? AppTheme.textPrimaryDark 
                : AppTheme.textTertiaryDark,
          ),
          onPressed: playerProvider.hasPrevious
              ? () => playerProvider.skipPrevious()
              : null,
        ),
        
        // Play/Pause (Spotify-like large circular button)
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppTheme.textPrimaryDark,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: playerProvider.isBuffering
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.backgroundDark,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    playerProvider.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppTheme.backgroundDark,
                    size: 36,
                  ),
                  onPressed: () => playerProvider.togglePlayPause(),
                ),
        ),
        
        // Next
        IconButton(
          icon: Icon(
            Icons.skip_next_rounded, 
            size: 44,
            color: playerProvider.hasNext 
                ? AppTheme.textPrimaryDark 
                : AppTheme.textTertiaryDark,
          ),
          onPressed: playerProvider.hasNext
              ? () => playerProvider.skipNext()
              : null,
        ),
        
        // Repeat
        IconButton(
          icon: Icon(
            playerProvider.repeatMode == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: playerProvider.repeatMode != RepeatMode.off
                ? AppTheme.primaryRed
                : AppTheme.textSecondaryDark,
            size: 24,
          ),
          onPressed: () => playerProvider.toggleRepeat(),
        ),
      ],
    );
  }
}

/// Extra controls row
class _ExtraControls extends StatelessWidget {
  final PlayerProvider playerProvider;

  const _ExtraControls({required this.playerProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.devices, size: 20),
          color: AppTheme.textSecondaryDark,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share, size: 20),
          color: AppTheme.textSecondaryDark,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.queue_music, size: 20),
          color: AppTheme.textSecondaryDark,
          onPressed: () {},
        ),
      ],
    );
  }
}
