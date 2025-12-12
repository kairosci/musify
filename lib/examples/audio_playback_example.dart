import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../services/piped_service.dart';

/// Example demonstrating how to use the new audio playback functionality
class AudioPlaybackExample extends StatefulWidget {
  const AudioPlaybackExample({super.key});

  @override
  State<AudioPlaybackExample> createState() => _AudioPlaybackExampleState();
}

class _AudioPlaybackExampleState extends State<AudioPlaybackExample> {
  bool _isSearching = false;
  List<PipedVideoItem> _searchResults = [];

  Future<void> _searchMusic(String query) async {
    setState(() => _isSearching = true);
    
    try {
      final result = await PipedService.searchMusic(query);
      setState(() {
        _searchResults = result.items;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _playSong(BuildContext context, int index) async {
    final playerProvider = context.read<PlayerProvider>();
    final songs = _searchResults.map((item) => item.toSong()).toList();
    await playerProvider.playSong(songs[index], playlist: songs, startIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Playback Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search for music',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: _searchMusic,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.uploaderName),
                        onTap: () => _playSong(context, index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
