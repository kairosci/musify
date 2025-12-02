import 'package:flutter_test/flutter_test.dart';
import 'package:flyer/models/song.dart';
import 'package:flyer/models/album.dart';
import 'package:flyer/models/playlist.dart';
import 'package:flyer/models/artist.dart';

void main() {
  group('Song Model Tests', () {
    test('Song should create correctly', () {
      final song = Song(
        id: '1',
        title: 'Test Song',
        artist: 'Test Artist',
        duration: const Duration(minutes: 3, seconds: 30),
      );

      expect(song.id, '1');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.duration.inSeconds, 210);
    });

    test('Song formattedDuration should work', () {
      final song = Song(
        id: '1',
        title: 'Test',
        artist: 'Artist',
        duration: const Duration(minutes: 3, seconds: 5),
      );

      expect(song.formattedDuration, '3:05');
    });

    test('Song copyWith should work', () {
      final song = Song(
        id: '1',
        title: 'Test',
        artist: 'Artist',
      );

      final updatedSong = song.copyWith(isLiked: true);

      expect(updatedSong.isLiked, true);
      expect(updatedSong.title, 'Test');
    });

    test('Song toMap and fromMap should work', () {
      final song = Song(
        id: '1',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: const Duration(minutes: 4),
      );

      final map = song.toMap();
      final recreatedSong = Song.fromMap(map);

      expect(recreatedSong.id, song.id);
      expect(recreatedSong.title, song.title);
      expect(recreatedSong.artist, song.artist);
    });
  });

  group('Album Model Tests', () {
    test('Album should create correctly', () {
      final album = Album(
        id: 'a1',
        title: 'Test Album',
        artist: 'Test Artist',
        year: 2024,
      );

      expect(album.id, 'a1');
      expect(album.title, 'Test Album');
      expect(album.year, 2024);
    });

    test('Album songCount should work', () {
      final songs = [
        const Song(id: 's1', title: 'Song 1', artist: 'Artist'),
        const Song(id: 's2', title: 'Song 2', artist: 'Artist'),
      ];

      final album = Album(
        id: 'a1',
        title: 'Test Album',
        artist: 'Artist',
        songs: songs,
      );

      expect(album.songCount, 2);
    });
  });

  group('Playlist Model Tests', () {
    test('Playlist should create correctly', () {
      final playlist = Playlist(
        id: 'p1',
        title: 'My Playlist',
        ownerName: 'User',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(playlist.id, 'p1');
      expect(playlist.title, 'My Playlist');
      expect(playlist.ownerName, 'User');
    });

    test('Playlist songCount should work', () {
      final songs = [
        const Song(id: 's1', title: 'Song 1', artist: 'Artist'),
        const Song(id: 's2', title: 'Song 2', artist: 'Artist'),
        const Song(id: 's3', title: 'Song 3', artist: 'Artist'),
      ];

      final playlist = Playlist(
        id: 'p1',
        title: 'Test',
        ownerName: 'User',
        songs: songs,
        createdAt: DateTime.now(),
      );

      expect(playlist.songCount, 3);
    });
  });

  group('Artist Model Tests', () {
    test('Artist should create correctly', () {
      final artist = Artist(
        id: 'ar1',
        name: 'Test Artist',
        followers: 1500000,
        isVerified: true,
      );

      expect(artist.id, 'ar1');
      expect(artist.name, 'Test Artist');
      expect(artist.isVerified, true);
    });

    test('Artist formattedFollowers should work', () {
      final artist1 = Artist(
        id: 'ar1',
        name: 'Artist 1',
        followers: 1500000,
      );

      final artist2 = Artist(
        id: 'ar2',
        name: 'Artist 2',
        followers: 50000,
      );

      expect(artist1.formattedFollowers, '1.5M followers');
      expect(artist2.formattedFollowers, '50.0K followers');
    });
  });
}
