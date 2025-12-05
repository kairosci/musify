import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../screens/player_screen.dart';

/**
 * Mini player widget shown at the bottom of the screen.
 * 
 * Displays the currently playing song with basic controls
 * and navigates to the full player screen when tapped.
 */
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final song = playerProvider.currentSong;
        
        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkSecondary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: playerProvider.progress.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.backgroundDarkTertiary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryRed,
                  ),
                  minHeight: 2,
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Album art
                        Container(
                          width: 48,
                          height: 48,
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
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Like button
                        Consumer<LibraryProvider>(
                          builder: (context, library, child) {
                            final isLiked = library.isLiked(song);
                            return IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? AppTheme.primaryRed : null,
                                size: 22,
                              ),
                              onPressed: () => library.toggleLike(song),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            );
                          },
                        ),
                        
                        // Play/Pause button
                        IconButton(
                          icon: Icon(
                            playerProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 28,
                          ),
                          onPressed: () => playerProvider.togglePlayPause(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
