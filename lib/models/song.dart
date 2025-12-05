/**
 * Represents a song/track in the application.
 * 
 * This is the core data model for music content, containing
 * all metadata needed for display and playback including title,
 * artist, album info, artwork URL, and audio stream URL.
 */
class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumId;
  final String? imageUrl;
  final String? audioUrl;
  final Duration duration;
  final bool isExplicit;
  final bool isLiked;
  final DateTime? addedAt;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumId,
    this.imageUrl,
    this.audioUrl,
    this.duration = Duration.zero,
    this.isExplicit = false,
    this.isLiked = false,
    this.addedAt,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumId,
    String? imageUrl,
    String? audioUrl,
    Duration? duration,
    bool? isExplicit,
    bool? isLiked,
    DateTime? addedAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isExplicit: isExplicit ?? this.isExplicit,
      isLiked: isLiked ?? this.isLiked,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumId': albumId,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'duration': duration.inMilliseconds,
      'isExplicit': isExplicit,
      'isLiked': isLiked,
      'addedAt': addedAt?.toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'],
      albumId: map['albumId'],
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      duration: Duration(milliseconds: map['duration'] ?? 0),
      isExplicit: map['isExplicit'] ?? false,
      isLiked: map['isLiked'] ?? false,
      addedAt: map['addedAt'] != null ? DateTime.parse(map['addedAt']) : null,
    );
  }

  /**
   * Formats the duration as a human-readable string (mm:ss).
   */
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
