import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';

/// Represents a sync chain for peer-to-peer synchronization without accounts
/// Similar to Brave's sync feature
class SyncChain {
  final String id;
  final String deviceId;
  final String deviceName;
  final String syncKey; // 24-word phrase for recovery
  final List<SyncDevice> connectedDevices;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  final bool isEnabled;

  const SyncChain({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.syncKey,
    this.connectedDevices = const [],
    required this.createdAt,
    this.lastSyncedAt,
    this.isEnabled = true,
  });

  SyncChain copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? syncKey,
    List<SyncDevice>? connectedDevices,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    bool? isEnabled,
  }) {
    return SyncChain(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      syncKey: syncKey ?? this.syncKey,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'syncKey': syncKey,
      'connectedDevices': connectedDevices.map((d) => d.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'isEnabled': isEnabled,
    };
  }

  factory SyncChain.fromMap(Map<String, dynamic> map) {
    return SyncChain(
      id: map['id'] ?? '',
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      syncKey: map['syncKey'] ?? '',
      connectedDevices: map['connectedDevices'] != null
          ? List<SyncDevice>.from(
              map['connectedDevices'].map((x) => SyncDevice.fromMap(x)))
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'])
          : null,
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncChain.fromJson(String source) =>
      SyncChain.fromMap(json.decode(source));

  /// Generate a new sync chain with a unique key
  factory SyncChain.create({
    required String deviceName,
  }) {
    const uuid = Uuid();
    return SyncChain(
      id: uuid.v4(),
      deviceId: uuid.v4(),
      deviceName: deviceName,
      syncKey: _generateSyncKey(),
      createdAt: DateTime.now(),
    );
  }

  /// Word list for sync key generation (256 words for ~192 bits of entropy with 24 words)
  /// This is a simplified version inspired by BIP39 word lists
  static const List<String> _wordList = [
    // A words
    'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract',
    'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid',
    'across', 'action', 'actor', 'actual', 'adapt', 'address', 'adjust', 'admit',
    'adult', 'advance', 'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again',
    // B words
    'balance', 'ball', 'bamboo', 'banana', 'banner', 'bar', 'barely', 'bargain',
    'barrel', 'base', 'basic', 'basket', 'battle', 'beach', 'bean', 'beauty',
    'because', 'become', 'beef', 'before', 'begin', 'behind', 'believe', 'below',
    'belt', 'bench', 'benefit', 'best', 'betray', 'better', 'between', 'beyond',
    // C words
    'cabin', 'cable', 'cactus', 'cage', 'cake', 'call', 'calm', 'camera',
    'camp', 'canal', 'cancel', 'candy', 'cannon', 'canoe', 'canvas', 'canyon',
    'capable', 'capital', 'captain', 'carbon', 'card', 'cargo', 'carpet', 'carry',
    'cart', 'case', 'cash', 'castle', 'catalog', 'catch', 'category', 'cattle',
    // D words
    'damage', 'damp', 'dance', 'danger', 'daring', 'dash', 'daughter', 'dawn',
    'debate', 'debris', 'decade', 'december', 'decide', 'decline', 'decorate', 'decrease',
    'deer', 'defense', 'define', 'defy', 'degree', 'delay', 'deliver', 'demand',
    'denial', 'dentist', 'deny', 'depart', 'depend', 'deposit', 'depth', 'deputy',
    // E words
    'eagle', 'early', 'earn', 'earth', 'easily', 'east', 'easy', 'echo',
    'ecology', 'economy', 'edge', 'edit', 'educate', 'effort', 'eight', 'either',
    'elbow', 'elder', 'electric', 'elegant', 'element', 'elephant', 'elevator', 'elite',
    'else', 'embark', 'embody', 'embrace', 'emerge', 'emotion', 'employ', 'empower',
    // F words
    'fabric', 'face', 'faculty', 'fade', 'faint', 'faith', 'fall', 'false',
    'fame', 'family', 'famous', 'fan', 'fancy', 'fantasy', 'farm', 'fashion',
    'fatal', 'father', 'fatigue', 'fault', 'favorite', 'feature', 'february', 'federal',
    'fee', 'feed', 'feel', 'female', 'fence', 'festival', 'fetch', 'fever',
    // G words
    'gadget', 'gain', 'galaxy', 'gallery', 'game', 'gap', 'garage', 'garbage',
    'garden', 'garlic', 'garment', 'gas', 'gasp', 'gate', 'gather', 'gauge',
    'gaze', 'general', 'genius', 'genre', 'gentle', 'genuine', 'gesture', 'ghost',
    'giant', 'gift', 'giggle', 'ginger', 'giraffe', 'girl', 'give', 'glad',
    // H words
    'habit', 'hair', 'half', 'hammer', 'hamster', 'hand', 'happy', 'harbor',
    'hard', 'harsh', 'harvest', 'hat', 'have', 'hawk', 'hazard', 'head',
    'health', 'heart', 'heavy', 'hedgehog', 'height', 'hello', 'helmet', 'help',
    'hen', 'hero', 'hidden', 'high', 'hill', 'hint', 'hip', 'hire',
  ];

  /// Generate a 24-word sync key (similar to Brave) using secure random
  static String _generateSyncKey() {
    final random = Random.secure();
    final List<String> selectedWords = [];
    
    for (int i = 0; i < 24; i++) {
      final index = random.nextInt(_wordList.length);
      selectedWords.add(_wordList[index]);
    }
    
    return selectedWords.join(' ');
  }

  /// Validate a sync key format
  static bool isValidSyncKey(String syncKey) {
    final words = syncKey.trim().split(' ');
    if (words.length != 24) return false;
    
    // Verify all words are from the word list
    for (final word in words) {
      if (!_wordList.contains(word.toLowerCase())) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncChain && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a device connected to the sync chain
class SyncDevice {
  final String id;
  final String name;
  final String platform; // windows, linux, android, ios, web, macos
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final bool isCurrentDevice;

  const SyncDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.joinedAt,
    this.lastSeenAt,
    this.isCurrentDevice = false,
  });

  SyncDevice copyWith({
    String? id,
    String? name,
    String? platform,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    bool? isCurrentDevice,
  }) {
    return SyncDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'joinedAt': joinedAt.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'isCurrentDevice': isCurrentDevice,
    };
  }

  factory SyncDevice.fromMap(Map<String, dynamic> map) {
    return SyncDevice(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      platform: map['platform'] ?? '',
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'])
          : DateTime.now(),
      lastSeenAt:
          map['lastSeenAt'] != null ? DateTime.parse(map['lastSeenAt']) : null,
      isCurrentDevice: map['isCurrentDevice'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncDevice.fromJson(String source) =>
      SyncDevice.fromMap(json.decode(source));

  /// Get platform icon name
  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'windows':
        return 'desktop_windows';
      case 'linux':
        return 'computer';
      case 'macos':
        return 'laptop_mac';
      case 'android':
        return 'phone_android';
      case 'ios':
        return 'phone_iphone';
      case 'web':
        return 'language';
      default:
        return 'devices';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents data that can be synced between devices
class SyncData {
  final String type; // 'liked_songs', 'playlists', 'settings', etc.
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String sourceDeviceId;

  const SyncData({
    required this.type,
    required this.data,
    required this.timestamp,
    required this.sourceDeviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'sourceDeviceId': sourceDeviceId,
    };
  }

  factory SyncData.fromMap(Map<String, dynamic> map) {
    return SyncData(
      type: map['type'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      sourceDeviceId: map['sourceDeviceId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncData.fromJson(String source) =>
      SyncData.fromMap(json.decode(source));
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  disabled,
}

/// Extension for SyncStatus
extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Ready to sync';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync failed';
      case SyncStatus.disabled:
        return 'Sync disabled';
    }
  }
}
