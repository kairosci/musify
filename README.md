# Flyer 🎵

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" alt="Platform">
  <img src="https://img.shields.io/badge/Material%20Design-3-purple" alt="Material 3">
  <img src="https://img.shields.io/badge/State%20Management-Provider-orange" alt="Provider">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

<p align="center">
  <strong>A Spotify-like music streaming app built with Flutter</strong><br>
  Inspired by <a href="https://github.com/mostafaalagamy/Metrolist">Metrolist</a> • Material 3 Design • Red Accent Theme
</p>

---

## 📑 Indice / Table of Contents

- [✨ Funzionalità / Features](#-funzionalità--features)
  - [🎵 Riproduzione Audio / Audio Playback](#-riproduzione-audio--audio-playback)
  - [📚 Gestione Libreria / Library Management](#-gestione-libreria--library-management)
  - [🔍 Ricerca e Navigazione / Search & Navigation](#-ricerca-e-navigazione--search--navigation)
  - [🎨 Design e Tema / Design & Theme](#-design-e-tema--design--theme)
- [🏗️ Architettura / Architecture](#️-architettura--architecture)
  - [📊 Modelli Dati / Data Models](#-modelli-dati--data-models)
  - [🔄 State Management](#-state-management)
  - [📱 Schermate / Screens](#-schermate--screens)
  - [🧩 Widget Riutilizzabili / Reusable Widgets](#-widget-riutilizzabili--reusable-widgets)
- [🚀 Guida all'Installazione / Getting Started](#-guida-allinstallazione--getting-started)
- [🛠️ Tech Stack e Dipendenze / Dependencies](#️-tech-stack-e-dipendenze--dependencies)
- [🎨 Sistema di Design / Design System](#-sistema-di-design--design-system)
- [🔧 Configurazione / Configuration](#-configurazione--configuration)
- [🧪 Testing](#-testing)
- [📄 Licenza / License](#-licenza--license)

---

## ✨ Funzionalità / Features

### 🎵 Riproduzione Audio / Audio Playback

| Funzionalità | Descrizione |
|-------------|-------------|
| **Player a Schermo Intero** | Visualizzazione completa con copertina album, controlli e barra di progresso |
| **Mini Player** | Player compatto sempre visibile nella parte inferiore dello schermo |
| **Play/Pause** | Controllo base della riproduzione |
| **Skip Avanti/Indietro** | Navigazione tra i brani nella coda |
| **Seek/Scrubbing** | Spostamento rapido in qualsiasi punto del brano |
| **Modalità Shuffle** | Riproduzione casuale con mantenimento del brano corrente |
| **Modalità Repeat** | Tre modalità: Off, Ripeti Tutti, Ripeti Uno |
| **Gestione Volume** | Controllo del volume da 0% a 100% |
| **Gestione Coda** | Visualizzazione e modifica della coda di riproduzione |
| **Play Next** | Aggiunta brani da riprodurre successivamente |
| **Background Playback** | Supporto per riproduzione in background (struttura predisposta) |

### 📚 Gestione Libreria / Library Management

| Funzionalità | Descrizione |
|-------------|-------------|
| **Brani Preferiti** | Salva e gestisci i tuoi brani preferiti con ❤️ |
| **Playlist Personalizzate** | Crea, modifica ed elimina playlist |
| **Album Salvati** | Aggiungi album alla tua libreria |
| **Artisti Seguiti** | Segui i tuoi artisti preferiti |
| **Cronologia Recenti** | Ultimi 50 brani riprodotti |
| **Download Manager** | Sistema di download con coda e simulazione |
| **Offline Mode** | Struttura predisposta per brani scaricati |
| **Playlist Collaborative** | Supporto per playlist condivise |

### 🔍 Ricerca e Navigazione / Search & Navigation

| Funzionalità | Descrizione |
|-------------|-------------|
| **Ricerca Globale** | Cerca brani, album, artisti e playlist |
| **Filtri per Categoria** | Risultati organizzati per tipo di contenuto |
| **Browse Categories** | 16 categorie musicali (Pop, Hip-Hop, Rock, Latin, ecc.) |
| **Quick Picks** | Raccomandazioni personalizzate |
| **Nuove Uscite** | Album appena pubblicati |
| **Made For You** | Playlist create per te |
| **Quick Access Grid** | Accesso rapido ai contenuti recenti |

### 🎨 Design e Tema / Design & Theme

| Funzionalità | Descrizione |
|-------------|-------------|
| **Material Design 3** | UI moderna seguendo le linee guida Material |
| **Tema Scuro** | Tema dark Spotify-like come default |
| **Tema Chiaro** | Alternativa luminosa disponibile |
| **Colore Primario Rosso** | Accent color distintivo (#E53935) |
| **Responsive Design** | Adattamento a diverse dimensioni schermo |
| **Animazioni Fluide** | Transizioni e animazioni ottimizzate |

---

## 🏗️ Architettura / Architecture

### 📊 Modelli Dati / Data Models

```
lib/models/
├── song.dart       # Brani musicali
├── album.dart      # Album
├── playlist.dart   # Playlist
└── artist.dart     # Artisti
```

#### Song (Brano)
```dart
- id, title, artist, album, albumId
- imageUrl, audioUrl, duration
- isExplicit, isLiked, addedAt
- Metodi: copyWith(), toMap(), fromMap()
- Getter: formattedDuration
```

#### Album
```dart
- id, title, artist, artistId
- imageUrl, year, songs[], genre, isExplicit
- Getter: songCount, totalDuration, formattedTotalDuration
```

#### Playlist
```dart
- id, title, description, imageUrl
- ownerId, ownerName, songs[]
- isPublic, isCollaborative
- createdAt, updatedAt
- Getter: displayImage (fallback su prima canzone)
```

#### Artist (Artista)
```dart
- id, name, imageUrl, bio
- followers, topSongs[], albums[], genres[]
- isVerified
- Getter: formattedFollowers (K/M formatting)
```

### 🔄 State Management

```
lib/providers/
├── player_provider.dart    # Stato riproduzione
├── library_provider.dart   # Libreria utente
└── theme_provider.dart     # Gestione tema
```

#### PlayerProvider
Gestisce lo stato completo della riproduzione audio:

| Stato | Descrizione |
|-------|-------------|
| `playbackState` | stopped, playing, paused, buffering |
| `currentSong` | Brano attualmente in riproduzione |
| `queue` | Lista brani in coda |
| `position/duration` | Posizione e durata corrente |
| `volume` | Volume (0.0 - 1.0) |
| `shuffle` | Modalità casuale attiva |
| `repeatMode` | off, all, one |

**Metodi principali:**
- `playSong()`, `togglePlayPause()`, `skipNext()`, `skipPrevious()`
- `seekTo()`, `seekToPercent()`, `setVolume()`
- `toggleShuffle()`, `toggleRepeat()`
- `addToQueue()`, `playNext()`, `removeFromQueue()`, `clearQueue()`

#### LibraryProvider
Gestisce la libreria dell'utente:

| Collezione | Metodi |
|-----------|--------|
| **Liked Songs** | `isLiked()`, `toggleLike()`, `addToLiked()`, `removeFromLiked()` |
| **Playlists** | `createPlaylist()`, `updatePlaylist()`, `deletePlaylist()`, `addSongToPlaylist()` |
| **Albums** | `isAlbumSaved()`, `saveAlbum()`, `removeAlbum()`, `toggleAlbumSaved()` |
| **Artists** | `isArtistFollowed()`, `followArtist()`, `unfollowArtist()`, `toggleFollowArtist()` |
| **Recently Played** | `addToRecentlyPlayed()`, `clearRecentlyPlayed()` |
| **Downloads** | `downloadSong()`, `removeDownload()`, `cancelDownload()` |

#### ThemeProvider
```dart
- themeMode: ThemeMode.dark (default)
- isDarkMode: getter booleano
- setThemeMode(), toggleTheme()
```

### 📱 Schermate / Screens

```
lib/screens/
├── main_screen.dart      # Container principale con BottomNavigation
├── home_screen.dart      # Home con raccomandazioni
├── search_screen.dart    # Ricerca e categorie
├── library_screen.dart   # Libreria utente
├── player_screen.dart    # Player a schermo intero
├── playlist_screen.dart  # Dettaglio playlist
├── album_screen.dart     # Dettaglio album
└── artist_screen.dart    # Pagina artista
```

| Schermata | Contenuto Principale |
|-----------|---------------------|
| **MainScreen** | BottomNavigationBar + MiniPlayer |
| **HomeScreen** | Greeting dinamico, Quick Access Grid, Quick Picks, Made For You, New Releases, Popular Artists, Recently Played |
| **SearchScreen** | Search bar, risultati filtrati, 16 categorie browse |
| **LibraryScreen** | Tabs per Liked Songs, Playlists, Albums, Artists |
| **PlayerScreen** | Full-screen player con tutti i controlli |
| **PlaylistScreen** | Header, lista brani, azioni playlist |
| **AlbumScreen** | Copertina, info album, tracklist |
| **ArtistScreen** | Bio, top songs, discografia |

### 🧩 Widget Riutilizzabili / Reusable Widgets

```
lib/widgets/
├── mini_player.dart      # Player compatto
├── song_tile.dart        # Elemento lista brano
├── playlist_card.dart    # Card playlist
├── album_card.dart       # Card album
├── artist_card.dart      # Card artista (circolare)
└── section_header.dart   # Header sezione con "Show All"
```

---

## 🚀 Guida all'Installazione / Getting Started

### Prerequisiti / Prerequisites

- **Flutter SDK** 3.0+
- **Dart SDK** 3.0+
- **Android Studio** / **VS Code** con estensioni Flutter
- **Git**

### Installazione / Installation

```bash
# 1. Clona il repository
git clone https://github.com/kairosci/flyer-test.git
cd flyer-test

# 2. Installa le dipendenze
flutter pub get

# 3. Avvia l'applicazione
flutter run
```

### Build per Produzione / Production Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (per Play Store)
flutter build appbundle --release

# iOS (richiede macOS)
flutter build ios --release

# Web
flutter build web --release
```

---

## 🛠️ Tech Stack e Dipendenze / Dependencies

### Framework & Core

| Pacchetto | Versione | Utilizzo |
|-----------|----------|----------|
| Flutter | 3.x | Framework UI |
| Dart | 3.0+ | Linguaggio |
| Provider | ^6.1.1 | State Management |

### UI Components

| Pacchetto | Versione | Utilizzo |
|-----------|----------|----------|
| cupertino_icons | ^1.0.6 | Icone iOS |
| flutter_svg | ^2.0.9 | Supporto SVG |
| cached_network_image | ^3.3.1 | Cache immagini |
| shimmer | ^3.0.0 | Effetti loading |

### Audio Playback

| Pacchetto | Versione | Utilizzo |
|-----------|----------|----------|
| just_audio | ^0.9.36 | Player audio |
| audio_service | ^0.18.12 | Background audio |
| just_audio_background | ^0.0.1-beta.11 | Notifiche audio |

### Storage

| Pacchetto | Versione | Utilizzo |
|-----------|----------|----------|
| hive | ^2.2.3 | Database locale NoSQL |
| hive_flutter | ^1.1.0 | Integrazione Hive |
| shared_preferences | ^2.2.2 | Preferenze semplici |
| path_provider | ^2.1.1 | Percorsi file system |

### Networking & Utilities

| Pacchetto | Versione | Utilizzo |
|-----------|----------|----------|
| http | ^1.1.2 | Richieste HTTP |
| uuid | ^4.2.2 | Generazione ID univoci |
| intl | ^0.18.1 | Internazionalizzazione |
| palette_generator | ^0.3.3+3 | Estrazione colori |
| rxdart | ^0.27.7 | Reactive extensions |

### Dev Dependencies

| Pacchetto | Versione | Utilizzo |
|-----------|----------|----------|
| flutter_test | SDK | Testing |
| flutter_lints | ^3.0.1 | Linting |
| hive_generator | ^2.0.1 | Code generation for Hive models |
| build_runner | ^2.4.8 | Build automation |

---

## 🎨 Sistema di Design / Design System

### Palette Colori / Color Palette

#### Tema Scuro (Default)

| Elemento | Colore | Hex |
|----------|--------|-----|
| **Primary** | Rosso | `#E53935` |
| **Primary Light** | Rosso chiaro | `#FF6F60` |
| **Primary Dark** | Rosso scuro | `#AB000D` |
| **Background** | Nero | `#121212` |
| **Background Secondary** | Grigio scuro | `#181818` |
| **Background Tertiary** | Grigio | `#282828` |
| **Surface** | Grigio superficie | `#1E1E1E` |
| **Text Primary** | Bianco | `#FFFFFF` |
| **Text Secondary** | Grigio chiaro | `#B3B3B3` |
| **Text Tertiary** | Grigio | `#727272` |

#### Tema Chiaro

| Elemento | Colore | Hex |
|----------|--------|-----|
| **Background** | Bianco sporco | `#FAFAFA` |
| **Surface** | Bianco | `#FFFFFF` |
| **Text Primary** | Nero | `#000000` |
| **Text Secondary** | Grigio | `#6A6A6A` |

### Tipografia / Typography

| Stile | Dimensione | Peso | Utilizzo |
|-------|------------|------|----------|
| Display Large | 32px | Bold | Titoli principali |
| Display Medium | 28px | Bold | Titoli secondari |
| Headline Large | 24px | Bold | Header sezioni |
| Headline Medium | 20px | Bold | Sottotitoli |
| Headline Small | 18px | Semi-bold | Titoli card |
| Title Large | 16px | Semi-bold | Nomi elementi |
| Title Medium | 14px | Semi-bold | Sottotitoli elementi |
| Body Large | 16px | Normal | Testo principale |
| Body Medium | 14px | Normal | Testo secondario |
| Body Small | 12px | Normal | Didascalie |

### Categorie Browse / Browse Categories

L'app include 16 categorie musicali predefinite:

| Categoria | Colore | Icona |
|-----------|--------|-------|
| Podcasts | Purple | podcasts |
| Live Events | Deep Orange | live_tv |
| Made For You | Red | favorite |
| New Releases | Teal | new_releases |
| Charts | Indigo | trending_up |
| Pop | Pink | bubble_chart |
| Hip-Hop | Amber | speaker |
| Rock | Red | electric_bolt |
| Latin | Green | music_note |
| Dance | Blue | nightlife |
| Indie | Orange | radio |
| Workout | Light Green | fitness_center |
| Chill | Cyan | waves |
| Focus | Deep Purple | psychology |
| Sleep | Blue Grey | bedtime |
| Party | Pink Accent | celebration |

---

## 🔧 Configurazione / Configuration

### Personalizzazione Tema / Theme Customization

Modifica `lib/utils/app_theme.dart` per personalizzare:

```dart
// Colori primari
static const Color primaryRed = Color(0xFFE53935);

// Sfondi
static const Color backgroundDark = Color(0xFF121212);

// Configurazioni tema completo in darkTheme e lightTheme
```

### Dati di Esempio / Sample Data

I dati di sviluppo sono in `lib/utils/sample_data.dart`. In produzione, sostituisci con:
- API backend
- Database locale (Hive)
- Servizio di streaming

### Configurazione Audio / Audio Configuration

L'app è predisposta per:
- Riproduzione in background
- Notifiche media controls
- Cache audio

---

## 🧪 Testing

```bash
# Esegui tutti i test
flutter test

# Test con coverage
flutter test --coverage

# Analisi statica
flutter analyze
```

---

## 📄 Licenza / License

Questo progetto è rilasciato sotto licenza **MIT**. Vedi il file [LICENSE](LICENSE) per i dettagli.

---

## 🙏 Ringraziamenti / Acknowledgments

- [Metrolist](https://github.com/mostafaalagamy/Metrolist) - Ispirazione design
- [Spotify](https://www.spotify.com) - Riferimento UX
- [Flutter](https://flutter.dev) - Framework
- [Material Design 3](https://m3.material.io/) - Design System

---

<p align="center">
  Made with ❤️ using Flutter<br>
  <sub>Sviluppato con passione per la musica 🎵</sub>
</p>