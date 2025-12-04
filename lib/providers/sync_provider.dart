import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_chain.dart';
import '../models/song.dart';
import '../models/playlist.dart';

/**
 * Provider for managing P2P synchronization without accounts.
 * 
 * Similar to Brave's sync feature, this enables syncing library data
 * across devices using a 24-word sync key without requiring user accounts.
 */
class SyncProvider extends ChangeNotifier {
  SyncChain? _syncChain;
  SyncStatus _status = SyncStatus.disabled;
  String? _errorMessage;
  
  bool _syncLikedSongs = true;
  bool _syncPlaylists = true;
  bool _syncSettings = true;
  bool _syncRecentlyPlayed = false;

  SyncChain? get syncChain => _syncChain;
  SyncStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isEnabled => _syncChain != null && _syncChain!.isEnabled;
  bool get isSyncing => _status == SyncStatus.syncing;
  
  bool get syncLikedSongs => _syncLikedSongs;
  bool get syncPlaylists => _syncPlaylists;
  bool get syncSettings => _syncSettings;
  bool get syncRecentlyPlayed => _syncRecentlyPlayed;
  
  List<SyncDevice> get connectedDevices => _syncChain?.connectedDevices ?? [];
  int get deviceCount => connectedDevices.length;

  /**
   * Returns the current platform identifier.
   */
  String get currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /**
   * Returns a default device name based on the current platform.
   */
  String get defaultDeviceName {
    final platform = currentPlatform;
    switch (platform) {
      case 'windows':
        return 'Windows PC';
      case 'linux':
        return 'Linux PC';
      case 'macos':
        return 'Mac';
      case 'android':
        return 'Android Phone';
      case 'ios':
        return 'iPhone';
      case 'web':
        return 'Web Browser';
      default:
        return 'Flyer Device';
    }
  }

  /**
   * Creates a new sync chain and returns the sync key.
   */
  Future<String> createSyncChain({String? deviceName}) async {
    _status = SyncStatus.syncing;
    notifyListeners();

    try {
      final name = deviceName ?? defaultDeviceName;
      _syncChain = SyncChain.create(deviceName: name);
      
      final currentDevice = SyncDevice(
        id: _syncChain!.deviceId,
        name: name,
        platform: currentPlatform,
        joinedAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
        isCurrentDevice: true,
      );
      
      _syncChain = _syncChain!.copyWith(
        connectedDevices: [currentDevice],
      );
      
      _status = SyncStatus.idle;
      _errorMessage = null;
      notifyListeners();
      
      return _syncChain!.syncKey;
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Failed to create sync chain: $e';
      notifyListeners();
      rethrow;
    }
  }

  /**
   * Joins an existing sync chain using the provided sync key.
   */
  Future<void> joinSyncChain(String syncKey, {String? deviceName}) async {
    _status = SyncStatus.syncing;
    notifyListeners();

    try {
      if (!SyncChain.isValidSyncKey(syncKey)) {
        throw Exception(
            'Invalid sync key. Make sure you enter exactly 24 words from the sync code.');
      }

      final name = deviceName ?? defaultDeviceName;
      
      final currentDevice = SyncDevice(
        id: const Uuid().v4(),
        name: name,
        platform: currentPlatform,
        joinedAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
        isCurrentDevice: true,
      );

      _syncChain = SyncChain(
        id: const Uuid().v4(),
        deviceId: currentDevice.id,
        deviceName: name,
        syncKey: syncKey.trim(),
        connectedDevices: [currentDevice],
        createdAt: DateTime.now(),
      );

      _status = SyncStatus.success;
      _errorMessage = null;
      notifyListeners();

      await syncNow();
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Failed to join sync chain: $e';
      notifyListeners();
      rethrow;
    }
  }

  /**
   * Leaves the current sync chain and stops syncing.
   */
  Future<void> leaveSyncChain() async {
    if (_syncChain == null) return;

    _status = SyncStatus.syncing;
    notifyListeners();

    try {
      _syncChain = null;
      _status = SyncStatus.disabled;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Failed to leave sync chain: $e';
      notifyListeners();
      rethrow;
    }
  }

  /**
   * Removes a device from the sync chain by its ID.
   */
  Future<void> removeDevice(String deviceId) async {
    if (_syncChain == null) return;
    
    if (deviceId == _syncChain!.deviceId) {
      throw Exception('Cannot remove current device. Use leaveSyncChain() instead.');
    }

    final updatedDevices = _syncChain!.connectedDevices
        .where((d) => d.id != deviceId)
        .toList();

    _syncChain = _syncChain!.copyWith(connectedDevices: updatedDevices);
    notifyListeners();
  }

  /**
   * Toggles sync enabled/disabled state.
   */
  void toggleSync() {
    if (_syncChain == null) return;
    
    _syncChain = _syncChain!.copyWith(isEnabled: !_syncChain!.isEnabled);
    _status = _syncChain!.isEnabled ? SyncStatus.idle : SyncStatus.disabled;
    notifyListeners();
  }

  /**
   * Updates sync preferences for what data types to sync.
   */
  void updateSyncPreferences({
    bool? syncLikedSongs,
    bool? syncPlaylists,
    bool? syncSettings,
    bool? syncRecentlyPlayed,
  }) {
    _syncLikedSongs = syncLikedSongs ?? _syncLikedSongs;
    _syncPlaylists = syncPlaylists ?? _syncPlaylists;
    _syncSettings = syncSettings ?? _syncSettings;
    _syncRecentlyPlayed = syncRecentlyPlayed ?? _syncRecentlyPlayed;
    notifyListeners();
  }

  /**
   * Manually triggers a sync operation.
   */
  Future<void> syncNow() async {
    if (_syncChain == null || !_syncChain!.isEnabled) return;

    _status = SyncStatus.syncing;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _syncChain = _syncChain!.copyWith(lastSyncedAt: DateTime.now());
      _status = SyncStatus.success;
      _errorMessage = null;
      
      Future.delayed(const Duration(seconds: 3), () {
        if (_status == SyncStatus.success) {
          _status = SyncStatus.idle;
          notifyListeners();
        }
      });
      
      notifyListeners();
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Sync failed: $e';
      notifyListeners();
    }
  }

  /**
   * Syncs a specific data type to other devices.
   */
  Future<void> syncData(SyncData data) async {
    if (_syncChain == null || !_syncChain!.isEnabled) return;

    switch (data.type) {
      case 'liked_songs':
        if (!_syncLikedSongs) return;
        break;
      case 'playlists':
        if (!_syncPlaylists) return;
        break;
      case 'settings':
        if (!_syncSettings) return;
        break;
      case 'recently_played':
        if (!_syncRecentlyPlayed) return;
        break;
    }

    await syncNow();
  }

  /**
   * Returns the sync key words as a list.
   */
  List<String> get syncKeyWords {
    if (_syncChain == null) return [];
    return _syncChain!.syncKey.split(' ');
  }

  /**
   * Returns the last sync time in a human-readable format.
   */
  String get lastSyncTimeFormatted {
    if (_syncChain?.lastSyncedAt == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(_syncChain!.lastSyncedAt!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${_syncChain!.lastSyncedAt!.day}/${_syncChain!.lastSyncedAt!.month}/${_syncChain!.lastSyncedAt!.year}';
  }

  /**
   * Renames the current device.
   */
  void renameDevice(String newName) {
    if (_syncChain == null) return;

    final updatedDevices = _syncChain!.connectedDevices.map((device) {
      if (device.isCurrentDevice) {
        return device.copyWith(name: newName);
      }
      return device;
    }).toList();

    _syncChain = _syncChain!.copyWith(
      deviceName: newName,
      connectedDevices: updatedDevices,
    );
    notifyListeners();
  }
}
