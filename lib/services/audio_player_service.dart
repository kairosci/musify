import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song.dart';
import 'piped_service.dart';

/**
 * Service for managing audio playback using just_audio.
 * 
 * This service handles the actual audio playback, integrating with
 * the Piped API to fetch audio stream URLs and play them using just_audio.
 * Supports background playback, audio session management, and system
 * media controls.
 */
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;

  // Stream controllers for state updates
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentSongController = StreamController<Song?>.broadcast();

  // Getters for streams
  Stream<PlaybackState> get playbackStateStream => _playbackStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  // Getters for current state
  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  /**
   * Initializes the audio player service.
   * Sets up player listeners and audio session.
   */
  Future<void> initialize() async {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      _playbackStateController.add(_mapPlayerState(state));
      
      // Auto-advance to next song when current finishes
      if (state.processingState == ProcessingState.completed) {
        skipNext();
      }
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      if (duration != null) {
        _durationController.add(duration);
      }
    });
  }

  /**
   * Maps just_audio PlayerState to our PlaybackState enum.
   */
  PlaybackState _mapPlayerState(PlayerState state) {
    if (state.playing) {
      return PlaybackState.playing;
    } else if (state.processingState == ProcessingState.buffering ||
        state.processingState == ProcessingState.loading) {
      return PlaybackState.buffering;
    } else {
      return PlaybackState.paused;
    }
  }

  /**
   * Plays a song by fetching its audio stream URL from Piped.
   */
  Future<void> playSong(Song song, {List<Song>? playlist, int startIndex = 0}) async {
    try {
      if (playlist != null && playlist.isNotEmpty) {
        _queue = List.from(playlist);
        _currentIndex = startIndex;
        _currentSong = _queue[_currentIndex];
      } else {
        _queue = [song];
        _currentIndex = 0;
        _currentSong = song;
      }

      _currentSongController.add(_currentSong);

      // Fetch audio stream URL from Piped if not already available
      String? audioUrl = _currentSong?.audioUrl;
      
      if (audioUrl == null || audioUrl.isEmpty) {
        final streamInfo = await PipedService.getAudioStream(_currentSong!.id);
        audioUrl = streamInfo.bestAudioUrl;
        
        if (audioUrl == null) {
          throw Exception('No audio stream available for this song');
        }
        
        // Update current song with fetched audio URL
        _currentSong = _currentSong!.copyWith(audioUrl: audioUrl);
        _currentSongController.add(_currentSong);
      }

      // Set audio source and play
      await _player.setUrl(audioUrl);
      await _player.play();
      
    } catch (e) {
      // Error handling - state updated to stopped
      _playbackStateController.add(PlaybackState.stopped);
      rethrow;
    }
  }

  /**
   * Toggles between play and pause states.
   */
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /**
   * Pauses playback.
   */
  Future<void> pause() async {
    await _player.pause();
  }

  /**
   * Resumes playback.
   */
  Future<void> play() async {
    await _player.play();
  }

  /**
   * Stops playback and resets position.
   */
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  /**
   * Skips to the next song in the queue.
   */
  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      final nextSong = _queue[_currentIndex];
      await playSong(nextSong);
    }
  }

  /**
   * Skips to the previous song or restarts current song.
   */
  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    
    if (_player.position.inSeconds > 3) {
      // Restart current song if more than 3 seconds in
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      // Go to previous song
      _currentIndex--;
      final previousSong = _queue[_currentIndex];
      await playSong(previousSong);
    }
  }

  /**
   * Seeks to a specific position in the current track.
   */
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /**
   * Sets the playback volume (0.0 to 1.0).
   */
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /**
   * Sets the playback speed (0.5 to 2.0).
   */
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  /**
   * Sets the loop mode.
   */
  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  /**
   * Enables or disables shuffle mode.
   */
  Future<void> setShuffleMode(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  /**
   * Adds a song to the end of the queue.
   */
  void addToQueue(Song song) {
    _queue.add(song);
  }

  /**
   * Inserts a song to play immediately after the current song.
   */
  void playNext(Song song) {
    if (_currentIndex < _queue.length - 1) {
      _queue.insert(_currentIndex + 1, song);
    } else {
      _queue.add(song);
    }
  }

  /**
   * Removes a song from the queue at the specified index.
   */
  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length && index != _currentIndex) {
      _queue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
    }
  }

  /**
   * Clears the entire queue.
   */
  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    _currentSong = null;
    _currentSongController.add(null);
  }

  /**
   * Plays the song at a specific index in the queue.
   */
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await playSong(_queue[index]);
    }
  }

  /**
   * Preloads the next song in the queue for seamless playback.
   */
  Future<void> preloadNext() async {
    if (_currentIndex < _queue.length - 1) {
      final nextSong = _queue[_currentIndex + 1];
      if (nextSong.audioUrl == null || nextSong.audioUrl!.isEmpty) {
        try {
          final streamInfo = await PipedService.getAudioStream(nextSong.id);
          final audioUrl = streamInfo.bestAudioUrl;
          if (audioUrl != null) {
            _queue[_currentIndex + 1] = nextSong.copyWith(audioUrl: audioUrl);
          }
        } catch (e) {
          // Silently fail preloading - will retry on actual playback
        }
      }
    }
  }

  /**
   * Disposes of the audio player and closes streams.
   */
  Future<void> dispose() async {
    await _player.dispose();
    await _playbackStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _currentSongController.close();
  }
}

/**
 * Enum representing the current playback state of the audio player.
 */
enum PlaybackState {
  stopped,
  playing,
  paused,
  buffering,
}
