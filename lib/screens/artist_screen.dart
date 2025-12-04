import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/artist.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../utils/sample_data.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_card.dart';
import '../widgets/section_header.dart';
import 'album_screen.dart';

/**
 * Artist detail screen showing artist info, top songs, and albums.
 */
class ArtistScreen extends StatelessWidget {
  final Artist artist;

  const ArtistScreen({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    // Get artist's songs from sample data
    final artistSongs = SampleData.songs
        .where((s) => s.artist == artist.name)
        .toList();
    final artistAlbums = SampleData.albums
        .where((a) => a.artist == artist.name)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with artist image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                artist.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: _ArtistHeader(artist: artist),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: _ActionBar(artist: artist, songs: artistSongs),
          ),

          // Popular songs
          if (artistSongs.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = artistSongs[index];
                  return SongTile(
                    song: song,
                    index: index + 1,
                    showAlbum: true,
                    onTap: () {
                      context.read<PlayerProvider>().playSong(
                            song,
                            playlist: artistSongs,
                            startIndex: index,
                          );
                    },
                  );
                },
                childCount: artistSongs.length.clamp(0, 5),
              ),
            ),
          ],

          // Albums
          if (artistAlbums.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Albums',
                showAll: false,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: artistAlbums.length,
                  itemBuilder: (context, index) {
                    final album = artistAlbums[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AlbumCard(
                        album: album,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumScreen(album: album),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Artist bio
          if (artist.bio != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artist.bio!,
                      style: Theme.of(context).textTheme.bodyMedium,
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
 * Artist header with background image and gradient overlay.
 */
class _ArtistHeader extends StatelessWidget {
  final Artist artist;

  const _ArtistHeader({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        if (artist.imageUrl != null)
          Image.network(
            artist.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.backgroundDarkTertiary,
              child: const Icon(
                Icons.person,
                size: 100,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          )
        else
          Container(
            color: AppTheme.backgroundDarkTertiary,
            child: const Icon(
              Icons.person,
              size: 100,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme.backgroundDark.withOpacity(0.8),
                AppTheme.backgroundDark,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
        
        // Followers and verified badge
        Positioned(
          left: 16,
          bottom: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (artist.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified Artist',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (artist.followers != null)
                Text(
                  artist.formattedFollowers,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/**
 * Action bar with follow/play buttons.
 */
class _ActionBar extends StatelessWidget {
  final Artist artist;
  final List songs;

  const _ActionBar({
    required this.artist,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Follow button
          Consumer<LibraryProvider>(
            builder: (context, libraryProvider, child) {
              final isFollowing = libraryProvider.isArtistFollowed(artist.id);
              return OutlinedButton(
                onPressed: () {
                  libraryProvider.toggleFollowArtist(artist);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isFollowing
                        ? AppTheme.primaryRed
                        : AppTheme.textPrimaryDark,
                  ),
                  foregroundColor: isFollowing
                      ? AppTheme.primaryRed
                      : AppTheme.textPrimaryDark,
                ),
                child: Text(isFollowing ? 'Following' : 'Follow'),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
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
                onPressed: songs.isEmpty
                    ? null
                    : () {
                        if (!playerProvider.shuffle) {
                          playerProvider.toggleShuffle();
                        }
                        playerProvider.playSong(
                          songs.first,
                          playlist: songs.cast(),
                        );
                      },
              );
            },
          ),
          
          // Play button
          FloatingActionButton(
            onPressed: songs.isEmpty
                ? null
                : () {
                    context.read<PlayerProvider>().playSong(
                          songs.first,
                          playlist: songs.cast(),
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
            leading: const Icon(Icons.radio),
            title: const Text('Start radio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Don\'t play this artist'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
