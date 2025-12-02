import 'song.dart';

/// Represents an album
class Album {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? imageUrl;
  final int? year;
  final List<Song> songs;
  final String? genre;
  final bool isExplicit;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.imageUrl,
    this.year,
    this.songs = const [],
    this.genre,
    this.isExplicit = false,
  });

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? imageUrl,
    int? year,
    List<Song>? songs,
    String? genre,
    bool? isExplicit,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      imageUrl: imageUrl ?? this.imageUrl,
      year: year ?? this.year,
      songs: songs ?? this.songs,
      genre: genre ?? this.genre,
      isExplicit: isExplicit ?? this.isExplicit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'imageUrl': imageUrl,
      'year': year,
      'songs': songs.map((s) => s.toMap()).toList(),
      'genre': genre,
      'isExplicit': isExplicit,
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      artistId: map['artistId'],
      imageUrl: map['imageUrl'],
      year: map['year'],
      songs: map['songs'] != null
          ? List<Song>.from(map['songs'].map((x) => Song.fromMap(x)))
          : [],
      genre: map['genre'],
      isExplicit: map['isExplicit'] ?? false,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
