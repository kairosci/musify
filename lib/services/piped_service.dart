import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';

/// Service for interacting with Piped API (audio-only YouTube alternative)
class PipedService {
  // Default Piped instance - can be changed by user
  static String _baseUrl = 'https://pipedapi.kavin.rocks';
  
  // Available Piped instances for fallback
  static const List<String> availableInstances = [
    'https://pipedapi.kavin.rocks',
    'https://pipedapi.adminforge.de',
    'https://pipedapi.darkness.services',
    'https://api.piped.yt',
  ];

  /// Set the base URL for Piped API
  static void setInstance(String url) {
    _baseUrl = url;
  }

  /// Get current instance URL
  static String get currentInstance => _baseUrl;

  /// Search for music (audio-only content)
  static Future<PipedSearchResult> searchMusic(String query, {String? nextPage}) async {
    try {
      final Uri uri;
      if (nextPage != null) {
        uri = Uri.parse('$_baseUrl/nextpage/search')
            .replace(queryParameters: {
              'nextpage': nextPage,
              'q': query,
              'filter': 'music_songs',
            });
      } else {
        uri = Uri.parse('$_baseUrl/search')
            .replace(queryParameters: {
              'q': query,
              'filter': 'music_songs',
            });
      }

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Search for artists
  static Future<PipedSearchResult> searchArtists(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
            'q': query,
            'filter': 'music_artists',
          });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search artists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Artist search failed: $e');
    }
  }

  /// Search for albums
  static Future<PipedSearchResult> searchAlbums(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
            'q': query,
            'filter': 'music_albums',
          });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Album search failed: $e');
    }
  }

  /// Search for playlists
  static Future<PipedSearchResult> searchPlaylists(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
            'q': query,
            'filter': 'music_playlists',
          });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Playlist search failed: $e');
    }
  }

  /// Get audio stream URL for a video/song ID (audio-only)
  static Future<PipedStreamInfo> getAudioStream(String videoId) async {
    try {
      final uri = Uri.parse('$_baseUrl/streams/$videoId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedStreamInfo.fromJson(data);
      } else {
        throw Exception('Failed to get stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Stream fetch failed: $e');
    }
  }

  /// Get playlist details
  static Future<PipedPlaylistInfo> getPlaylist(String playlistId) async {
    try {
      final uri = Uri.parse('$_baseUrl/playlists/$playlistId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedPlaylistInfo.fromJson(data);
      } else {
        throw Exception('Failed to get playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Playlist fetch failed: $e');
    }
  }

  /// Get artist/channel details
  static Future<PipedChannelInfo> getChannel(String channelId) async {
    try {
      final uri = Uri.parse('$_baseUrl/channel/$channelId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedChannelInfo.fromJson(data);
      } else {
        throw Exception('Failed to get channel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Channel fetch failed: $e');
    }
  }

  /// Get trending music
  static Future<List<PipedVideoItem>> getTrending({String region = 'US'}) async {
    try {
      final uri = Uri.parse('$_baseUrl/trending')
          .replace(queryParameters: {'region': region});

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filter to only include music content
        return data
            .map((item) => PipedVideoItem.fromJson(item))
            .where((item) => item.isMusic)
            .toList();
      } else {
        throw Exception('Failed to get trending: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Trending fetch failed: $e');
    }
  }

  /// Check if instance is available
  static Future<bool> checkInstance(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Find best available instance
  static Future<String?> findBestInstance() async {
    for (final instance in availableInstances) {
      if (await checkInstance(instance)) {
        return instance;
      }
    }
    return null;
  }
}

/// Search result from Piped API
class PipedSearchResult {
  final List<PipedVideoItem> items;
  final String? nextPage;
  final String? correctedQuery;

  PipedSearchResult({
    required this.items,
    this.nextPage,
    this.correctedQuery,
  });

  factory PipedSearchResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => PipedVideoItem.fromJson(item))
            .toList() ??
        [];

    return PipedSearchResult(
      items: items,
      nextPage: json['nextpage'] as String?,
      correctedQuery: json['correctedQuery'] as String?,
    );
  }
}

/// Video/Song item from Piped
class PipedVideoItem {
  final String id;
  final String title;
  final String? thumbnail;
  final String uploaderName;
  final String? uploaderId;
  final String? uploaderAvatar;
  final Duration duration;
  final int? views;
  final String? uploadedDate;
  final bool isShort;
  final String type;

  PipedVideoItem({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.uploaderName,
    this.uploaderId,
    this.uploaderAvatar,
    required this.duration,
    this.views,
    this.uploadedDate,
    this.isShort = false,
    required this.type,
  });

  /// Check if this is a music item (not a short or regular video)
  bool get isMusic => !isShort && type == 'stream';

  factory PipedVideoItem.fromJson(Map<String, dynamic> json) {
    // Extract video ID from URL
    String id = '';
    final url = json['url'] as String?;
    if (url != null) {
      final uri = Uri.tryParse('https://youtube.com$url');
      id = uri?.queryParameters['v'] ?? url.replaceAll('/watch?v=', '');
    }

    return PipedVideoItem(
      id: id,
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      uploaderName: json['uploaderName'] as String? ?? 'Unknown',
      uploaderId: _extractChannelId(json['uploaderUrl'] as String?),
      uploaderAvatar: json['uploaderAvatar'] as String?,
      duration: Duration(seconds: (json['duration'] as int?) ?? 0),
      views: json['views'] as int?,
      uploadedDate: json['uploadedDate'] as String?,
      isShort: json['isShort'] as bool? ?? false,
      type: json['type'] as String? ?? 'stream',
    );
  }

  static String? _extractChannelId(String? url) {
    if (url == null) return null;
    return url.replaceAll('/channel/', '');
  }

  /// Convert to Song model
  Song toSong() {
    return Song(
      id: id,
      title: title,
      artist: uploaderName,
      imageUrl: thumbnail,
      duration: duration,
    );
  }
}

/// Stream info from Piped API (audio streams)
class PipedStreamInfo {
  final String title;
  final String? description;
  final String uploader;
  final String? uploaderUrl;
  final String? uploaderAvatar;
  final String? thumbnailUrl;
  final Duration duration;
  final int? views;
  final int? likes;
  final int? dislikes;
  final List<PipedAudioStream> audioStreams;
  final List<PipedRelatedStream> relatedStreams;

  PipedStreamInfo({
    required this.title,
    this.description,
    required this.uploader,
    this.uploaderUrl,
    this.uploaderAvatar,
    this.thumbnailUrl,
    required this.duration,
    this.views,
    this.likes,
    this.dislikes,
    required this.audioStreams,
    required this.relatedStreams,
  });

  factory PipedStreamInfo.fromJson(Map<String, dynamic> json) {
    final audioStreams = (json['audioStreams'] as List<dynamic>?)
            ?.map((s) => PipedAudioStream.fromJson(s))
            .toList() ??
        [];

    final relatedStreams = (json['relatedStreams'] as List<dynamic>?)
            ?.map((s) => PipedRelatedStream.fromJson(s))
            .where((s) => !s.isShort) // Filter out shorts
            .toList() ??
        [];

    return PipedStreamInfo(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      uploader: json['uploader'] as String? ?? 'Unknown',
      uploaderUrl: json['uploaderUrl'] as String?,
      uploaderAvatar: json['uploaderAvatar'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: Duration(seconds: (json['duration'] as int?) ?? 0),
      views: json['views'] as int?,
      likes: json['likes'] as int?,
      dislikes: json['dislikes'] as int?,
      audioStreams: audioStreams,
      relatedStreams: relatedStreams,
    );
  }

  /// Get the best quality audio stream URL
  String? get bestAudioUrl {
    if (audioStreams.isEmpty) return null;
    
    // Prefer opus/webm for better quality, then m4a/mp4
    final sorted = List<PipedAudioStream>.from(audioStreams);
    sorted.sort((a, b) => b.bitrate.compareTo(a.bitrate));
    
    // Try to find opus first
    final opus = sorted.where((s) => s.codec.contains('opus')).firstOrNull;
    if (opus != null) return opus.url;
    
    // Fall back to highest bitrate
    return sorted.first.url;
  }

  /// Convert to Song model
  Song toSong(String videoId) {
    return Song(
      id: videoId,
      title: title,
      artist: uploader,
      imageUrl: thumbnailUrl,
      audioUrl: bestAudioUrl,
      duration: duration,
    );
  }
}

/// Audio stream from Piped
class PipedAudioStream {
  final String url;
  final String codec;
  final int bitrate;
  final String mimeType;
  final String quality;

  PipedAudioStream({
    required this.url,
    required this.codec,
    required this.bitrate,
    required this.mimeType,
    required this.quality,
  });

  factory PipedAudioStream.fromJson(Map<String, dynamic> json) {
    return PipedAudioStream(
      url: json['url'] as String? ?? '',
      codec: json['codec'] as String? ?? '',
      bitrate: json['bitrate'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? '',
      quality: json['quality'] as String? ?? '',
    );
  }
}

/// Related stream from Piped
class PipedRelatedStream {
  final String id;
  final String title;
  final String? thumbnail;
  final String uploaderName;
  final Duration duration;
  final bool isShort;

  PipedRelatedStream({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.uploaderName,
    required this.duration,
    this.isShort = false,
  });

  factory PipedRelatedStream.fromJson(Map<String, dynamic> json) {
    String id = '';
    final url = json['url'] as String?;
    if (url != null) {
      id = url.replaceAll('/watch?v=', '');
    }

    return PipedRelatedStream(
      id: id,
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      uploaderName: json['uploaderName'] as String? ?? 'Unknown',
      duration: Duration(seconds: (json['duration'] as int?) ?? 0),
      isShort: json['isShort'] as bool? ?? false,
    );
  }

  /// Convert to Song model
  Song toSong() {
    return Song(
      id: id,
      title: title,
      artist: uploaderName,
      imageUrl: thumbnail,
      duration: duration,
    );
  }
}

/// Playlist info from Piped
class PipedPlaylistInfo {
  final String name;
  final String? thumbnailUrl;
  final String? description;
  final String? uploader;
  final String? uploaderUrl;
  final int videoCount;
  final List<PipedVideoItem> videos;
  final String? nextPage;

  PipedPlaylistInfo({
    required this.name,
    this.thumbnailUrl,
    this.description,
    this.uploader,
    this.uploaderUrl,
    required this.videoCount,
    required this.videos,
    this.nextPage,
  });

  factory PipedPlaylistInfo.fromJson(Map<String, dynamic> json) {
    final videos = (json['relatedStreams'] as List<dynamic>?)
            ?.map((v) => PipedVideoItem.fromJson(v))
            .toList() ??
        [];

    return PipedPlaylistInfo(
      name: json['name'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      description: json['description'] as String?,
      uploader: json['uploader'] as String?,
      uploaderUrl: json['uploaderUrl'] as String?,
      videoCount: json['videos'] as int? ?? 0,
      videos: videos,
      nextPage: json['nextpage'] as String?,
    );
  }

  /// Convert to Playlist model
  Playlist toPlaylist(String id) {
    return Playlist(
      id: id,
      title: name,
      description: description,
      imageUrl: thumbnailUrl,
      ownerName: uploader ?? 'Unknown',
      songs: videos.map((v) => v.toSong()).toList(),
      createdAt: DateTime.now(),
    );
  }
}

/// Channel/Artist info from Piped
class PipedChannelInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? description;
  final int? subscriberCount;
  final List<PipedVideoItem> videos;
  final String? nextPage;

  PipedChannelInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bannerUrl,
    this.description,
    this.subscriberCount,
    required this.videos,
    this.nextPage,
  });

  factory PipedChannelInfo.fromJson(Map<String, dynamic> json) {
    final videos = (json['relatedStreams'] as List<dynamic>?)
            ?.map((v) => PipedVideoItem.fromJson(v))
            .toList() ??
        [];

    return PipedChannelInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      description: json['description'] as String?,
      subscriberCount: json['subscriberCount'] as int?,
      videos: videos,
      nextPage: json['nextpage'] as String?,
    );
  }

  /// Convert to Artist model
  Artist toArtist() {
    return Artist(
      id: id,
      name: name,
      imageUrl: avatarUrl,
      bio: description,
      followers: subscriberCount,
      topSongs: videos.take(10).map((v) => v.toSong()).toList(),
      isVerified: (subscriberCount ?? 0) > 100000,
    );
  }
}
