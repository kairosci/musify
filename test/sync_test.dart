import 'package:flutter_test/flutter_test.dart';
import 'package:flyer/models/sync_chain.dart';
import 'package:flyer/providers/sync_provider.dart';

void main() {
  group('SyncChain Tests', () {
    test('SyncChain.create generates valid chain', () {
      final chain = SyncChain.create(deviceName: 'Test Device');

      expect(chain.id, isNotEmpty);
      expect(chain.deviceId, isNotEmpty);
      expect(chain.deviceName, equals('Test Device'));
      expect(chain.syncKey, isNotEmpty);
      expect(chain.isEnabled, isTrue);
    });

    test('SyncChain sync key has 24 words', () {
      final chain = SyncChain.create(deviceName: 'Test Device');
      final words = chain.syncKey.split(' ');

      expect(words.length, equals(24));
    });

    test('SyncChain copyWith preserves values', () {
      final chain = SyncChain.create(deviceName: 'Original');
      final copied = chain.copyWith(deviceName: 'Modified');

      expect(copied.id, equals(chain.id));
      expect(copied.deviceName, equals('Modified'));
      expect(copied.syncKey, equals(chain.syncKey));
    });

    test('SyncChain toMap and fromMap roundtrip', () {
      final chain = SyncChain.create(deviceName: 'Test Device');
      final map = chain.toMap();
      final restored = SyncChain.fromMap(map);

      expect(restored.id, equals(chain.id));
      expect(restored.deviceId, equals(chain.deviceId));
      expect(restored.deviceName, equals(chain.deviceName));
      expect(restored.syncKey, equals(chain.syncKey));
    });

    test('isValidSyncKey validates generated keys', () {
      final chain = SyncChain.create(deviceName: 'Test Device');
      expect(SyncChain.isValidSyncKey(chain.syncKey), isTrue);
    });

    test('isValidSyncKey rejects invalid keys', () {
      expect(SyncChain.isValidSyncKey('invalid key'), isFalse);
      expect(SyncChain.isValidSyncKey('one two three'), isFalse);
      expect(SyncChain.isValidSyncKey(''), isFalse);
      expect(SyncChain.isValidSyncKey('notaword ' * 24), isFalse);
    });

    test('isValidSyncKey accepts valid word combinations', () {
      // Using valid words from the new expanded word list
      final validKey = 'abandon ability able about above absent absorb abstract '
          'absurd abuse access accident account accuse achieve acid '
          'across action actor actual adapt address adjust admit';
      expect(SyncChain.isValidSyncKey(validKey), isTrue);
    });
  });

  group('SyncDevice Tests', () {
    test('SyncDevice creation', () {
      final device = SyncDevice(
        id: 'device-1',
        name: 'My PC',
        platform: 'windows',
        joinedAt: DateTime.now(),
        isCurrentDevice: true,
      );

      expect(device.id, equals('device-1'));
      expect(device.name, equals('My PC'));
      expect(device.platform, equals('windows'));
      expect(device.isCurrentDevice, isTrue);
    });

    test('SyncDevice platformIcon returns correct icon', () {
      final windowsDevice = SyncDevice(
        id: '1',
        name: 'PC',
        platform: 'windows',
        joinedAt: DateTime.now(),
      );
      final androidDevice = SyncDevice(
        id: '2',
        name: 'Phone',
        platform: 'android',
        joinedAt: DateTime.now(),
      );
      final linuxDevice = SyncDevice(
        id: '3',
        name: 'Linux Box',
        platform: 'linux',
        joinedAt: DateTime.now(),
      );

      expect(windowsDevice.platformIcon, equals('desktop_windows'));
      expect(androidDevice.platformIcon, equals('phone_android'));
      expect(linuxDevice.platformIcon, equals('computer'));
    });
  });

  group('SyncData Tests', () {
    test('SyncData creation and serialization', () {
      final data = SyncData(
        type: 'liked_songs',
        data: {'song_ids': ['1', '2', '3']},
        timestamp: DateTime.now(),
        sourceDeviceId: 'device-1',
      );

      expect(data.type, equals('liked_songs'));
      expect(data.data['song_ids'], contains('1'));

      final map = data.toMap();
      final restored = SyncData.fromMap(map);

      expect(restored.type, equals(data.type));
      expect(restored.sourceDeviceId, equals(data.sourceDeviceId));
    });
  });

  group('SyncStatus Tests', () {
    test('SyncStatus displayName returns correct strings', () {
      expect(SyncStatus.idle.displayName, equals('Ready to sync'));
      expect(SyncStatus.syncing.displayName, equals('Syncing...'));
      expect(SyncStatus.success.displayName, equals('Synced'));
      expect(SyncStatus.error.displayName, equals('Sync failed'));
      expect(SyncStatus.disabled.displayName, equals('Sync disabled'));
    });
  });

  group('SyncProvider Tests', () {
    late SyncProvider syncProvider;

    setUp(() {
      syncProvider = SyncProvider();
    });

    test('Initial state has no sync chain', () {
      expect(syncProvider.syncChain, isNull);
      expect(syncProvider.isEnabled, isFalse);
      expect(syncProvider.status, equals(SyncStatus.disabled));
    });

    test('Default sync preferences are set correctly', () {
      expect(syncProvider.syncLikedSongs, isTrue);
      expect(syncProvider.syncPlaylists, isTrue);
      expect(syncProvider.syncSettings, isTrue);
      expect(syncProvider.syncRecentlyPlayed, isFalse);
    });

    test('updateSyncPreferences updates correctly', () {
      syncProvider.updateSyncPreferences(syncLikedSongs: false);
      expect(syncProvider.syncLikedSongs, isFalse);

      syncProvider.updateSyncPreferences(syncRecentlyPlayed: true);
      expect(syncProvider.syncRecentlyPlayed, isTrue);
    });

    test('createSyncChain creates valid chain', () async {
      final syncKey = await syncProvider.createSyncChain(
        deviceName: 'Test Device',
      );

      expect(syncKey, isNotEmpty);
      expect(syncProvider.syncChain, isNotNull);
      expect(syncProvider.syncChain!.deviceName, equals('Test Device'));
      expect(syncProvider.isEnabled, isTrue);
      expect(syncProvider.deviceCount, equals(1));
    });

    test('createSyncChain adds current device', () async {
      await syncProvider.createSyncChain(deviceName: 'My Device');

      expect(syncProvider.connectedDevices.length, equals(1));
      expect(syncProvider.connectedDevices.first.isCurrentDevice, isTrue);
    });

    test('leaveSyncChain clears the chain', () async {
      await syncProvider.createSyncChain(deviceName: 'Test');
      expect(syncProvider.syncChain, isNotNull);

      await syncProvider.leaveSyncChain();
      expect(syncProvider.syncChain, isNull);
      expect(syncProvider.status, equals(SyncStatus.disabled));
    });

    test('toggleSync toggles enabled state', () async {
      await syncProvider.createSyncChain(deviceName: 'Test');
      expect(syncProvider.isEnabled, isTrue);

      syncProvider.toggleSync();
      expect(syncProvider.isEnabled, isFalse);
      expect(syncProvider.status, equals(SyncStatus.disabled));

      syncProvider.toggleSync();
      expect(syncProvider.isEnabled, isTrue);
    });

    test('syncKeyWords returns correct word list', () async {
      await syncProvider.createSyncChain(deviceName: 'Test');
      final words = syncProvider.syncKeyWords;

      expect(words.length, equals(24));
    });

    test('lastSyncTimeFormatted returns Never when no sync', () async {
      await syncProvider.createSyncChain(deviceName: 'Test');
      expect(syncProvider.lastSyncTimeFormatted, equals('Never'));
    });

    test('renameDevice updates device name', () async {
      await syncProvider.createSyncChain(deviceName: 'Original Name');
      syncProvider.renameDevice('New Name');

      expect(syncProvider.syncChain!.deviceName, equals('New Name'));
      expect(
        syncProvider.connectedDevices.first.name,
        equals('New Name'),
      );
    });
  });
}
