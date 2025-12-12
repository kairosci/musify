import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

/**
 * Enum representing the repeat mode setting.
 */
enum RepeatMode {
  off,
  all,
  one,
}

/**
 * Provider for managing audio playback state.
 * 
 * Handles all playback operations including play, pause, skip,
 * seek, shuffle, repeat, and queue management. Notifies listeners
 * of any state changes for UI updates.
 * 
 * This provider acts as a bridge between the UI and the AudioPlayerService,
 * managing state and exposing playback controls to the UI.
 */
class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  
  PlaybackState _playbackState = PlaybackState.stopped;
  
  Song? _currentSong;
  
  List<Song> _queue = [];
  
  int _currentIndex = 0;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  double _volume = 1.0;
  
  bool _shuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;
  
  List<Song> _originalQueue = [];
  
  bool _initialized = false;

  // Getters
  PlaybackState get playbackState => _playbackState;
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get shuffle => _shuffle;
  RepeatMode get repeatMode => _repeatMode;
  
  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get isPaused => _playbackState == PlaybackState.paused;
  bool get isBuffering => _playbackState == PlaybackState.buffering;
  bool get hasQueue => _queue.isNotEmpty;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _queue.length - 1;

  /**
   * Initializes the audio player service and sets up listeners.
   */
  Future<void> initialize() async {
    if (_initialized) return;
    
    await _audioService.initialize();
    
    // Listen to playback state changes
    _audioService.playbackStateStream.listen((state) {
      _playbackState = state;
      notifyListeners();
    });
    
    // Listen to position changes
    _audioService.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    
    // Listen to duration changes
    _audioService.durationStream.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
    
    // Listen to current song changes
    _audioService.currentSongStream.listen((song) {
      _currentSong = song;
      notifyListeners();
    });
    
    _initialized = true;
  }

  /**
   * Returns playback progress as a value between 0.0 and 1.0.
   */
  double get progress {
    if (_duration == Duration.zero) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  /**
   * Starts playing a song, optionally with a playlist context.
   */
  Future<void> playSong(Song song, {List<Song>? playlist, int startIndex = 0}) async {
    if (playlist != null && playlist.isNotEmpty) {
      _queue = List.from(playlist);
      _originalQueue = List.from(playlist);
      _currentIndex = startIndex;
    } else {
      _queue = [song];
      _originalQueue = [song];
      _currentIndex = 0;
    }
    
    _currentSong = song;
    notifyListeners();
    
    // Use audio service to actually play the song
    await _audioService.playSong(song, playlist: _queue, startIndex: _currentIndex);
    
    // Apply current repeat mode
    await _applyRepeatMode();
  }

  /**
   * Toggles between play and pause states.
   */
  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  /**
   * Pauses playback if currently playing.
   */
  Future<void> pause() async {
    await _audioService.pause();
  }

  /**
   * Resumes playback if currently paused.
   */
  Future<void> play() async {
    await _audioService.play();
  }

  /**
   * Stops playback and resets position.
   */
  Future<void> stop() async {
    await _audioService.stop();
    _playbackState = PlaybackState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  /**
   * Internal helper to play a song at a specific index.
   */
  Future<void> _playAtIndexInternal(int index) async {
    _currentIndex = index;
    _currentSong = _queue[_currentIndex];
    await _audioService.playAtIndex(_currentIndex);
    notifyListeners();
  }

  /**
   * Skips to the next song in the queue.
   * Handles repeat mode to loop back to start if needed.
   */
  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    
    if (_currentIndex < _queue.length - 1) {
      await _playAtIndexInternal(_currentIndex + 1);
    } else if (_repeatMode == RepeatMode.all) {
      await _playAtIndexInternal(0);
    }
  }

  /**
   * Skips to the previous song or restarts current song.
   * Restarts if more than 3 seconds have played, otherwise goes to previous.
   */
  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    
    if (_position.inSeconds > 3) {
      await _audioService.seekTo(Duration.zero);
    } else if (_currentIndex > 0) {
      await _playAtIndexInternal(_currentIndex - 1);
    } else if (_repeatMode == RepeatMode.all) {
      await _playAtIndexInternal(_queue.length - 1);
    }
  }

  /**
   * Seeks to a specific position in the current track.
   */
  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
  }

  /**
   * Seeks to a position based on percentage (0.0 to 1.0).
   */
  Future<void> seekToPercent(double percent) async {
    final newPosition = Duration(
      milliseconds: (_duration.inMilliseconds * percent).round(),
    );
    await _audioService.seekTo(newPosition);
  }

  /**
   * Sets the playback volume (0.0 to 1.0).
   */
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    notifyListeners();
  }

  /**
   * Toggles shuffle mode on/off.
   * When enabled, shuffles queue while keeping current song first.
   * When disabled, restores original queue order.
   */
  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    
    if (_shuffle) {
      final currentSong = _currentSong;
      _queue.shuffle();
      if (currentSong != null) {
        _queue.remove(currentSong);
        _queue.insert(0, currentSong);
        _currentIndex = 0;
      }
    } else {
      final currentSong = _currentSong;
      _queue = List.from(_originalQueue);
      if (currentSong != null) {
        _currentIndex = _queue.indexWhere((s) => s.id == currentSong.id);
        if (_currentIndex < 0) _currentIndex = 0;
      }
    }
    
    await _audioService.setShuffleMode(_shuffle);
    notifyListeners();
  }

  /**
   * Cycles through repeat modes: off -> all -> one -> off.
   */
  Future<void> toggleRepeat() async {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    await _applyRepeatMode();
    notifyListeners();
  }

  /**
   * Applies the current repeat mode to the audio player.
   */
  Future<void> _applyRepeatMode() async {
    switch (_repeatMode) {
      case RepeatMode.off:
        await _audioService.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.all:
        await _audioService.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.one:
        await _audioService.setLoopMode(LoopMode.one);
        break;
    }
  }

  /**
   * Adds a song to the end of the queue.
   */
  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    _audioService.addToQueue(song);
    notifyListeners();
  }

  /**
   * Inserts a song to play immediately after the current song.
   */
  void playNext(Song song) {
    _queue.insert(_currentIndex + 1, song);
    _originalQueue.insert(_currentIndex + 1, song);
    _audioService.playNext(song);
    notifyListeners();
  }

  /**
   * Removes a song from the queue at the specified index.
   */
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    
    _queue.removeAt(index);
    _audioService.removeFromQueue(index);
    
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _queue.isNotEmpty) {
      _currentSong = _queue[_currentIndex.clamp(0, _queue.length - 1)];
    }
    notifyListeners();
  }

  /**
   * Clears the entire queue and stops playback.
   */
  Future<void> clearQueue() async {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = 0;
    _currentSong = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    
    await _audioService.stop();
    _audioService.clearQueue();
    
    _playbackState = PlaybackState.stopped;
    notifyListeners();
  }

  /**
   * Plays the song at a specific index in the queue.
   */
  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    
    _currentIndex = index;
    _currentSong = _queue[index];
    await _audioService.playAtIndex(index);
    notifyListeners();
  }

  /**
   * Updates the current playback position.
   * Called by the audio service during playback.
   */
  void updatePosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  /**
   * Updates the total duration of the current track.
   * Called by the audio service when track metadata is loaded.
   */
  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  /**
   * Updates the current playback state.
   * Called by the audio service when playback state changes.
   */
  void updatePlaybackState(PlaybackState state) {
    _playbackState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
