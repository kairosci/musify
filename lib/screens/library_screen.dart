import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../utils/sample_data.dart';
import '../utils/app_theme.dart';
import 'playlist_screen.dart';
import 'album_screen.dart';
import 'artist_screen.dart';

/// Library screen showing user's saved content
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              title: const Text('Your Library'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreatePlaylistDialog(context),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: _FilterChips(
                  selected: _selectedFilter,
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ),
            ),
          ];
        },
        body: Consumer<LibraryProvider>(
          builder: (context, libraryProvider, child) {
            return _buildContent(libraryProvider);
          },
        ),
      ),
    );
  }

  Widget _buildContent(LibraryProvider library) {
    final allItems = <_LibraryItem>[];

    // Add liked songs as first item
    if (library.likedSongs.isNotEmpty) {
      allItems.add(_LibraryItem(
        type: 'liked',
        title: 'Liked Songs',
        subtitle: '${library.likedSongs.length} songs',
        imageUrl: null,
        item: library.likedSongs,
      ));
    } else {
      // Add sample liked songs
      allItems.add(_LibraryItem(
        type: 'liked',
        title: 'Liked Songs',
        subtitle: '${SampleData.songs.length} songs',
        imageUrl: null,
        item: SampleData.songs,
      ));
    }

    // Add playlists
    final playlists =
        library.playlists.isEmpty ? SampleData.playlists : library.playlists;
    for (final playlist in playlists) {
      if (_selectedFilter == 'all' || _selectedFilter == 'playlists') {
        allItems.add(_LibraryItem(
          type: 'playlist',
          title: playlist.title,
          subtitle: 'Playlist • ${playlist.ownerName}',
          imageUrl: playlist.displayImage,
          item: playlist,
        ));
      }
    }

    // Add albums
    final albums =
        library.savedAlbums.isEmpty ? SampleData.albums : library.savedAlbums;
    for (final album in albums) {
      if (_selectedFilter == 'all' || _selectedFilter == 'albums') {
        allItems.add(_LibraryItem(
          type: 'album',
          title: album.title,
          subtitle: 'Album • ${album.artist}',
          imageUrl: album.imageUrl,
          item: album,
        ));
      }
    }

    // Add artists
    final artists = library.followedArtists.isEmpty
        ? SampleData.artists
        : library.followedArtists;
    for (final artist in artists) {
      if (_selectedFilter == 'all' || _selectedFilter == 'artists') {
        allItems.add(_LibraryItem(
          type: 'artist',
          title: artist.name,
          subtitle: 'Artist',
          imageUrl: artist.imageUrl,
          item: artist,
        ));
      }
    }

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music_outlined,
              size: 64,
              color: AppTheme.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Your library is empty',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Find something to listen to',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return _LibraryListItem(
          item: item,
          onTap: () => _onItemTap(item),
        );
      },
    );
  }

  void _onItemTap(_LibraryItem item) {
    switch (item.type) {
      case 'liked':
        // Navigate to liked songs
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistScreen(
              playlist: Playlist(
                id: 'liked',
                title: 'Liked Songs',
                ownerName: 'You',
                songs: item.item as List<Song>,
                createdAt: DateTime.now(),
              ),
              isLikedSongs: true,
            ),
          ),
        );
        break;
      case 'playlist':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PlaylistScreen(playlist: item.item as Playlist),
          ),
        );
        break;
      case 'album':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumScreen(album: item.item as Album),
          ),
        );
        break;
      case 'artist':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistScreen(artist: item.item as Artist),
          ),
        );
        break;
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkSecondary,
        title: const Text('Create Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<LibraryProvider>()
                    .createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Create',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chips for library
class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == 'all',
            onTap: () => onSelected('all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Playlists',
            isSelected: selected == 'playlists',
            onTap: () => onSelected('playlists'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Albums',
            isSelected: selected == 'albums',
            onTap: () => onSelected('albums'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Artists',
            isSelected: selected == 'artists',
            onTap: () => onSelected('artists'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Downloaded',
            isSelected: selected == 'downloaded',
            onTap: () => onSelected('downloaded'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRed
              : AppTheme.backgroundDarkTertiary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Library item model
class _LibraryItem {
  final String type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final dynamic item;

  _LibraryItem({
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.item,
  });
}

/// Library list item widget
class _LibraryListItem extends StatelessWidget {
  final _LibraryItem item;
  final VoidCallback onTap;

  const _LibraryListItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _buildLeading(),
      title: Text(
        item.title,
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (item.type == 'liked')
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.push_pin,
                size: 14,
                color: AppTheme.primaryRed,
              ),
            ),
          Text(
            item.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLeading() {
    if (item.type == 'liked') {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.redGradient,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
        ),
      );
    }

    if (item.type == 'artist') {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.backgroundDarkTertiary,
        backgroundImage:
            item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
        child: item.imageUrl == null ? const Icon(Icons.person) : null,
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: item.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    IconData icon;
    switch (item.type) {
      case 'playlist':
        icon = Icons.queue_music;
        break;
      case 'album':
        icon = Icons.album;
        break;
      default:
        icon = Icons.music_note;
    }
    return Icon(icon, color: AppTheme.textSecondaryDark);
  }
}
