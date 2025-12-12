# Audio Playback Implementation

This document describes the real audio playback functionality implemented using just_audio and Piped API integration.

## Architecture

The audio playback system consists of three main components:

### 1. AudioPlayerService (`lib/services/audio_player_service.dart`)
- Core audio playback service using just_audio
- Handles direct interaction with the audio player
- Manages audio stream fetching from Piped API
- Provides streams for state updates (playback state, position, duration, current song)
- Features:
  - Automatic audio URL fetching from Piped when not cached
  - Queue management
  - Preloading for seamless playback
  - Volume and speed controls

### 2. FlyerAudioHandler (`lib/services/audio_handler.dart`)
- Background audio handler using audio_service
- Enables system media controls (notifications, lock screen)
- Integrates with OS media session
- Provides native player experience
- Features:
  - Rich media notifications
  - Headset/Bluetooth control support
  - Lock screen controls
  - Auto-advance to next track

### 3. PlayerProvider (`lib/providers/player_provider.dart`)
- State management layer using Provider pattern
- Bridges UI and audio services
- Manages playback state for the entire app
- Features:
  - Queue management (add, remove, reorder)
  - Shuffle and repeat modes
  - Playback controls (play, pause, skip, seek)
  - Volume control

## How It Works

### Playing a Song

When a user plays a song:

1. UI calls `playerProvider.playSong(song)`
2. PlayerProvider updates local state and calls `audioService.playSong(song)`
3. AudioPlayerService checks if the song has an `audioUrl`
4. If no URL exists, it fetches the stream from Piped API via `PipedService.getAudioStream(videoId)`
5. The best quality audio stream is selected (prefers opus codec)
6. just_audio loads and plays the stream
7. State updates flow back through streams to update the UI

### Piped Integration

The Piped service provides:
- Search for music tracks, artists, albums, playlists
- Audio stream URLs at various quality levels
- Metadata (title, artist, duration, thumbnail)
- Related tracks for recommendations
- Automatic fallback between multiple Piped instances

### Background Playback

Background playback is enabled through:
- `audio_service` package for OS integration
- `FlyerAudioHandler` managing the audio session
- Proper Android permissions in AndroidManifest.xml
- Notification with media controls

## Usage Example

```dart
// Get the player provider
final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

// Initialize (done automatically in main.dart)
await playerProvider.initialize();

// Play a single song
await playerProvider.playSong(song);

// Play a song from a playlist
await playerProvider.playSong(
  song,
  playlist: playlistSongs,
  startIndex: 0,
);

// Control playback
await playerProvider.togglePlayPause();
await playerProvider.skipNext();
await playerProvider.skipPrevious();
await playerProvider.seekTo(Duration(seconds: 30));

// Manage queue
playerProvider.addToQueue(song);
playerProvider.playNext(song);
await playerProvider.playAtIndex(2);

// Toggle modes
await playerProvider.toggleShuffle();
await playerProvider.toggleRepeat(); // cycles: off -> all -> one -> off

// Volume control
await playerProvider.setVolume(0.8); // 0.0 to 1.0
```

## Search and Stream Flow

```dart
// 1. Search for music
final result = await PipedService.searchMusic('artist - song name');

// 2. Convert to Song model
final songs = result.items.map((item) => item.toSong()).toList();

// 3. Play the song
await playerProvider.playSong(songs.first, playlist: songs);

// Audio URL is fetched automatically during playback
```

## Key Features

### Automatic Stream URL Fetching
Songs don't need to have audio URLs pre-loaded. The service automatically fetches them from Piped when needed.

### Instance Fallback
If one Piped instance fails, the service automatically tries alternative instances to ensure reliability.

### Seamless Playback
The next song in queue is preloaded in the background for gapless playback.

### Rich Notifications
On Android, displays album art, title, artist with play/pause/skip controls in the notification.

### Background Playback
Music continues playing when the app is minimized or screen is locked.

### Queue Management
Full queue support with add, remove, reorder, play next, and play at index.

### Multiple Repeat Modes
- Off: Stop at end of queue
- All: Loop entire queue
- One: Repeat current song

## Technical Details

### Audio Format
- Preferred: Opus codec in WebM container (best quality/size ratio)
- Fallback: Highest bitrate available stream
- Streaming: Progressive download (no need to download entire file)

### State Management
- Uses Flutter Provider pattern
- Stream-based state updates
- Automatic UI updates through ChangeNotifier

### Error Handling
- Graceful degradation on stream fetch failure
- Automatic instance fallback
- Error state propagation to UI

## Future Enhancements

Potential improvements:
- Offline caching of frequently played songs
- Audio equalizer
- Crossfade between tracks
- Sleep timer
- Playlist radio (infinite playback with recommendations)
- Audio quality selection
- Bandwidth usage optimization
