import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'piped_service.dart';

/**
 * Custom audio handler for background playback and media controls.
 * 
 * This handler integrates with the system's media controls (notifications,
 * lock screen, headset buttons) to provide a native music player experience.
 * Supports play, pause, skip, seek, and displays rich media information.
 */
class FlyerAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  
  List<MediaItem> _queue = [];
  int _currentIndex = 0;

  FlyerAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Listen to player state changes and update playback state
    _player.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      final processingState = _mapProcessingState(state.processingState);
      
      playbackState.add(playbackState.value.copyWith(
        playing: isPlaying,
        processingState: processingState,
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
      ));
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      if (duration != null && _currentIndex < _queue.length) {
        final updatedItem = _queue[_currentIndex].copyWith(duration: duration);
        _queue[_currentIndex] = updatedItem;
        mediaItem.add(updatedItem);
      }
    });

    // Auto-advance to next song when current finishes
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });

    // Initialize playback state
    playbackState.add(PlaybackState(
      playing: false,
      processingState: AudioProcessingState.idle,
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlaySong(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlaySong(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await _loadAndPlaySong(_queue[index]);
    }
  }

  /**
   * Plays a song with optional queue context.
   */
  Future<void> playSong(Song song, {List<Song>? playlist, int startIndex = 0}) async {
    if (playlist != null && playlist.isNotEmpty) {
      _queue = playlist.map((s) => _songToMediaItem(s)).toList();
      _currentIndex = startIndex;
    } else {
      _queue = [_songToMediaItem(song)];
      _currentIndex = 0;
    }

    queue.add(_queue);
    await _loadAndPlaySong(_queue[_currentIndex]);
  }

  Future<void> _loadAndPlaySong(MediaItem item) async {
    try {
      mediaItem.add(item);
      
      // Fetch audio URL if needed
      String? audioUrl = item.extras?['audioUrl'] as String?;
      
      if (audioUrl == null || audioUrl.isEmpty) {
        final videoId = item.id;
        final streamInfo = await PipedService.getAudioStream(videoId);
        audioUrl = streamInfo.bestAudioUrl;
        
        if (audioUrl == null) {
          throw Exception('No audio stream available');
        }
      }

      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
      ));
    }
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: song.imageUrl != null ? Uri.parse(song.imageUrl!) : null,
      duration: song.duration,
      extras: {
        'audioUrl': song.audioUrl ?? '',
      },
    );
  }

  /**
   * Adds a song to the queue.
   */
  Future<void> addToQueue(Song song) async {
    _queue.add(_songToMediaItem(song));
    queue.add(_queue);
  }

  /**
   * Inserts a song to play next.
   */
  Future<void> playNext(Song song) async {
    if (_currentIndex < _queue.length - 1) {
      _queue.insert(_currentIndex + 1, _songToMediaItem(song));
    } else {
      _queue.add(_songToMediaItem(song));
    }
    queue.add(_queue);
  }

  /**
   * Removes an item from the queue.
   */
  Future<void> removeQueueItemAt(int index) async {
    if (index >= 0 && index < _queue.length && index != _currentIndex) {
      _queue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
      queue.add(_queue);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    await _player.setShuffleModeEnabled(
      shuffleMode == AudioServiceShuffleMode.all,
    );
  }

  AudioPlayer get player => _player;
}
