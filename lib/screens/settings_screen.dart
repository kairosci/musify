import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/piped_service.dart';
import '../utils/app_theme.dart';

/**
 * Settings screen for configuring the app preferences.
 */
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentInstance = PipedService.currentInstance;
  bool _isCheckingInstance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Audio Source Section
          _SectionHeader(title: 'Audio Source'),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Piped Instance'),
            subtitle: Text(
              _currentInstance,
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 12,
              ),
            ),
            trailing: _isCheckingInstance
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _showInstancePicker,
          ),
          const Divider(),

          // About Section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Flyer'),
            subtitle: const Text('A modern music streaming app'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('Audio Only'),
            subtitle: const Text('This app streams audio only, no videos'),
            enabled: false,
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(),

          // Playback Section
          _SectionHeader(title: 'Playback'),
          SwitchListTile(
            secondary: const Icon(Icons.high_quality),
            title: const Text('High Quality Audio'),
            subtitle: const Text('Stream in higher bitrate'),
            value: true,
            onChanged: (value) {
              // TODO: Implement quality settings
            },
            activeColor: AppTheme.primaryRed,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.equalizer),
            title: const Text('Audio Normalization'),
            subtitle: const Text('Normalize volume across tracks'),
            value: false,
            onChanged: (value) {
              // TODO: Implement normalization
            },
            activeColor: AppTheme.primaryRed,
          ),
          const Divider(),

          // Privacy Section
          _SectionHeader(title: 'Privacy'),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy-First'),
            subtitle: Text('No tracking, no ads. Uses Piped for streaming.'),
            enabled: false,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showInstancePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundDarkSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiaryDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Piped Instance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a server for audio streaming',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(),
          ...PipedService.availableInstances.map((instance) => ListTile(
                leading: Icon(
                  _currentInstance == instance
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: _currentInstance == instance
                      ? AppTheme.primaryRed
                      : AppTheme.textSecondaryDark,
                ),
                title: Text(instance.replaceAll('https://', '')),
                onTap: () => _selectInstance(instance),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectInstance(String instance) async {
    Navigator.pop(context);
    
    setState(() {
      _isCheckingInstance = true;
    });

    final isAvailable = await PipedService.checkInstance(instance);
    
    if (isAvailable) {
      PipedService.setInstance(instance);
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('piped_instance', instance);
      
      setState(() {
        _currentInstance = instance;
        _isCheckingInstance = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to ${instance.replaceAll('https://', '')}')),
        );
      }
    } else {
      setState(() {
        _isCheckingInstance = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instance not available, please try another'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkSecondary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Flyer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'A modern music streaming app built with Flutter, using YouTube Music as audio source via Piped API.',
              style: TextStyle(color: AppTheme.textSecondaryDark),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Audio-only streaming via Piped'),
            Text('• No ads, no tracking'),
            Text('• Privacy-focused'),
            Text('• P2P sync across devices'),
            Text('• Open source alternative frontend'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/**
 * Section header widget for settings categories.
 */
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSecondaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
