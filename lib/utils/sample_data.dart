import '../models/song.dart';
import '../models/album.dart';
import '../models/playlist.dart';
import '../models/artist.dart';

/**
 * Provides sample data for the application.
 * 
 * Used for demonstration purposes and as fallback data
 * when network requests fail or during development.
 */
class SampleData {
  static const String _baseImageUrl = 'https://picsum.photos/seed';

  static List<Song> get songs => [
        Song(
          id: 's1',
          title: 'Midnight Dreams',
          artist: 'Luna Nova',
          album: 'Stellar Journey',
          albumId: 'a1',
          imageUrl: '$_baseImageUrl/song1/300',
          duration: const Duration(minutes: 3, seconds: 45),
        ),
        Song(
          id: 's2',
          title: 'Electric Pulse',
          artist: 'Neon Riders',
          album: 'City Lights',
          albumId: 'a2',
          imageUrl: '$_baseImageUrl/song2/300',
          duration: const Duration(minutes: 4, seconds: 12),
          isExplicit: true,
        ),
        Song(
          id: 's3',
          title: 'Summer Breeze',
          artist: 'Ocean Waves',
          album: 'Tropical Escape',
          albumId: 'a3',
          imageUrl: '$_baseImageUrl/song3/300',
          duration: const Duration(minutes: 3, seconds: 28),
        ),
        Song(
          id: 's4',
          title: 'Dark Matter',
          artist: 'Cosmic Force',
          album: 'Nebula',
          albumId: 'a4',
          imageUrl: '$_baseImageUrl/song4/300',
          duration: const Duration(minutes: 5, seconds: 01),
          isExplicit: true,
        ),
        Song(
          id: 's5',
          title: 'Golden Hour',
          artist: 'Sunset Boulevard',
          album: 'Memories',
          albumId: 'a5',
          imageUrl: '$_baseImageUrl/song5/300',
          duration: const Duration(minutes: 3, seconds: 56),
        ),
        Song(
          id: 's6',
          title: 'Neon Lights',
          artist: 'Luna Nova',
          album: 'Stellar Journey',
          albumId: 'a1',
          imageUrl: '$_baseImageUrl/song6/300',
          duration: const Duration(minutes: 4, seconds: 23),
        ),
        Song(
          id: 's7',
          title: 'Rainfall',
          artist: 'Natural Harmony',
          album: 'Earth Elements',
          albumId: 'a6',
          imageUrl: '$_baseImageUrl/song7/300',
          duration: const Duration(minutes: 3, seconds: 15),
        ),
        Song(
          id: 's8',
          title: 'Velocity',
          artist: 'Speed Demons',
          album: 'Fast Lane',
          albumId: 'a7',
          imageUrl: '$_baseImageUrl/song8/300',
          duration: const Duration(minutes: 2, seconds: 58),
          isExplicit: true,
        ),
        Song(
          id: 's9',
          title: 'Whispers',
          artist: 'Silent Echo',
          album: 'Tranquility',
          albumId: 'a8',
          imageUrl: '$_baseImageUrl/song9/300',
          duration: const Duration(minutes: 4, seconds: 45),
        ),
        Song(
          id: 's10',
          title: 'Fire & Ice',
          artist: 'Elemental',
          album: 'Opposites',
          albumId: 'a9',
          imageUrl: '$_baseImageUrl/song10/300',
          duration: const Duration(minutes: 3, seconds: 33),
        ),
        Song(
          id: 's11',
          title: 'Crystal Clear',
          artist: 'Glass Tower',
          album: 'Reflections',
          albumId: 'a10',
          imageUrl: '$_baseImageUrl/song11/300',
          duration: const Duration(minutes: 4, seconds: 08),
        ),
        Song(
          id: 's12',
          title: 'Heartbeat',
          artist: 'Pulse',
          album: 'Rhythm',
          albumId: 'a11',
          imageUrl: '$_baseImageUrl/song12/300',
          duration: const Duration(minutes: 3, seconds: 22),
        ),
      ];

  static List<Album> get albums => [
        Album(
          id: 'a1',
          title: 'Stellar Journey',
          artist: 'Luna Nova',
          imageUrl: '$_baseImageUrl/album1/300',
          year: 2024,
          songs: songs.where((s) => s.albumId == 'a1').toList(),
          genre: 'Electronic',
        ),
        Album(
          id: 'a2',
          title: 'City Lights',
          artist: 'Neon Riders',
          imageUrl: '$_baseImageUrl/album2/300',
          year: 2024,
          songs: songs.where((s) => s.albumId == 'a2').toList(),
          genre: 'Synthwave',
          isExplicit: true,
        ),
        Album(
          id: 'a3',
          title: 'Tropical Escape',
          artist: 'Ocean Waves',
          imageUrl: '$_baseImageUrl/album3/300',
          year: 2023,
          songs: songs.where((s) => s.albumId == 'a3').toList(),
          genre: 'Tropical House',
        ),
        Album(
          id: 'a4',
          title: 'Nebula',
          artist: 'Cosmic Force',
          imageUrl: '$_baseImageUrl/album4/300',
          year: 2024,
          songs: songs.where((s) => s.albumId == 'a4').toList(),
          genre: 'Space Rock',
          isExplicit: true,
        ),
        Album(
          id: 'a5',
          title: 'Memories',
          artist: 'Sunset Boulevard',
          imageUrl: '$_baseImageUrl/album5/300',
          year: 2023,
          songs: songs.where((s) => s.albumId == 'a5').toList(),
          genre: 'Indie Pop',
        ),
        Album(
          id: 'a6',
          title: 'Earth Elements',
          artist: 'Natural Harmony',
          imageUrl: '$_baseImageUrl/album6/300',
          year: 2024,
          songs: songs.where((s) => s.albumId == 'a6').toList(),
          genre: 'Ambient',
        ),
      ];

  static List<Artist> get artists => [
        Artist(
          id: 'ar1',
          name: 'Luna Nova',
          imageUrl: '$_baseImageUrl/artist1/300',
          followers: 1250000,
          genres: ['Electronic', 'Synthwave'],
          isVerified: true,
          bio: 'Luna Nova is an electronic music producer known for atmospheric soundscapes.',
          topSongs: songs.where((s) => s.artist == 'Luna Nova').toList(),
          albums: albums.where((a) => a.artist == 'Luna Nova').toList(),
        ),
        Artist(
          id: 'ar2',
          name: 'Neon Riders',
          imageUrl: '$_baseImageUrl/artist2/300',
          followers: 890000,
          genres: ['Synthwave', 'Retrowave'],
          isVerified: true,
          bio: 'Neon Riders brings 80s-inspired synthwave to the modern era.',
        ),
        Artist(
          id: 'ar3',
          name: 'Ocean Waves',
          imageUrl: '$_baseImageUrl/artist3/300',
          followers: 567000,
          genres: ['Tropical House', 'Chill'],
          isVerified: true,
        ),
        Artist(
          id: 'ar4',
          name: 'Cosmic Force',
          imageUrl: '$_baseImageUrl/artist4/300',
          followers: 432000,
          genres: ['Space Rock', 'Progressive'],
          isVerified: false,
        ),
        Artist(
          id: 'ar5',
          name: 'Sunset Boulevard',
          imageUrl: '$_baseImageUrl/artist5/300',
          followers: 789000,
          genres: ['Indie Pop', 'Alternative'],
          isVerified: true,
        ),
        Artist(
          id: 'ar6',
          name: 'Natural Harmony',
          imageUrl: '$_baseImageUrl/artist6/300',
          followers: 234000,
          genres: ['Ambient', 'Nature'],
          isVerified: false,
        ),
      ];

  static List<Playlist> get playlists => [
        Playlist(
          id: 'p1',
          title: 'Chill Vibes',
          description: 'Relax and unwind with these chill tracks',
          imageUrl: '$_baseImageUrl/playlist1/300',
          ownerName: 'Flyer',
          songs: [songs[2], songs[6], songs[8], songs[4]],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Playlist(
          id: 'p2',
          title: 'Workout Energy',
          description: 'High energy tracks to power your workout',
          imageUrl: '$_baseImageUrl/playlist2/300',
          ownerName: 'Flyer',
          songs: [songs[1], songs[7], songs[3], songs[9]],
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        Playlist(
          id: 'p3',
          title: 'Late Night Drive',
          description: 'Perfect soundtrack for nighttime adventures',
          imageUrl: '$_baseImageUrl/playlist3/300',
          ownerName: 'Flyer',
          songs: [songs[0], songs[5], songs[10], songs[11]],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Playlist(
          id: 'p4',
          title: 'Top Hits 2024',
          description: 'The biggest hits of the year',
          imageUrl: '$_baseImageUrl/playlist4/300',
          ownerName: 'Flyer',
          songs: songs.take(8).toList(),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Playlist(
          id: 'p5',
          title: 'Discover Weekly',
          description: 'New music picked just for you',
          imageUrl: '$_baseImageUrl/playlist5/300',
          ownerName: 'Flyer',
          songs: songs.reversed.take(6).toList(),
          createdAt: DateTime.now(),
        ),
        Playlist(
          id: 'p6',
          title: 'Focus Flow',
          description: 'Instrumental beats for concentration',
          imageUrl: '$_baseImageUrl/playlist6/300',
          ownerName: 'Flyer',
          songs: [songs[6], songs[8], songs[10]],
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ];

  static List<Song> get quickPicks => songs.take(6).toList();

  static List<Song> get recentlyPlayed => songs.reversed.take(6).toList();

  static List<Playlist> get recommendedPlaylists => playlists.take(4).toList();

  static List<Album> get newReleases => albums.take(5).toList();

  static List<Artist> get featuredArtists => artists.take(5).toList();
}
