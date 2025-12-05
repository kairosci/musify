import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';

/**
 * Main screen with bottom navigation.
 * 
 * Contains the primary navigation structure with Home, Search,
 * and Library tabs along with the mini player.
 */
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Mini player at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<PlayerProvider>(
              builder: (context, playerProvider, child) {
                if (playerProvider.currentSong == null) {
                  return const SizedBox.shrink();
                }
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MiniPlayer(),
                    SizedBox(height: 56), // Space for bottom nav
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined),
                  activeIcon: Icon(Icons.library_music),
                  label: 'Library',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
