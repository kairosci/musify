import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../utils/app_theme.dart';

/// Artist card widget for horizontal lists (circular style)
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Column(
          children: [
            // Artist image (circular)
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkTertiary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: artist.imageUrl != null
                    ? Image.network(
                        artist.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: AppTheme.textSecondaryDark,
                          size: 48,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppTheme.textSecondaryDark,
                        size: 48,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Artist name
            Text(
              artist.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            // Artist label
            Text(
              'Artist',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
