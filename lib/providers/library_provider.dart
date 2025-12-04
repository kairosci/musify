import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../models/playlist.dart';
import '../models/artist.dart';

/**
 * Provider for managing the user's music library.
 * 
 * Handles liked songs, playlists, saved albums, followed artists,
 * recently played tracks, and downloaded content.
 */
class LibraryProvider extends ChangeNotifier {
  final List<Song> _likedSongs = [];
  final List<Playlist> _playlists = [];
  final List<Album> _savedAlbums = [];
  final List<Artist> _followedArtists = [];
  final List<Song> _recentlyPlayed = [];
  final List<Song> _downloadQueue = [];
  final List<Song> _downloadedSongs = [];

  List<Song> get likedSongs => List.unmodifiable(_likedSongs);
  List<Playlist> get playlists => List.unmodifiable(_playlists);
  List<Album> get savedAlbums => List.unmodifiable(_savedAlbums);
  List<Artist> get followedArtists => List.unmodifiable(_followedArtists);
  List<Song> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);
  List<Song> get downloadQueue => List.unmodifiable(_downloadQueue);
  List<Song> get downloadedSongs => List.unmodifiable(_downloadedSongs);

  bool isLiked(Song song) => _likedSongs.any((s) => s.id == song.id);

  void toggleLike(Song song) {
    final index = _likedSongs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _likedSongs.removeAt(index);
    } else {
      _likedSongs.insert(0, song.copyWith(isLiked: true, addedAt: DateTime.now()));
    }
    notifyListeners();
  }

  void addToLiked(Song song) {
    if (!isLiked(song)) {
      _likedSongs.insert(0, song.copyWith(isLiked: true, addedAt: DateTime.now()));
      notifyListeners();
    }
  }

  void removeFromLiked(Song song) {
    _likedSongs.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  Playlist? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void createPlaylist(String title, {String? description}) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      ownerName: 'You',
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, playlist);
    notifyListeners();
  }

  void updatePlaylist(Playlist playlist) {
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index >= 0) {
      _playlists[index] = playlist.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  void addSongToPlaylist(String playlistId, Song song) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final playlist = _playlists[index];
      if (!playlist.songs.any((s) => s.id == song.id)) {
        _playlists[index] = playlist.copyWith(
          songs: [...playlist.songs, song],
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final playlist = _playlists[index];
      _playlists[index] = playlist.copyWith(
        songs: playlist.songs.where((s) => s.id != songId).toList(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  bool isAlbumSaved(String albumId) =>
      _savedAlbums.any((a) => a.id == albumId);

  void saveAlbum(Album album) {
    if (!isAlbumSaved(album.id)) {
      _savedAlbums.insert(0, album);
      notifyListeners();
    }
  }

  void removeAlbum(String albumId) {
    _savedAlbums.removeWhere((a) => a.id == albumId);
    notifyListeners();
  }

  void toggleAlbumSaved(Album album) {
    if (isAlbumSaved(album.id)) {
      removeAlbum(album.id);
    } else {
      saveAlbum(album);
    }
  }

  bool isArtistFollowed(String artistId) =>
      _followedArtists.any((a) => a.id == artistId);

  void followArtist(Artist artist) {
    if (!isArtistFollowed(artist.id)) {
      _followedArtists.insert(0, artist);
      notifyListeners();
    }
  }

  void unfollowArtist(String artistId) {
    _followedArtists.removeWhere((a) => a.id == artistId);
    notifyListeners();
  }

  void toggleFollowArtist(Artist artist) {
    if (isArtistFollowed(artist.id)) {
      unfollowArtist(artist.id);
    } else {
      followArtist(artist);
    }
  }

  void addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed.removeLast();
    }
    notifyListeners();
  }

  void clearRecentlyPlayed() {
    _recentlyPlayed.clear();
    notifyListeners();
  }

  bool isDownloaded(String songId) =>
      _downloadedSongs.any((s) => s.id == songId);

  bool isDownloading(String songId) =>
      _downloadQueue.any((s) => s.id == songId);

  void downloadSong(Song song) {
    if (!isDownloaded(song.id) && !isDownloading(song.id)) {
      _downloadQueue.add(song);
      notifyListeners();
      _simulateDownload(song);
    }
  }

  void _simulateDownload(Song song) {
    Future.delayed(const Duration(seconds: 2), () {
      _downloadQueue.removeWhere((s) => s.id == song.id);
      _downloadedSongs.add(song);
      notifyListeners();
    });
  }

  void removeDownload(String songId) {
    _downloadedSongs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }

  void cancelDownload(String songId) {
    _downloadQueue.removeWhere((s) => s.id == songId);
    notifyListeners();
  }
}
