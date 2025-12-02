import 'package:flutter_test/flutter_test.dart';
import 'package:flyer/providers/player_provider.dart';
import 'package:flyer/providers/library_provider.dart';
import 'package:flyer/providers/theme_provider.dart';
import 'package:flyer/models/song.dart';
import 'package:flyer/models/playlist.dart';
import 'package:flutter/material.dart';

void main() {
  group('PlayerProvider Tests', () {
    late PlayerProvider playerProvider;

    setUp(() {
      playerProvider = PlayerProvider();
    });

    test('Initial state should be stopped', () {
      expect(playerProvider.playbackState, PlaybackState.stopped);
      expect(playerProvider.currentSong, null);
      expect(playerProvider.isPlaying, false);
    });

    test('playSong should update state', () {
      final song = Song(
        id: 's1',
        title: 'Test Song',
        artist: 'Artist',
        duration: const Duration(minutes: 3),
      );

      playerProvider.playSong(song);

      expect(playerProvider.currentSong, song);
      expect(playerProvider.isPlaying, true);
      expect(playerProvider.playbackState, PlaybackState.playing);
    });

    test('togglePlayPause should toggle state', () {
      final song = Song(
        id: 's1',
        title: 'Test',
        artist: 'Artist',
      );

      playerProvider.playSong(song);
      expect(playerProvider.isPlaying, true);

      playerProvider.togglePlayPause();
      expect(playerProvider.isPaused, true);

      playerProvider.togglePlayPause();
      expect(playerProvider.isPlaying, true);
    });

    test('addToQueue should add song', () {
      final song = Song(id: 's1', title: 'Test', artist: 'Artist');
      
      playerProvider.playSong(song);
      final newSong = Song(id: 's2', title: 'New Song', artist: 'Artist');
      
      playerProvider.addToQueue(newSong);
      
      expect(playerProvider.queue.length, 2);
    });

    test('toggleShuffle should toggle shuffle mode', () {
      expect(playerProvider.shuffle, false);
      
      playerProvider.toggleShuffle();
      
      expect(playerProvider.shuffle, true);
    });

    test('toggleRepeat should cycle through modes', () {
      expect(playerProvider.repeatMode, RepeatMode.off);
      
      playerProvider.toggleRepeat();
      expect(playerProvider.repeatMode, RepeatMode.all);
      
      playerProvider.toggleRepeat();
      expect(playerProvider.repeatMode, RepeatMode.one);
      
      playerProvider.toggleRepeat();
      expect(playerProvider.repeatMode, RepeatMode.off);
    });
  });

  group('LibraryProvider Tests', () {
    late LibraryProvider libraryProvider;

    setUp(() {
      libraryProvider = LibraryProvider();
    });

    test('Initial library should be empty', () {
      expect(libraryProvider.likedSongs, isEmpty);
      expect(libraryProvider.playlists, isEmpty);
    });

    test('toggleLike should add/remove song', () {
      final song = Song(id: 's1', title: 'Test', artist: 'Artist');

      libraryProvider.toggleLike(song);
      expect(libraryProvider.isLiked(song), true);

      libraryProvider.toggleLike(song);
      expect(libraryProvider.isLiked(song), false);
    });

    test('createPlaylist should add playlist', () {
      libraryProvider.createPlaylist('My Playlist');

      expect(libraryProvider.playlists.length, 1);
      expect(libraryProvider.playlists.first.title, 'My Playlist');
    });

    test('addSongToPlaylist should add song', () {
      libraryProvider.createPlaylist('Test Playlist');
      final playlistId = libraryProvider.playlists.first.id;
      final song = Song(id: 's1', title: 'Test', artist: 'Artist');

      libraryProvider.addSongToPlaylist(playlistId, song);

      final playlist = libraryProvider.getPlaylist(playlistId);
      expect(playlist?.songs.length, 1);
    });

    test('addToRecentlyPlayed should add song', () {
      final song = Song(id: 's1', title: 'Test', artist: 'Artist');

      libraryProvider.addToRecentlyPlayed(song);

      expect(libraryProvider.recentlyPlayed.length, 1);
      expect(libraryProvider.recentlyPlayed.first.id, 's1');
    });

    test('recentlyPlayed should have max 50 items', () {
      for (int i = 0; i < 60; i++) {
        libraryProvider.addToRecentlyPlayed(
          Song(id: 's$i', title: 'Song $i', artist: 'Artist'),
        );
      }

      expect(libraryProvider.recentlyPlayed.length, 50);
    });
  });

  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('Initial theme should be dark', () {
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
    });

    test('toggleTheme should switch theme', () {
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);

      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('setThemeMode should update theme', () {
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
    });
  });
}
