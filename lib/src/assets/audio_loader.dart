import 'package:audioplayers/audioplayers.dart';

import '../utils/logger.dart';

/// Handles loading and management of audio assets for the game
class AudioLoader {
  factory AudioLoader() => _instance;
  AudioLoader._internal();
  static final AudioLoader _instance = AudioLoader._internal();

  final Map<String, Source> _audioCache = <String, Source>{};
  final Map<String, AudioGroup> _audioGroups = <String, AudioGroup>{};
  final AudioPlayer _preloadPlayer = AudioPlayer();

  bool _isInitialized = false;

  /// Initialize the audio loader
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _setupAudioGroups();
    await _preloadCriticalAudio();
    _isInitialized = true;
  }

  /// Load audio file and return Source
  Future<Source> loadAudio(String audioPath) async {
    if (_audioCache.containsKey(audioPath)) {
      return _audioCache[audioPath]!;
    }

    try {
      Source audioSource;

      if (audioPath.startsWith('assets/')) {
        audioSource =
            AssetSource(audioPath.substring(7)); // Remove 'assets/' prefix
      } else {
        audioSource = AssetSource(audioPath);
      }

      // Validate the audio file exists by attempting to load it
      await _preloadPlayer.setSource(audioSource);

      _audioCache[audioPath] = audioSource;
      return audioSource;
    } catch (e) {
      throw Exception('Failed to load audio: $audioPath. Error: $e');
    }
  }

  /// Load multiple audio files for a specific category
  Future<Map<String, Source>> loadAudioGroup(
    String groupName,
    List<String> audioPaths,
  ) async {
    final Map<String, Source> audioSources = <String, Source>{};

    for (final String audioPath in audioPaths) {
      try {
        final Source audioSource = await loadAudio(audioPath);
        final String filename = audioPath.split('/').last.split('.').first;
        audioSources[filename] = audioSource;
      } catch (e) {
        logger.warning(
          'Failed to load audio in group $groupName: $audioPath',
          e,
        );
      }
    }

    _audioGroups[groupName] = AudioGroup(
      name: groupName,
      audioSources: audioSources,
    );

    return audioSources;
  }

  /// Load sound effects
  Future<Map<String, Source>> loadSoundEffects() async {
    final List<String> soundEffectPaths = <String>[
      'audio/sfx/jump.wav',
      'audio/sfx/land.wav',
      'audio/sfx/attack.wav',
      'audio/sfx/hit.wav',
      'audio/sfx/collect_coin.wav',
      'audio/sfx/collect_powerup.wav',
      'audio/sfx/enemy_death.wav',
      'audio/sfx/button_click.wav',
      'audio/sfx/button_hover.wav',
      'audio/sfx/menu_open.wav',
      'audio/sfx/menu_close.wav',
      'audio/sfx/checkpoint.wav',
      'audio/sfx/level_complete.wav',
      'audio/sfx/game_over.wav',
    ];

    return loadAudioGroup('sound_effects', soundEffectPaths);
  }

  /// Load music tracks
  Future<Map<String, Source>> loadMusicTracks() async {
    final List<String> musicPaths = <String>[
      'audio/music/main_theme.mp3',
      'audio/music/level_1.mp3',
      'audio/music/level_2.mp3',
      'audio/music/boss_fight.mp3',
      'audio/music/peaceful_area.mp3',
      'audio/music/tension.mp3',
      'audio/music/victory.mp3',
      'audio/music/game_over.mp3',
    ];

    return loadAudioGroup('music', musicPaths);
  }

  /// Load ambient sounds
  Future<Map<String, Source>> loadAmbientSounds() async {
    final List<String> ambientPaths = <String>[
      'audio/ambient/forest.mp3',
      'audio/ambient/cave.mp3',
      'audio/ambient/water.mp3',
      'audio/ambient/wind.mp3',
      'audio/ambient/fire.mp3',
      'audio/ambient/rain.mp3',
      'audio/ambient/thunder.mp3',
    ];

    return loadAudioGroup('ambient', ambientPaths);
  }

  /// Load voice clips
  Future<Map<String, Source>> loadVoiceClips() async {
    final List<String> voicePaths = <String>[
      'audio/voice/player_hurt.wav',
      'audio/voice/player_attack.wav',
      'audio/voice/npc_greeting.wav',
      'audio/voice/npc_goodbye.wav',
      'audio/voice/narrator_intro.wav',
    ];

    return loadAudioGroup('voice', voicePaths);
  }

  /// Load UI sounds
  Future<Map<String, Source>> loadUISounds() async {
    final List<String> uiPaths = <String>[
      'audio/ui/button_click.wav',
      'audio/ui/button_hover.wav',
      'audio/ui/tab_switch.wav',
      'audio/ui/popup_open.wav',
      'audio/ui/popup_close.wav',
      'audio/ui/error.wav',
      'audio/ui/success.wav',
      'audio/ui/typing.wav',
    ];

    return loadAudioGroup('ui', uiPaths);
  }

  /// Load all audio assets
  Future<void> loadAllAudio() async {
    await Future.wait(<Future<Map<String, dynamic>>>[
      loadSoundEffects(),
      loadMusicTracks(),
      loadAmbientSounds(),
      loadVoiceClips(),
      loadUISounds(),
    ]);
  }

  /// Get audio source from cache
  Source? getAudioSource(String audioPath) {
    return _audioCache[audioPath];
  }

  /// Get audio source by group and name
  Source? getAudioFromGroup(String groupName, String audioName) {
    final AudioGroup? group = _audioGroups[groupName];
    return group?.audioSources[audioName];
  }

  /// Get all audio sources in a group
  Map<String, Source>? getAudioGroup(String groupName) {
    return _audioGroups[groupName]?.audioSources;
  }

  /// Preload audio by creating AudioPlayer instances without playing
  Future<void> preloadAudio(String audioPath) async {
    try {
      final Source audioSource = await loadAudio(audioPath);
      final AudioPlayer tempPlayer = AudioPlayer();
      await tempPlayer.setSource(audioSource);
      await tempPlayer.dispose();
    } catch (e) {
      logger.warning('Failed to preload audio: $audioPath', e);
    }
  }

  /// Validate audio file exists and is playable
  Future<bool> validateAudio(String audioPath) async {
    try {
      final Source audioSource = await loadAudio(audioPath);
      final AudioPlayer tempPlayer = AudioPlayer();
      await tempPlayer.setSource(audioSource);
      await tempPlayer.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get audio duration without playing
  Future<Duration?> getAudioDuration(String audioPath) async {
    try {
      final Source audioSource = await loadAudio(audioPath);
      final AudioPlayer tempPlayer = AudioPlayer();
      await tempPlayer.setSource(audioSource);
      final Duration? duration = await tempPlayer.getDuration();
      await tempPlayer.dispose();
      return duration;
    } catch (e) {
      return null;
    }
  }

  /// Setup predefined audio groups
  Future<void> _setupAudioGroups() async {
    // Initialize empty groups that will be populated when loaded
    _audioGroups['sound_effects'] =
        AudioGroup(name: 'sound_effects', audioSources: <String, Source>{});
    _audioGroups['music'] =
        AudioGroup(name: 'music', audioSources: <String, Source>{});
    _audioGroups['ambient'] =
        AudioGroup(name: 'ambient', audioSources: <String, Source>{});
    _audioGroups['voice'] =
        AudioGroup(name: 'voice', audioSources: <String, Source>{});
    _audioGroups['ui'] =
        AudioGroup(name: 'ui', audioSources: <String, Source>{});
  }

  /// Preload critical audio files
  Future<void> _preloadCriticalAudio() async {
    final List<String> criticalAudio = <String>[
      'audio/sfx/jump.wav',
      'audio/sfx/button_click.wav',
      'audio/music/main_theme.mp3',
    ];
    for (final String audioPath in criticalAudio) {
      try {
        await loadAudio(audioPath);
      } catch (e) {
        logger.warning('Failed to preload critical audio: $audioPath', e);
      }
    }
  }

  /// Check if audio is loaded in cache
  bool isLoaded(String audioPath) {
    return _audioCache.containsKey(audioPath);
  }

  /// Unload specific audio from cache
  void unload(String audioPath) {
    _audioCache.remove(audioPath);

    // Also remove from audio groups
    for (final AudioGroup group in _audioGroups.values) {
      group.audioSources.remove(audioPath.split('/').last.split('.').first);
    }
  }

  /// Clear specific audio from cache
  void clearAudio(String audioPath) {
    _audioCache.remove(audioPath);
  }

  /// Clear entire audio group
  void clearAudioGroup(String groupName) {
    final AudioGroup? group = _audioGroups[groupName];
    if (group != null) {
      group.audioSources.clear();
    }
  }

  /// Clear all cached audio
  void clearCache() {
    _audioCache.clear();
    for (final AudioGroup group in _audioGroups.values) {
      group.audioSources.clear();
    }
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    final Map<String, int> groupStats = <String, int>{};
    for (final MapEntry<String, AudioGroup> entry in _audioGroups.entries) {
      groupStats[entry.key] = entry.value.audioSources.length;
    }

    return <String, dynamic>{
      'total_cached_audio': _audioCache.length,
      'audio_groups': groupStats,
    };
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _preloadPlayer.dispose();
    clearCache();
    _isInitialized = false;
  }
}

/// Audio group containing related audio sources
class AudioGroup {
  AudioGroup({
    required this.name,
    required this.audioSources,
    this.metadata = const <String, dynamic>{},
  });
  final String name;
  final Map<String, Source> audioSources;
  final Map<String, dynamic> metadata;

  /// Add audio source to group
  void addAudio(String name, Source audioSource) {
    audioSources[name] = audioSource;
  }

  /// Remove audio source from group
  void removeAudio(String name) {
    audioSources.remove(name);
  }

  /// Get random audio source from group
  Source? getRandomAudio() {
    if (audioSources.isEmpty) return null;
    final List<String> keys = audioSources.keys.toList();
    final String randomKey =
        keys[DateTime.now().millisecondsSinceEpoch % keys.length];
    return audioSources[randomKey];
  }

  /// Check if group contains audio
  bool containsAudio(String name) {
    return audioSources.containsKey(name);
  }

  /// Get all audio names in group
  List<String> getAudioNames() {
    return audioSources.keys.toList();
  }
}

/// Audio configuration for different game contexts
class AudioConfig {
  static const double soundEffectVolume = 0.8;
  static const double musicVolume = 0.6;
  static const double ambientVolume = 0.4;
  static const double voiceVolume = 0.9;
  static const double uiVolume = 0.7;

  static const Map<String, double> groupVolumes = <String, double>{
    'sound_effects': soundEffectVolume,
    'music': musicVolume,
    'ambient': ambientVolume,
    'voice': voiceVolume,
    'ui': uiVolume,
  };

  /// Audio file format preferences
  static const List<String> preferredFormats = <String>['wav', 'mp3', 'ogg'];

  /// Maximum concurrent audio players per group
  static const Map<String, int> maxConcurrentPlayers = <String, int>{
    'sound_effects': 8,
    'music': 2,
    'ambient': 4,
    'voice': 2,
    'ui': 4,
  };
}

/// Audio loading presets for different scenarios
class AudioPresets {
  /// Minimal audio for basic functionality
  static const List<String> minimal = <String>[
    'audio/sfx/jump.wav',
    'audio/sfx/button_click.wav',
    'audio/music/main_theme.mp3',
  ];

  /// Essential gameplay audio
  static const List<String> gameplay = <String>[
    'audio/sfx/jump.wav',
    'audio/sfx/land.wav',
    'audio/sfx/attack.wav',
    'audio/sfx/collect_coin.wav',
    'audio/sfx/enemy_death.wav',
    'audio/music/level_1.mp3',
  ];

  /// Complete audio set
  static const List<String> complete = <String>[
    // Sound effects
    'audio/sfx/jump.wav',
    'audio/sfx/land.wav',
    'audio/sfx/attack.wav',
    'audio/sfx/hit.wav',
    'audio/sfx/collect_coin.wav',
    'audio/sfx/collect_powerup.wav',
    'audio/sfx/enemy_death.wav',
    'audio/sfx/checkpoint.wav',
    'audio/sfx/level_complete.wav',
    'audio/sfx/game_over.wav',

    // Music
    'audio/music/main_theme.mp3',
    'audio/music/level_1.mp3',
    'audio/music/level_2.mp3',
    'audio/music/boss_fight.mp3',
    'audio/music/victory.mp3',
    'audio/music/game_over.mp3',

    // UI
    'audio/ui/button_click.wav',
    'audio/ui/button_hover.wav',
    'audio/ui/menu_open.wav',
    'audio/ui/menu_close.wav',

    // Ambient
    'audio/ambient/forest.mp3',
    'audio/ambient/cave.mp3',
    'audio/ambient/water.mp3',
  ];
}
