# Flyer 🎵

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux-green" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

A Spotify-like music streaming app built with Flutter, inspired by the principles of [Metrolist](https://github.com/mostafaalagamy/Metrolist). Features a modern Material 3 design with a red accent color and Spotify-like UX.

## ✨ Features

- 🎨 **Material 3 Design** - Modern UI with red accent color
- 🌙 **Dark/Light Theme** - Spotify-inspired dark theme as default
- 🏠 **Home Screen** - Personalized recommendations, quick picks, and recent plays
- 🔍 **Search** - Search for songs, albums, artists, and playlists
- 📚 **Library** - Manage your liked songs, playlists, albums, and followed artists
- 🎵 **Now Playing** - Full-screen player with album art and controls
- 📱 **Mini Player** - Compact player at bottom for quick controls
- 📋 **Playlists** - Create, edit, and manage playlists
- 💿 **Albums & Artists** - Browse albums and artist pages
- ❤️ **Liked Songs** - Save your favorite tracks
- 🔀 **Shuffle & Repeat** - Multiple playback modes
- 📥 **Queue Management** - Add songs to queue, play next
- 🔄 **P2P Sync** - Sync your library across devices without an account (Brave-style)
- 💻 **Cross-Platform** - Works on Android, iOS, Web, Windows, and Linux

## 🚀 Getting Started

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

#### Windows
```bash
flutter build windows --release
```

#### Linux
```bash
flutter build linux --release
```

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── song.dart
│   ├── album.dart
│   ├── playlist.dart
│   ├── artist.dart
│   └── sync_chain.dart    # P2P sync data models
├── providers/             # State management (Provider)
│   ├── player_provider.dart
│   ├── library_provider.dart
│   ├── theme_provider.dart
│   └── sync_provider.dart # P2P sync state management
├── screens/               # App screens
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── library_screen.dart
│   ├── player_screen.dart
│   ├── playlist_screen.dart
│   ├── album_screen.dart
│   ├── artist_screen.dart
│   └── sync_screen.dart   # P2P sync settings screen
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

## 🎨 Design Principles

### Inspired by Metrolist
This app follows the design and UX principles of Metrolist:
- Clean, modern interface
- Music streaming focus (no video content)
- Library management
- Background playback support
- Offline capability (download support structure)
- **P2P Sync** - Account-free synchronization inspired by Brave browser

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

## 🛠 Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Audio**: just_audio, audio_service
- **Storage**: Hive, SharedPreferences
- **Networking**: http
- **Image Caching**: cached_network_image

## 📱 Screenshots

The app features:
- A modern home screen with personalized recommendations
- Search functionality with category browsing
- Library management with filters
- Full-featured music player
- Detailed screens for playlists, albums, and artists

## 🔧 Configuration

### Theme Customization
The app theme can be customized in `lib/utils/app_theme.dart`. You can modify:
- Primary colors
- Background colors
- Text styles
- Component themes

### Sample Data
Sample data for development is located in `lib/utils/sample_data.dart`. Replace this with your actual data source in production.

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 🔄 P2P Sync Feature

Flyer includes a peer-to-peer synchronization feature inspired by Brave browser's sync functionality. This allows you to sync your music library across multiple devices without creating an account.

### How It Works

1. **Start a New Sync Chain**: On your first device, create a new sync chain. You'll receive a 24-word sync code.
2. **Save Your Sync Code**: Store this code securely - it cannot be recovered!
3. **Connect Other Devices**: Enter the same 24-word code on your other devices to join the sync chain.
4. **Choose What to Sync**: Select which data to sync (liked songs, playlists, settings, etc.)

### Privacy Features

- **No Account Required**: Your data is never associated with an email or account
- **End-to-End Encrypted**: Only devices with the sync code can read your data
- **Decentralized**: Data syncs directly between devices via P2P
- **Full Control**: Remove devices or leave the sync chain at any time

### Supported Platforms for Sync

- ✅ Windows
- ✅ Linux  
- ✅ macOS
- ✅ Android
- ✅ iOS
- ✅ Web

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Metrolist](https://github.com/mostafaalagamy/Metrolist) - Design inspiration
- [Spotify](https://www.spotify.com) - UX reference
- [Flutter](https://flutter.dev) - Framework

---

Made with ❤️ using Flutter