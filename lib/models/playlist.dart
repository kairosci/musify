import 'song.dart';

/**
 * Represents a playlist containing a collection of songs.
 * 
 * Supports both user-created and system-generated playlists
 * with options for public/private visibility and collaboration.
 */
class Playlist {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? ownerId;
  final String ownerName;
  final List<Song> songs;
  final bool isPublic;
  final bool isCollaborative;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Playlist({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.ownerId,
    required this.ownerName,
    this.songs = const [],
    this.isPublic = true,
    this.isCollaborative = false,
    required this.createdAt,
    this.updatedAt,
  });

  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    List<Song>? songs,
    bool? isPublic,
    bool? isCollaborative,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      songs: songs ?? this.songs,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'songs': songs.map((s) => s.toMap()).toList(),
      'isPublic': isPublic,
      'isCollaborative': isCollaborative,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'],
      ownerName: map['ownerName'] ?? '',
      songs: map['songs'] != null
          ? List<Song>.from(map['songs'].map((x) => Song.fromMap(x)))
          : [],
      isPublic: map['isPublic'] ?? true,
      isCollaborative: map['isCollaborative'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  int get songCount => songs.length;

  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  String get formattedTotalDuration {
    final minutes = totalDuration.inMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours hr $remainingMinutes min';
    }
    return '$minutes min';
  }

  String? get displayImage {
    if (imageUrl != null) return imageUrl;
    if (songs.isNotEmpty && songs.first.imageUrl != null) {
      return songs.first.imageUrl;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
