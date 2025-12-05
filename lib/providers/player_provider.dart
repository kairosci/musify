import 'package:flutter/foundation.dart';
import '../models/song.dart';

/**
 * Enum representing the current playback state of the audio player.
 */
enum PlaybackState {
  stopped,
  playing,
  paused,
  buffering,
}

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
 */
class PlayerProvider extends ChangeNotifier {
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
   * Returns playback progress as a value between 0.0 and 1.0.
   */
  double get progress {
    if (_duration == Duration.zero) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  /**
   * Starts playing a song, optionally with a playlist context.
   */
  void playSong(Song song, {List<Song>? playlist, int startIndex = 0}) {
    if (playlist != null && playlist.isNotEmpty) {
      _queue = List.from(playlist);
      _originalQueue = List.from(playlist);
      _currentIndex = startIndex;
      _currentSong = _queue[_currentIndex];
    } else {
      _queue = [song];
      _originalQueue = [song];
      _currentIndex = 0;
      _currentSong = song;
    }
    
    _playbackState = PlaybackState.playing;
    _position = Duration.zero;
    _duration = song.duration;
    notifyListeners();
  }

  /**
   * Toggles between play and pause states.
   */
  void togglePlayPause() {
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.paused;
    } else if (_playbackState == PlaybackState.paused) {
      _playbackState = PlaybackState.playing;
    }
    notifyListeners();
  }

  /**
   * Pauses playback if currently playing.
   */
  void pause() {
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.paused;
      notifyListeners();
    }
  }

  /**
   * Resumes playback if currently paused.
   */
  void play() {
    if (_currentSong != null && _playbackState == PlaybackState.paused) {
      _playbackState = PlaybackState.playing;
      notifyListeners();
    }
  }

  /**
   * Stops playback and resets position.
   */
  void stop() {
    _playbackState = PlaybackState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  /**
   * Skips to the next song in the queue.
   * Handles repeat mode to loop back to start if needed.
   */
  void skipNext() {
    if (_queue.isEmpty) return;
    
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = 0;
    } else {
      return;
    }
    
    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _duration = _currentSong?.duration ?? Duration.zero;
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  /**
   * Skips to the previous song or restarts current song.
   * Restarts if more than 3 seconds have played, otherwise goes to previous.
   */
  void skipPrevious() {
    if (_queue.isEmpty) return;
    
    if (_position.inSeconds > 3) {
      _position = Duration.zero;
    } else if (_currentIndex > 0) {
      _currentIndex--;
      _currentSong = _queue[_currentIndex];
      _position = Duration.zero;
      _duration = _currentSong?.duration ?? Duration.zero;
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = _queue.length - 1;
      _currentSong = _queue[_currentIndex];
      _position = Duration.zero;
      _duration = _currentSong?.duration ?? Duration.zero;
    }
    
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  /**
   * Seeks to a specific position in the current track.
   */
  void seekTo(Duration position) {
    _position = position;
    notifyListeners();
  }

  /**
   * Seeks to a position based on percentage (0.0 to 1.0).
   */
  void seekToPercent(double percent) {
    final newPosition = Duration(
      milliseconds: (_duration.inMilliseconds * percent).round(),
    );
    _position = newPosition;
    notifyListeners();
  }

  /**
   * Sets the playback volume (0.0 to 1.0).
   */
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /**
   * Toggles shuffle mode on/off.
   * When enabled, shuffles queue while keeping current song first.
   * When disabled, restores original queue order.
   */
  void toggleShuffle() {
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
    
    notifyListeners();
  }

  /**
   * Cycles through repeat modes: off -> all -> one -> off.
   */
  void toggleRepeat() {
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
    notifyListeners();
  }

  /**
   * Adds a song to the end of the queue.
   */
  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    notifyListeners();
  }

  /**
   * Inserts a song to play immediately after the current song.
   */
  void playNext(Song song) {
    _queue.insert(_currentIndex + 1, song);
    _originalQueue.insert(_currentIndex + 1, song);
    notifyListeners();
  }

  /**
   * Removes a song from the queue at the specified index.
   */
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    
    _queue.removeAt(index);
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
  void clearQueue() {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = 0;
    _currentSong = null;
    _playbackState = PlaybackState.stopped;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  /**
   * Plays the song at a specific index in the queue.
   */
  void playAtIndex(int index) {
    if (index < 0 || index >= _queue.length) return;
    
    _currentIndex = index;
    _currentSong = _queue[index];
    _position = Duration.zero;
    _duration = _currentSong?.duration ?? Duration.zero;
    _playbackState = PlaybackState.playing;
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
}
