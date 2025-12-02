import 'package:flutter/foundation.dart';
import '../models/song.dart';

/// Enum representing the current playback state
enum PlaybackState {
  stopped,
  playing,
  paused,
  buffering,
}

/// Enum representing the repeat mode
enum RepeatMode {
  off,
  all,
  one,
}

/// Provider for managing audio playback state
class PlayerProvider extends ChangeNotifier {
  // Current playback state
  PlaybackState _playbackState = PlaybackState.stopped;
  
  // Current song being played
  Song? _currentSong;
  
  // Queue of songs
  List<Song> _queue = [];
  
  // Current position in queue
  int _currentIndex = 0;
  
  // Playback position
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  // Volume (0.0 to 1.0)
  double _volume = 1.0;
  
  // Playback settings
  bool _shuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;
  
  // Original queue order (for shuffle)
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

  /// Progress of current playback (0.0 to 1.0)
  double get progress {
    if (_duration == Duration.zero) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  /// Play a song
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

  /// Toggle play/pause
  void togglePlayPause() {
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.paused;
    } else if (_playbackState == PlaybackState.paused) {
      _playbackState = PlaybackState.playing;
    }
    notifyListeners();
  }

  /// Pause playback
  void pause() {
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.paused;
      notifyListeners();
    }
  }

  /// Resume playback
  void play() {
    if (_currentSong != null && _playbackState == PlaybackState.paused) {
      _playbackState = PlaybackState.playing;
      notifyListeners();
    }
  }

  /// Stop playback
  void stop() {
    _playbackState = PlaybackState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  /// Skip to next song
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

  /// Skip to previous song
  void skipPrevious() {
    if (_queue.isEmpty) return;
    
    // If more than 3 seconds have passed, restart current song
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

  /// Seek to position
  void seekTo(Duration position) {
    _position = position;
    notifyListeners();
  }

  /// Seek to position by percentage (0.0 to 1.0)
  void seekToPercent(double percent) {
    final newPosition = Duration(
      milliseconds: (_duration.inMilliseconds * percent).round(),
    );
    _position = newPosition;
    notifyListeners();
  }

  /// Set volume
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffle = !_shuffle;
    
    if (_shuffle) {
      // Shuffle queue but keep current song
      final currentSong = _currentSong;
      _queue.shuffle();
      if (currentSong != null) {
        _queue.remove(currentSong);
        _queue.insert(0, currentSong);
        _currentIndex = 0;
      }
    } else {
      // Restore original order
      final currentSong = _currentSong;
      _queue = List.from(_originalQueue);
      if (currentSong != null) {
        _currentIndex = _queue.indexWhere((s) => s.id == currentSong.id);
        if (_currentIndex < 0) _currentIndex = 0;
      }
    }
    
    notifyListeners();
  }

  /// Toggle repeat mode
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

  /// Add song to queue
  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    notifyListeners();
  }

  /// Add song to play next
  void playNext(Song song) {
    _queue.insert(_currentIndex + 1, song);
    _originalQueue.insert(_currentIndex + 1, song);
    notifyListeners();
  }

  /// Remove song from queue
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

  /// Clear queue
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

  /// Play song at specific index in queue
  void playAtIndex(int index) {
    if (index < 0 || index >= _queue.length) return;
    
    _currentIndex = index;
    _currentSong = _queue[index];
    _position = Duration.zero;
    _duration = _currentSong?.duration ?? Duration.zero;
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  /// Update position (called by audio service)
  void updatePosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  /// Update duration (called by audio service)
  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  /// Update playback state
  void updatePlaybackState(PlaybackState state) {
    _playbackState = state;
    notifyListeners();
  }
}
