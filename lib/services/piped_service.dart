import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';

/**
 * Service for interacting with Piped API.
 * 
 * Piped is an open-source privacy-focused alternative frontend for YouTube
 * that provides audio-only streaming capabilities. This service handles all
 * communication with Piped instances for searching and streaming music.
 * 
 * Features:
 * - Multiple Piped instances with automatic fallback
 * - Audio-only streaming (no video content)
 * - Search for songs, artists, albums, and playlists
 * - Configurable instance selection
 */
class PipedService {
  static String _baseUrl = 'https://pipedapi.kavin.rocks';
  static int _currentInstanceIndex = 0;
  
  /**
   * List of available Piped API instances.
   * Used for fallback when the primary instance is unavailable.
   */
  static const List<String> availableInstances = [
    'https://pipedapi.kavin.rocks',
    'https://pipedapi.adminforge.de',
    'https://pipedapi.darkness.services',
    'https://api.piped.yt',
  ];

  /**
   * Sets the base URL for all Piped API requests.
   * Call this method to switch to a different Piped instance.
   */
  static void setInstance(String url) {
    _baseUrl = url;
    _currentInstanceIndex = availableInstances.indexOf(url);
    if (_currentInstanceIndex < 0) _currentInstanceIndex = 0;
  }

  static String get currentInstance => _baseUrl;

  /**
   * Searches for music tracks using the Piped API.
   * 
   * The search is filtered to return only music songs (audio content).
   * Supports pagination through the nextPage parameter.
   * 
   * Automatically falls back to alternative instances on failure.
   */
  static Future<PipedSearchResult> searchMusic(String query, {String? nextPage}) async {
    return _executeWithFallback(() async {
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
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    });
  }

  /**
   * Searches for artists using the Piped API.
   * Returns channels/artists matching the search query.
   */
  static Future<PipedSearchResult> searchArtists(String query) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
            'q': query,
            'filter': 'music_artists',
          });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search artists: ${response.statusCode}');
      }
    });
  }

  /**
   * Searches for albums using the Piped API.
   * Returns music albums matching the search query.
   */
  static Future<PipedSearchResult> searchAlbums(String query) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
            'q': query,
            'filter': 'music_albums',
          });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search albums: ${response.statusCode}');
      }
    });
  }

  /**
   * Searches for playlists using the Piped API.
   * Returns music playlists matching the search query.
   */
  static Future<PipedSearchResult> searchPlaylists(String query) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
            'q': query,
            'filter': 'music_playlists',
          });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedSearchResult.fromJson(data);
      } else {
        throw Exception('Failed to search playlists: ${response.statusCode}');
      }
    });
  }

  /**
   * Retrieves audio stream information for a specific video/song.
   * 
   * Returns detailed stream info including multiple audio quality options,
   * related tracks, and metadata. The response includes URLs for direct
   * audio streaming without video content.
   */
  static Future<PipedStreamInfo> getAudioStream(String videoId) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/streams/$videoId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedStreamInfo.fromJson(data);
      } else {
        throw Exception('Failed to get stream: ${response.statusCode}');
      }
    });
  }

  /**
   * Retrieves detailed information about a playlist.
   * Includes playlist metadata and all contained tracks.
   */
  static Future<PipedPlaylistInfo> getPlaylist(String playlistId) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/playlists/$playlistId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedPlaylistInfo.fromJson(data);
      } else {
        throw Exception('Failed to get playlist: ${response.statusCode}');
      }
    });
  }

  /**
   * Retrieves detailed information about a channel/artist.
   * Includes channel metadata and recent uploads.
   */
  static Future<PipedChannelInfo> getChannel(String channelId) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/channel/$channelId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PipedChannelInfo.fromJson(data);
      } else {
        throw Exception('Failed to get channel: ${response.statusCode}');
      }
    });
  }

  /**
   * Retrieves trending music content for a specific region.
   * Filters results to only include music content.
   */
  static Future<List<PipedVideoItem>> getTrending({String region = 'US'}) async {
    return _executeWithFallback(() async {
      final uri = Uri.parse('$_baseUrl/trending')
          .replace(queryParameters: {'region': region});

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => PipedVideoItem.fromJson(item))
            .where((item) => item.isMusic)
            .toList();
      } else {
        throw Exception('Failed to get trending: ${response.statusCode}');
      }
    });
  }

  /**
   * Checks if a Piped instance is available and responding.
   * Returns true if the instance is healthy, false otherwise.
   */
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

  /**
   * Finds the first available Piped instance from the list.
   * Iterates through all instances and returns the first one that responds.
   */
  static Future<String?> findBestInstance() async {
    for (final instance in availableInstances) {
      if (await checkInstance(instance)) {
        return instance;
      }
    }
    return null;
  }

  /**
   * Executes an API request with automatic fallback to alternative instances.
   * 
   * If the current instance fails, it will try each available instance
   * in order until one succeeds or all have been tried.
   */
  static Future<T> _executeWithFallback<T>(Future<T> Function() request) async {
    Exception? lastException;
    final startIndex = _currentInstanceIndex;
    
    for (int i = 0; i < availableInstances.length; i++) {
      final index = (startIndex + i) % availableInstances.length;
      _baseUrl = availableInstances[index];
      
      try {
        final result = await request();
        _currentInstanceIndex = index;
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception('$e');
        continue;
      }
    }
    
    throw lastException ?? Exception('All Piped instances failed');
  }
}

/**
 * Represents the result of a search query from Piped API.
 * Contains a list of matching items and pagination information.
 */
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

/**
 * Represents a video/song item from Piped search results.
 * Contains metadata about the media item including title, artist,
 * duration, and thumbnail information.
 */
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

  bool get isMusic => !isShort && type == 'stream';

  factory PipedVideoItem.fromJson(Map<String, dynamic> json) {
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

/**
 * Contains detailed stream information from Piped API.
 * Includes audio stream URLs at various quality levels,
 * related content, and metadata about the media.
 */
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
            .where((s) => !s.isShort)
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

  /**
   * Returns the best quality audio stream URL available.
   * Prefers opus/webm codec for better quality, falls back to highest bitrate.
   */
  String? get bestAudioUrl {
    if (audioStreams.isEmpty) return null;
    
    final sorted = List<PipedAudioStream>.from(audioStreams);
    sorted.sort((a, b) => b.bitrate.compareTo(a.bitrate));
    
    final opus = sorted.where((s) => s.codec.contains('opus')).firstOrNull;
    if (opus != null) return opus.url;
    
    return sorted.first.url;
  }

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

/**
 * Represents an individual audio stream from Piped.
 * Contains stream URL and quality information.
 */
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

/**
 * Represents a related stream/song recommendation from Piped.
 * Used for building recommendation queues and related content.
 */
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

/**
 * Contains playlist information from Piped API.
 * Includes playlist metadata and all contained tracks.
 */
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

/**
 * Contains channel/artist information from Piped API.
 * Includes channel metadata, avatar, banner, and recent uploads.
 */
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
