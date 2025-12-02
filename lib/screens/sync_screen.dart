import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../models/sync_chain.dart';

/// Screen for managing P2P sync settings
/// Inspired by Brave's sync feature - no account required
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
        centerTitle: true,
      ),
      body: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          if (syncProvider.syncChain == null) {
            return const _SetupSyncView();
          }
          return const _SyncSettingsView();
        },
      ),
    );
  }
}

/// View shown when sync is not set up yet
class _SetupSyncView extends StatelessWidget {
  const _SetupSyncView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Icon(
              Icons.sync,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Sync Your Music Library',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Keep your liked songs, playlists, and settings in sync across all your devices. No account required.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),

          // Start new sync chain
          _ActionCard(
            icon: Icons.add_circle_outline,
            title: 'Start a New Sync Chain',
            subtitle: 'Create a new sync chain and get a 24-word recovery phrase',
            onTap: () => _showStartSyncDialog(context),
          ),
          const SizedBox(height: 16),

          // Join existing sync chain
          _ActionCard(
            icon: Icons.link,
            title: 'Join Existing Sync Chain',
            subtitle: 'Enter your 24-word sync code from another device',
            onTap: () => _showJoinSyncDialog(context),
          ),
          const SizedBox(height: 32),

          // Info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy First',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• End-to-end encrypted peer-to-peer sync\n'
                  '• No account or email required\n'
                  '• Your data never touches our servers\n'
                  '• Works across Windows, Linux, macOS, Android, iOS, and Web',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStartSyncDialog(BuildContext context) {
    final deviceNameController = TextEditingController();
    final syncProvider = context.read<SyncProvider>();
    deviceNameController.text = syncProvider.defaultDeviceName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Sync Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter a name for this device:'),
            const SizedBox(height: 12),
            TextField(
              controller: deviceNameController,
              decoration: const InputDecoration(
                hintText: 'Device name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final syncKey = await syncProvider.createSyncChain(
                  deviceName: deviceNameController.text.isNotEmpty 
                      ? deviceNameController.text 
                      : null,
                );
                if (context.mounted) {
                  _showSyncKeyDialog(context, syncKey);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showSyncKeyDialog(BuildContext context, String syncKey) {
    final theme = Theme.of(context);
    final words = syncKey.split(' ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Your Sync Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save these 24 words in a safe place. You\'ll need them to connect other devices.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: words.asMap().entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This code cannot be recovered. Store it securely!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: syncKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync code copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I\'ve Saved It'),
          ),
        ],
      ),
    );
  }

  void _showJoinSyncDialog(BuildContext context) {
    final syncCodeController = TextEditingController();
    final deviceNameController = TextEditingController();
    final syncProvider = context.read<SyncProvider>();
    deviceNameController.text = syncProvider.defaultDeviceName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Sync Chain'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your 24-word sync code:'),
              const SizedBox(height: 12),
              TextField(
                controller: syncCodeController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'word1 word2 word3 ...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Device name:'),
              const SizedBox(height: 8),
              TextField(
                controller: deviceNameController,
                decoration: const InputDecoration(
                  hintText: 'Device name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final syncCode = syncCodeController.text.trim();
              if (syncCode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your sync code')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await syncProvider.joinSyncChain(
                  syncCode,
                  deviceName: deviceNameController.text.isNotEmpty 
                      ? deviceNameController.text 
                      : null,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully joined sync chain!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

/// View shown when sync is set up
class _SyncSettingsView extends StatelessWidget {
  const _SyncSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sync status header
              _SyncStatusHeader(syncProvider: syncProvider),
              
              const Divider(height: 1),

              // Sync now button
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Now'),
                subtitle: Text('Last synced: ${syncProvider.lastSyncTimeFormatted}'),
                trailing: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: syncProvider.isSyncing ? null : () => syncProvider.syncNow(),
              ),

              const Divider(height: 1),

              // Section: What to sync
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'What to Sync',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SwitchListTile(
                title: const Text('Liked Songs'),
                subtitle: const Text('Sync your favorite tracks'),
                value: syncProvider.syncLikedSongs,
                onChanged: (value) => syncProvider.updateSyncPreferences(
                  syncLikedSongs: value,
                ),
              ),
              SwitchListTile(
                title: const Text('Playlists'),
                subtitle: const Text('Sync your custom playlists'),
                value: syncProvider.syncPlaylists,
                onChanged: (value) => syncProvider.updateSyncPreferences(
                  syncPlaylists: value,
                ),
              ),
              SwitchListTile(
                title: const Text('Settings'),
                subtitle: const Text('Sync theme and preferences'),
                value: syncProvider.syncSettings,
                onChanged: (value) => syncProvider.updateSyncPreferences(
                  syncSettings: value,
                ),
              ),
              SwitchListTile(
                title: const Text('Recently Played'),
                subtitle: const Text('Sync playback history'),
                value: syncProvider.syncRecentlyPlayed,
                onChanged: (value) => syncProvider.updateSyncPreferences(
                  syncRecentlyPlayed: value,
                ),
              ),

              const Divider(height: 1),

              // Section: Connected devices
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Connected Devices',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${syncProvider.deviceCount} device${syncProvider.deviceCount != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              ...syncProvider.connectedDevices.map((device) => _DeviceTile(
                device: device,
                onRemove: device.isCurrentDevice
                    ? null
                    : () => _confirmRemoveDevice(context, syncProvider, device),
              )),

              const SizedBox(height: 8),

              // Add new device
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Another Device'),
                subtitle: const Text('Show sync code to add more devices'),
                onTap: () => _showSyncCode(context, syncProvider),
              ),

              const Divider(height: 32),

              // Section: Manage Sync
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Manage Sync',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              ListTile(
                leading: Icon(
                  syncProvider.isEnabled ? Icons.pause : Icons.play_arrow,
                ),
                title: Text(syncProvider.isEnabled ? 'Pause Sync' : 'Resume Sync'),
                subtitle: Text(
                  syncProvider.isEnabled 
                      ? 'Temporarily stop syncing' 
                      : 'Resume syncing between devices',
                ),
                onTap: () => syncProvider.toggleSync(),
              ),

              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Leave Sync Chain',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Remove this device from sync'),
                onTap: () => _confirmLeaveSyncChain(context, syncProvider),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _showSyncCode(BuildContext context, SyncProvider syncProvider) {
    final theme = Theme.of(context);
    final words = syncProvider.syncKeyWords;
    final syncKey = syncProvider.syncChain?.syncKey ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Sync Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter this code on your other device to sync your library.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: words.asMap().entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: syncKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync code copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveDevice(
    BuildContext context,
    SyncProvider syncProvider,
    SyncDevice device,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text(
          'Are you sure you want to remove "${device.name}" from your sync chain?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              syncProvider.removeDevice(device.id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveSyncChain(BuildContext context, SyncProvider syncProvider) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Sync Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to leave this sync chain?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your local data will be kept, but this device will no longer sync with others.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              syncProvider.leaveSyncChain();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

/// Sync status header widget
class _SyncStatusHeader extends StatelessWidget {
  final SyncProvider syncProvider;

  const _SyncStatusHeader({required this.syncProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color statusColor;
    IconData statusIcon;
    
    switch (syncProvider.status) {
      case SyncStatus.syncing:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.sync;
        break;
      case SyncStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.error:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.error;
        break;
      case SyncStatus.disabled:
        statusColor = theme.colorScheme.onSurface.withOpacity(0.5);
        statusIcon = Icons.sync_disabled;
        break;
      default:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.sync;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  syncProvider.isEnabled ? 'Sync Enabled' : 'Sync Paused',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  syncProvider.status.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action card for setup view
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Device tile widget
class _DeviceTile extends StatelessWidget {
  final SyncDevice device;
  final VoidCallback? onRemove;

  const _DeviceTile({
    required this.device,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData platformIcon;
    switch (device.platform.toLowerCase()) {
      case 'windows':
        platformIcon = Icons.desktop_windows;
        break;
      case 'linux':
        platformIcon = Icons.computer;
        break;
      case 'macos':
        platformIcon = Icons.laptop_mac;
        break;
      case 'android':
        platformIcon = Icons.phone_android;
        break;
      case 'ios':
        platformIcon = Icons.phone_iphone;
        break;
      case 'web':
        platformIcon = Icons.language;
        break;
      default:
        platformIcon = Icons.devices;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(platformIcon),
      ),
      title: Row(
        children: [
          Flexible(child: Text(device.name)),
          if (device.isCurrentDevice) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'This device',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        device.lastSeenAt != null
            ? 'Last seen: ${_formatLastSeen(device.lastSeenAt!)}'
            : 'Never synced',
      ),
      trailing: onRemove != null
          ? IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showDeviceMenu(context),
            )
          : null,
    );
  }

  void _showDeviceMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove Device'),
              onTap: () {
                Navigator.pop(context);
                onRemove?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }
}
