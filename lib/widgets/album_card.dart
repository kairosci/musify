import 'package:flutter/material.dart';
import '../models/album.dart';
import '../utils/app_theme.dart';

/**
 * Album card widget for horizontal lists.
 */
class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const AlbumCard({
    super.key,
    required this.album,
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
            // Album cover
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkTertiary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: album.imageUrl != null
                    ? Image.network(
                        album.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.album,
                          color: AppTheme.textSecondaryDark,
                          size: 48,
                        ),
                      )
                    : const Icon(
                        Icons.album,
                        color: AppTheme.textSecondaryDark,
                        size: 48,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Album title
            Text(
              album.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Artist name
            Text(
              '${album.year != null ? '${album.year} • ' : ''}${album.artist}',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
