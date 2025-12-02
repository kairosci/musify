import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/song_tile.dart';

/// Playlist detail screen
class PlaylistScreen extends StatelessWidget {
  final Playlist playlist;
  final bool isLikedSongs;

  const PlaylistScreen({
    super.key,
    required this.playlist,
    this.isLikedSongs = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with playlist info
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: _PlaylistHeader(
                playlist: playlist,
                isLikedSongs: isLikedSongs,
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: _ActionBar(
              playlist: playlist,
              isLikedSongs: isLikedSongs,
            ),
          ),

          // Songs list
          if (playlist.songs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music,
                      size: 64,
                      color: AppTheme.textSecondaryDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No songs yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find some songs to add to this playlist',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = playlist.songs[index];
                  return SongTile(
                    song: song,
                    index: index + 1,
                    showAlbum: true,
                    onTap: () {
                      context.read<PlayerProvider>().playSong(
                            song,
                            playlist: playlist.songs,
                            startIndex: index,
                          );
                    },
                  );
                },
                childCount: playlist.songs.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Playlist header with image and info
class _PlaylistHeader extends StatelessWidget {
  final Playlist playlist;
  final bool isLikedSongs;

  const _PlaylistHeader({
    required this.playlist,
    required this.isLikedSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLikedSongs
              ? [
                  AppTheme.primaryRed.withOpacity(0.8),
                  AppTheme.primaryRedDark.withOpacity(0.6),
                  AppTheme.backgroundDark,
                ]
              : [
                  AppTheme.backgroundDarkTertiary,
                  AppTheme.backgroundDark,
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            children: [
              // Playlist image
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: isLikedSongs
                      ? null
                      : AppTheme.backgroundDarkTertiary,
                  gradient: isLikedSongs
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppTheme.redGradient,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: isLikedSongs
                      ? const Icon(
                          Icons.favorite,
                          size: 64,
                          color: Colors.white,
                        )
                      : playlist.displayImage != null
                          ? Image.network(
                              playlist.displayImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.queue_music,
                                size: 64,
                                color: AppTheme.textSecondaryDark,
                              ),
                            )
                          : const Icon(
                              Icons.queue_music,
                              size: 64,
                              color: AppTheme.textSecondaryDark,
                            ),
                ),
              ),

              const SizedBox(height: 16),

              // Playlist title
              Text(
                playlist.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (playlist.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  playlist.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              // Playlist info
              Text(
                '${playlist.ownerName} • ${playlist.songCount} songs${playlist.songCount > 0 ? ' • ${playlist.formattedTotalDuration}' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action bar with play/shuffle buttons
class _ActionBar extends StatelessWidget {
  final Playlist playlist;
  final bool isLikedSongs;

  const _ActionBar({
    required this.playlist,
    required this.isLikedSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Download button
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
          // Add to library
          if (!isLikedSongs)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {},
            ),
          // More options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
          
          const Spacer(),
          
          // Shuffle button
          Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              return IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: playerProvider.shuffle
                      ? AppTheme.primaryRed
                      : AppTheme.textPrimaryDark,
                ),
                onPressed: playlist.songs.isEmpty
                    ? null
                    : () {
                        if (!playerProvider.shuffle) {
                          playerProvider.toggleShuffle();
                        }
                        playerProvider.playSong(
                          playlist.songs.first,
                          playlist: playlist.songs,
                        );
                      },
              );
            },
          ),
          
          // Play button
          FloatingActionButton(
            onPressed: playlist.songs.isEmpty
                ? null
                : () {
                    context.read<PlayerProvider>().playSong(
                          playlist.songs.first,
                          playlist: playlist.songs,
                        );
                  },
            child: const Icon(Icons.play_arrow, size: 32),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
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
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_to_queue),
            title: const Text('Add to queue'),
            onTap: () {
              for (final song in playlist.songs) {
                context.read<PlayerProvider>().addToQueue(song);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          if (!isLikedSongs)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit playlist'),
              onTap: () => Navigator.pop(context),
            ),
          if (!isLikedSongs)
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[400]),
              title: Text('Delete playlist',
                  style: TextStyle(color: Colors.red[400])),
              onTap: () {
                context.read<LibraryProvider>().deletePlaylist(playlist.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
