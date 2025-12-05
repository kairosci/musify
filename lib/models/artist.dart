import 'album.dart';
import 'song.dart';

/**
 * Represents a music artist or creator.
 * 
 * Contains artist metadata including name, biography, follower count,
 * top songs, albums, and verification status.
 */
class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bio;
  final int? followers;
  final List<Song> topSongs;
  final List<Album> albums;
  final List<String> genres;
  final bool isVerified;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    this.followers,
    this.topSongs = const [],
    this.albums = const [],
    this.genres = const [],
    this.isVerified = false,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? bio,
    int? followers,
    List<Song>? topSongs,
    List<Album>? albums,
    List<String>? genres,
    bool? isVerified,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      topSongs: topSongs ?? this.topSongs,
      albums: albums ?? this.albums,
      genres: genres ?? this.genres,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'bio': bio,
      'followers': followers,
      'topSongs': topSongs.map((s) => s.toMap()).toList(),
      'albums': albums.map((a) => a.toMap()).toList(),
      'genres': genres,
      'isVerified': isVerified,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      bio: map['bio'],
      followers: map['followers'],
      topSongs: map['topSongs'] != null
          ? List<Song>.from(map['topSongs'].map((x) => Song.fromMap(x)))
          : [],
      albums: map['albums'] != null
          ? List<Album>.from(map['albums'].map((x) => Album.fromMap(x)))
          : [],
      genres: map['genres'] != null ? List<String>.from(map['genres']) : [],
      isVerified: map['isVerified'] ?? false,
    );
  }

  String get formattedFollowers {
    if (followers == null) return '';
    if (followers! >= 1000000) {
      return '${(followers! / 1000000).toStringAsFixed(1)}M followers';
    } else if (followers! >= 1000) {
      return '${(followers! / 1000).toStringAsFixed(1)}K followers';
    }
    return '$followers followers';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
