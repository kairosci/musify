import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../providers/player_provider.dart';
import '../utils/sample_data.dart';
import '../utils/app_theme.dart';
import '../widgets/song_tile.dart';
import '../widgets/playlist_card.dart';
import '../widgets/album_card.dart';
import '../widgets/artist_card.dart';
import '../widgets/section_header.dart';
import 'playlist_screen.dart';
import 'album_screen.dart';
import 'artist_screen.dart';

/// Home screen with personalized content
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Flyer'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Greeting Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),

          // Quick Access Grid (Recent playlists/albums)
          SliverToBoxAdapter(
            child: _QuickAccessGrid(
              playlists: SampleData.playlists.take(6).toList(),
            ),
          ),

          // Quick Picks
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Quick Picks',
              subtitle: 'Personalized for you',
            ),
          ),
          SliverToBoxAdapter(
            child: _QuickPicksSection(songs: SampleData.quickPicks),
          ),

          // Made For You Playlists
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Made For You',
              showAll: true,
            ),
          ),
          SliverToBoxAdapter(
            child: _PlaylistsRow(playlists: SampleData.recommendedPlaylists),
          ),

          // New Releases
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'New Releases',
              showAll: true,
            ),
          ),
          SliverToBoxAdapter(
            child: _AlbumsRow(albums: SampleData.newReleases),
          ),

          // Popular Artists
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Popular Artists',
              showAll: true,
            ),
          ),
          SliverToBoxAdapter(
            child: _ArtistsRow(artists: SampleData.featuredArtists),
          ),

          // Recently Played
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recently Played',
              showAll: true,
            ),
          ),
          SliverToBoxAdapter(
            child: _RecentlyPlayedSection(songs: SampleData.recentlyPlayed),
          ),

          // Bottom padding for mini player
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}

/// Quick access grid showing recent items
class _QuickAccessGrid extends StatelessWidget {
  final List<Playlist> playlists;

  const _QuickAccessGrid({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: playlists.length.clamp(0, 6),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return _QuickAccessItem(
            title: playlist.title,
            imageUrl: playlist.displayImage,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistScreen(playlist: playlist),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.title,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(4),
              ),
              child: Container(
                width: 56,
                height: 56,
                color: AppTheme.backgroundDarkTertiary,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.music_note,
                          color: AppTheme.textSecondaryDark,
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        color: AppTheme.textSecondaryDark,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick picks horizontal list
class _QuickPicksSection extends StatelessWidget {
  final List<Song> songs;

  const _QuickPicksSection({required this.songs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _QuickPickCard(
              song: song,
              onTap: () {
                context.read<PlayerProvider>().playSong(
                      song,
                      playlist: songs,
                      startIndex: index,
                    );
              },
            ),
          );
        },
      ),
    );
  }
}

class _QuickPickCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _QuickPickCard({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.imageUrl != null
                    ? Image.network(
                        song.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.music_note,
                          color: AppTheme.textSecondaryDark,
                          size: 48,
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        color: AppTheme.textSecondaryDark,
                        size: 48,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Playlists horizontal row
class _PlaylistsRow extends StatelessWidget {
  final List<Playlist> playlists;

  const _PlaylistsRow({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PlaylistCard(
              playlist: playlist,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistScreen(playlist: playlist),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Albums horizontal row
class _AlbumsRow extends StatelessWidget {
  final List<Album> albums;

  const _AlbumsRow({required this.albums});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
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
    );
  }
}

/// Artists horizontal row
class _ArtistsRow extends StatelessWidget {
  final List<Artist> artists;

  const _ArtistsRow({required this.artists});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ArtistCard(
              artist: artist,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArtistScreen(artist: artist),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Recently played section
class _RecentlyPlayedSection extends StatelessWidget {
  final List<Song> songs;

  const _RecentlyPlayedSection({required this.songs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _QuickPickCard(
              song: song,
              onTap: () {
                context.read<PlayerProvider>().playSong(
                      song,
                      playlist: songs,
                      startIndex: index,
                    );
              },
            ),
          );
        },
      ),
    );
  }
}
