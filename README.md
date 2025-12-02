# Flyer

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

A Spotify-like music streaming app built with Flutter, inspired by the principles of [Metrolist](https://github.com/mostafaalagamy/Metrolist). Features a modern Material 3 design with a red accent color and Spotify-like UX.

## Features

- **Material 3 Design** - Modern UI with red accent color
- **Dark/Light Theme** - Spotify-inspired dark theme as default
- **Home Screen** - Personalized recommendations, quick picks, and recent plays
- **Search** - Search for songs, albums, artists, and playlists
- **Library** - Manage your liked songs, playlists, albums, and followed artists
- **Now Playing** - Full-screen player with album art and controls
- **Mini Player** - Compact player at bottom for quick controls
- **Playlists** - Create, edit, and manage playlists
- **Albums & Artists** - Browse albums and artist pages
- **Liked Songs** - Save your favorite tracks
- **Shuffle & Repeat** - Multiple playback modes
- **Queue Management** - Add songs to queue, play next

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kairosci/flyer-test.git
cd flyer-test
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── song.dart
│   ├── album.dart
│   ├── playlist.dart
│   └── artist.dart
├── providers/             # State management (Provider)
│   ├── player_provider.dart
│   ├── library_provider.dart
│   └── theme_provider.dart
├── screens/               # App screens
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── library_screen.dart
│   ├── player_screen.dart
│   ├── playlist_screen.dart
│   ├── album_screen.dart
│   └── artist_screen.dart
├── widgets/               # Reusable widgets
│   ├── mini_player.dart
│   ├── song_tile.dart
│   ├── playlist_card.dart
│   ├── album_card.dart
│   ├── artist_card.dart
│   └── section_header.dart
└── utils/                 # Utilities and constants
    ├── app_theme.dart
    └── sample_data.dart
```

## Design Principles

### Inspired by Metrolist
This app follows the design and UX principles of Metrolist:
- Clean, modern interface
- Music streaming focus (no video content)
- Library management
- Background playback support
- Offline capability (download support structure)

### Spotify-like UX
- Bottom navigation with Home, Search, Library tabs
- Mini player that appears when playing music
- Full-screen player with gesture controls
- Grid and list views for content
- Horizontal scrolling carousels
- Quick access grid for recent content

### Color Scheme
- **Primary Color**: Red (#E53935)
- **Background**: Dark (#121212)
- **Surface**: Dark gray (#1E1E1E)
- **Cards**: Slightly lighter gray (#282828)

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Audio**: just_audio, audio_service
- **Storage**: Hive, SharedPreferences
- **Networking**: http
- **Image Caching**: cached_network_image

## Screenshots

The app features:
- A modern home screen with personalized recommendations
- Search functionality with category browsing
- Library management with filters
- Full-featured music player
- Detailed screens for playlists, albums, and artists

## Configuration

### Theme Customization
The app theme can be customized in `lib/utils/app_theme.dart`. You can modify:
- Primary colors
- Background colors
- Text styles
- Component themes

### Sample Data
Sample data for development is located in `lib/utils/sample_data.dart`. Replace this with your actual data source in production.

## Testing

Run tests with:
```bash
flutter test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Metrolist](https://github.com/mostafaalagamy/Metrolist) - Design inspiration
- [Spotify](https://www.spotify.com) - UX reference
- [Flutter](https://flutter.dev) - Framework

---

Made with Flutter
