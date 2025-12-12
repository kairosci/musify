import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/album.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/song_tile.dart';
import 'artist_screen.dart';

/**
 * Album detail screen showing album info and track list.
 */
class AlbumScreen extends StatelessWidget {
  final Album album;

  const AlbumScreen({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with album info
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: _AlbumHeader(album: album),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: _ActionBar(album: album),
          ),

          // Songs list
          if (album.songs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.album,
                      size: 64,
                      color: AppTheme.textSecondaryDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No songs available',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = album.songs[index];
                  return SongTile(
                    song: song,
                    index: index + 1,
                    showAlbum: false,
                    onTap: () async {
                      await context.read<PlayerProvider>().playSong(
                            song,
                            playlist: album.songs,
                            startIndex: index,
                          );
                    },
                  );
                },
                childCount: album.songs.length,
              ),
            ),

          // Album info footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (album.year != null)
                    Text(
                      '${album.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${album.songCount} songs • ${album.formattedTotalDuration}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
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

/**
 * Album header with image and info.
 */
class _AlbumHeader extends StatelessWidget {
  final Album album;

  const _AlbumHeader({required this.album});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
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
              // Album cover
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDarkTertiary,
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
                  child: album.imageUrl != null
                      ? Image.network(
                          album.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.album,
                            size: 64,
                            color: AppTheme.textSecondaryDark,
                          ),
                        )
                      : const Icon(
                          Icons.album,
                          size: 64,
                          color: AppTheme.textSecondaryDark,
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Album title
              Text(
                album.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Artist name (clickable)
              GestureDetector(
                onTap: () {
                  // Navigate to artist page
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      album.artist,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (album.isExplicit) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondaryDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'E',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.backgroundDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Album info
              Text(
                'Album${album.year != null ? ' • ${album.year}' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/**
 * Action bar with play/shuffle buttons.
 */
class _ActionBar extends StatelessWidget {
  final Album album;

  const _ActionBar({required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like/save button
          Consumer<LibraryProvider>(
            builder: (context, libraryProvider, child) {
              final isSaved = libraryProvider.isAlbumSaved(album.id);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? AppTheme.primaryRed : null,
                ),
                onPressed: () {
                  libraryProvider.toggleAlbumSaved(album);
                },
              );
            },
          ),
          // Download button
          IconButton(
            icon: const Icon(Icons.download_outlined),
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
                onPressed: album.songs.isEmpty
                    ? null
                    : () async {
                        if (!playerProvider.shuffle) {
                          await playerProvider.toggleShuffle();
                        }
                        await playerProvider.playSong(
                          album.songs.first,
                          playlist: album.songs,
                        );
                      },
              );
            },
          ),
          
          // Play button
          FloatingActionButton(
            onPressed: album.songs.isEmpty
                ? null
                : () async {
                    await context.read<PlayerProvider>().playSong(
                          album.songs.first,
                          playlist: album.songs,
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
              for (final song in album.songs) {
                context.read<PlayerProvider>().addToQueue(song);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to playlist'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Go to artist'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
