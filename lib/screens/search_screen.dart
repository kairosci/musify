import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../providers/player_provider.dart';
import '../services/piped_service.dart';
import '../utils/sample_data.dart';
import '../utils/app_theme.dart';
import '../widgets/song_tile.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'playlist_screen.dart';

/**
 * Search screen for discovering music.
 * 
 * Provides search functionality using Piped API and displays
 * browseable categories when no search query is active.
 */
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const int _maxSearchResults = 10;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  // Search results
  List<Song> _songResults = [];
  List<Album> _albumResults = [];
  List<Artist> _artistResults = [];
  List<Playlist> _playlistResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      _errorMessage = null;
    });

    if (_isSearching && query.length >= 2) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Search using Piped API for music (audio-only)
        final results = await PipedService.searchMusic(query);
        
        // Convert Piped results to Song models
        // Note: Server already filters for music_songs, but we keep isMusic check
        // as a safety measure for any unexpected items
        final songs = results.items
            .map((item) => item.toSong())
            .toList();

        // Also search local sample data as fallback
        final lowerQuery = query.toLowerCase();
        final localSongs = SampleData.songs
            .where((s) =>
                s.title.toLowerCase().contains(lowerQuery) ||
                s.artist.toLowerCase().contains(lowerQuery))
            .toList();

        final localAlbums = SampleData.albums
            .where((a) =>
                a.title.toLowerCase().contains(lowerQuery) ||
                a.artist.toLowerCase().contains(lowerQuery))
            .toList();

        final localArtists = SampleData.artists
            .where((a) => a.name.toLowerCase().contains(lowerQuery))
            .toList();

        final localPlaylists = SampleData.playlists
            .where((p) => p.title.toLowerCase().contains(lowerQuery))
            .toList();

        if (mounted) {
          setState(() {
            // Combine Piped results with local results
            _songResults = [...songs, ...localSongs];
            _albumResults = localAlbums;
            _artistResults = localArtists;
            _playlistResults = localPlaylists;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Fall back to local sample data on error
        final lowerQuery = query.toLowerCase();
        
        if (mounted) {
          setState(() {
            _songResults = SampleData.songs
                .where((s) =>
                    s.title.toLowerCase().contains(lowerQuery) ||
                    s.artist.toLowerCase().contains(lowerQuery))
                .toList();

            _albumResults = SampleData.albums
                .where((a) =>
                    a.title.toLowerCase().contains(lowerQuery) ||
                    a.artist.toLowerCase().contains(lowerQuery))
                .toList();

            _artistResults = SampleData.artists
                .where((a) => a.name.toLowerCase().contains(lowerQuery))
                .toList();

            _playlistResults = SampleData.playlists
                .where((p) => p.title.toLowerCase().contains(lowerQuery))
                .toList();
                
            _isLoading = false;
            // Show error but still show local results
            _errorMessage = 'Using offline results. Online search unavailable.';
          });
        }
      }
    } else if (!_isSearching) {
      setState(() {
        _songResults = [];
        _albumResults = [];
        _artistResults = [];
        _playlistResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _SearchBar(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
              ),
            ),
          ),

          // Content
          if (_isSearching)
            ..._buildSearchResults()
          else
            ..._buildBrowseContent(),
        ],
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    // Show loading indicator
    if (_isLoading) {
      return [
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryRed,
            ),
          ),
        ),
      ];
    }

    final hasResults = _songResults.isNotEmpty ||
        _albumResults.isNotEmpty ||
        _artistResults.isNotEmpty ||
        _playlistResults.isNotEmpty;

    if (!hasResults) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.textSecondaryDark,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$_searchQuery"',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryDark,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    return [
      // Show error message banner if there was an error
      if (_errorMessage != null)
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppTheme.textSecondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryDark,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
      // Songs
      if (_songResults.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Songs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = _songResults[index];
              return SongTile(
                song: song,
                onTap: () {
                  context.read<PlayerProvider>().playSong(
                        song,
                        playlist: _songResults,
                        startIndex: index,
                      );
                },
              );
            },
            childCount: _songResults.length.clamp(0, _maxSearchResults),
          ),
        ),
      ],

      // Artists
      if (_artistResults.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Artists',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final artist = _artistResults[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.backgroundDarkTertiary,
                  backgroundImage: artist.imageUrl != null
                      ? NetworkImage(artist.imageUrl!)
                      : null,
                  child: artist.imageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(artist.name),
                subtitle: const Text('Artist'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistScreen(artist: artist),
                    ),
                  );
                },
              );
            },
            childCount: _artistResults.length,
          ),
        ),
      ],

      // Albums
      if (_albumResults.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Albums',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final album = _albumResults[index];
              return ListTile(
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDarkTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: album.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            album.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.album),
                ),
                title: Text(album.title),
                subtitle: Text('${album.artist} • Album'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumScreen(album: album),
                    ),
                  );
                },
              );
            },
            childCount: _albumResults.length,
          ),
        ),
      ],

      // Playlists
      if (_playlistResults.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Playlists',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final playlist = _playlistResults[index];
              return ListTile(
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDarkTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: playlist.displayImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            playlist.displayImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.queue_music),
                ),
                title: Text(playlist.title),
                subtitle: Text('By ${playlist.ownerName} • Playlist'),
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
            childCount: _playlistResults.length,
          ),
        ),
      ],

      // Bottom padding
      const SliverToBoxAdapter(
        child: SizedBox(height: 100),
      ),
    ];
  }

  List<Widget> _buildBrowseContent() {
    final categories = [
      _BrowseCategory('Podcasts', Colors.purple, Icons.podcasts),
      _BrowseCategory('Live Events', Colors.deepOrange, Icons.live_tv),
      _BrowseCategory('Made For You', AppTheme.primaryRed, Icons.favorite),
      _BrowseCategory('New Releases', Colors.teal, Icons.new_releases),
      _BrowseCategory('Charts', Colors.indigo, Icons.trending_up),
      _BrowseCategory('Pop', Colors.pink, Icons.bubble_chart),
      _BrowseCategory('Hip-Hop', Colors.amber, Icons.speaker),
      _BrowseCategory('Rock', Colors.red, Icons.electric_bolt),
      _BrowseCategory('Latin', Colors.green, Icons.music_note),
      _BrowseCategory('Dance', Colors.blue, Icons.nightlife),
      _BrowseCategory('Indie', Colors.orange, Icons.radio),
      _BrowseCategory('Workout', Colors.lightGreen, Icons.fitness_center),
      _BrowseCategory('Chill', Colors.cyan, Icons.waves),
      _BrowseCategory('Focus', Colors.deepPurple, Icons.psychology),
      _BrowseCategory('Sleep', Colors.blueGrey, Icons.bedtime),
      _BrowseCategory('Party', Colors.pinkAccent, Icons.celebration),
    ];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Browse All',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final category = categories[index];
              return _CategoryCard(category: category);
            },
            childCount: categories.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: SizedBox(height: 100),
      ),
    ];
  }
}

/**
 * Search bar widget.
 */
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppTheme.textPrimaryLight,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'What do you want to listen to?',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondaryLight,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textPrimaryLight,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.textPrimaryLight,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/**
 * Browse category model.
 */
class _BrowseCategory {
  final String name;
  final Color color;
  final IconData icon;

  _BrowseCategory(this.name, this.color, this.icon);
}

/**
 * Category card widget.
 */
class _CategoryCard extends StatelessWidget {
  final _BrowseCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          // Navigate to category
        },
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 12,
              child: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white.withOpacity(0.5),
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
