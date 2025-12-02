import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';

/// Song tile widget for lists
class SongTile extends StatelessWidget {
  final Song song;
  final int? index;
  final bool showAlbum;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    this.index,
    this.showAlbum = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final isPlaying = playerProvider.currentSong?.id == song.id &&
            playerProvider.isPlaying;

        return ListTile(
          onTap: onTap,
          onLongPress: () => _showOptions(context),
          leading: _buildLeading(context, isPlaying),
          title: Text(
            song.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isPlaying
                      ? AppTheme.primaryRed
                      : AppTheme.textPrimaryDark,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              if (song.isExplicit) ...[
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
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.backgroundDark,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  showAlbum && song.album != null
                      ? '${song.artist} • ${song.album}'
                      : song.artist,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        );
      },
    );
  }

  Widget _buildLeading(BuildContext context, bool isPlaying) {
    if (index != null) {
      return SizedBox(
        width: 50,
        child: Row(
          children: [
            if (isPlaying)
              Icon(
                Icons.equalizer,
                color: AppTheme.primaryRed,
                size: 20,
              )
            else
              Text(
                '$index',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDarkTertiary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: song.imageUrl != null
                      ? Image.network(
                          song.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.music_note,
                            size: 20,
                            color: AppTheme.textSecondaryDark,
                          ),
                        )
                      : const Icon(
                          Icons.music_note,
                          size: 20,
                          color: AppTheme.textSecondaryDark,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.imageUrl != null
            ? Image.network(
                song.imageUrl!,
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
          
          // Song info header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDarkTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: song.imageUrl != null
                        ? Image.network(song.imageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          Consumer<LibraryProvider>(
            builder: (context, library, child) {
              final isLiked = library.isLiked(song);
              return ListTile(
                leading: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppTheme.primaryRed : null,
                ),
                title: Text(isLiked ? 'Remove from Liked Songs' : 'Like'),
                onTap: () {
                  library.toggleLike(song);
                  Navigator.pop(context);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to playlist'),
            onTap: () {
              Navigator.pop(context);
              _showPlaylistPicker(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: const Text('Add to queue'),
            onTap: () {
              context.read<PlayerProvider>().addToQueue(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Play next'),
            onTap: () {
              context.read<PlayerProvider>().playNext(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Will play next')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Go to artist'),
            onTap: () => Navigator.pop(context),
          ),
          if (song.album != null)
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Go to album'),
              onTap: () => Navigator.pop(context),
            ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPlaylistPicker(BuildContext context) {
    final library = context.read<LibraryProvider>();
    
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to playlist',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreatePlaylistDialog(context);
                  },
                  child: const Text('New Playlist'),
                ),
              ],
            ),
          ),
          const Divider(),
          if (library.playlists.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No playlists yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...library.playlists.map((playlist) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDarkTertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.queue_music),
                  ),
                  title: Text(playlist.title),
                  subtitle: Text('${playlist.songCount} songs'),
                  onTap: () {
                    library.addSongToPlaylist(playlist.id, song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Added to ${playlist.title}')),
                    );
                  },
                )),
          const SizedBox(height: 16),
        ],
      ),
    );
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
                final library = context.read<LibraryProvider>();
                library.createPlaylist(controller.text);
                // Add song to newly created playlist
                if (library.playlists.isNotEmpty) {
                  library.addSongToPlaylist(library.playlists.first.id, song);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Created "${controller.text}" and added song')),
                );
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
