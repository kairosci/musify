import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../utils/app_theme.dart';

/**
 * Playlist card widget for horizontal lists.
 */
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
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
            // Playlist cover
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: playlist.displayImage != null
                    ? Image.network(
                        playlist.displayImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.queue_music,
                          color: AppTheme.textSecondaryDark,
                          size: 48,
                        ),
                      )
                    : const Icon(
                        Icons.queue_music,
                        color: AppTheme.textSecondaryDark,
                        size: 48,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Playlist title
            Text(
              playlist.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Playlist description or owner
            Text(
              playlist.description ?? 'By ${playlist.ownerName}',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
