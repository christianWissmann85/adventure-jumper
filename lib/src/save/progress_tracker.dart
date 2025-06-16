import 'dart:math' as math;

/// Tracks game progress, achievements, and statistics across all save files
/// Maintains global progress data that persists across different save files
class ProgressTracker {
  ProgressTracker({
    Map<String, bool>? globalAchievements,
    Map<String, int>? globalStatistics,
    Map<String, DateTime>? firstCompletions,
    Map<String, dynamic>? unlockableContent,
    Map<String, List<String>>? achievementCategories,
    Map<String, AchievementProgress>? achievementProgress,
    this.totalPlaytime = 0,
    this.totalJumps = 0,
    this.totalDeaths = 0,
    this.totalEnemiesDefeated = 0,
    this.totalCoinsCollected = 0,
    this.totalSecretsFound = 0,
    this.totalLevelsCompleted = 0,
    Map<String, BiomeProgress>? biomeProgress,
    Map<String, bool>? allLevelsInBiome,
    Map<String, bool>? allSecretsInBiome,
    Map<String, bool>? allAchievementsInCategory,
    Map<String, bool>? unlockedFeatures,
    Map<String, bool>? unlockedBiomes,
    Map<String, bool>? unlockedCharacters,
    Map<String, bool>? unlockedAbilities,
    Map<String, PlayerRecord>? personalBests,
    Map<String, int>? speedrunRecords,
    Map<String, int>? challengeRecords,
  })  : globalAchievements = globalAchievements ?? <String, bool>{},
        globalStatistics = globalStatistics ?? _defaultGlobalStatistics(),
        firstCompletions = firstCompletions ?? <String, DateTime>{},
        unlockableContent = unlockableContent ?? <String, dynamic>{},
        achievementCategories =
            achievementCategories ?? _defaultAchievementCategories(),
        achievementProgress =
            achievementProgress ?? <String, AchievementProgress>{},
        biomeProgress = biomeProgress ?? <String, BiomeProgress>{},
        allLevelsInBiome = allLevelsInBiome ?? <String, bool>{},
        allSecretsInBiome = allSecretsInBiome ?? <String, bool>{},
        allAchievementsInCategory =
            allAchievementsInCategory ?? <String, bool>{},
        unlockedFeatures = unlockedFeatures ?? _defaultUnlockedFeatures(),
        unlockedBiomes = unlockedBiomes ?? <String, bool>{'grasslands': true},
        unlockedCharacters =
            unlockedCharacters ?? <String, bool>{'default_hero': true},
        unlockedAbilities = unlockedAbilities ?? <String, bool>{},
        personalBests = personalBests ?? <String, PlayerRecord>{},
        speedrunRecords = speedrunRecords ?? <String, int>{},
        challengeRecords = challengeRecords ?? <String, int>{};

  /// Create from JSON
  factory ProgressTracker.fromJson(Map<String, dynamic> json) {
    return ProgressTracker(
      globalAchievements: json['globalAchievements'] != null
          ? Map<String, bool>.from(
              json['globalAchievements'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      globalStatistics: json['globalStatistics'] != null
          ? Map<String, int>.from(
              json['globalStatistics'] as Map<String, dynamic>,
            )
          : _defaultGlobalStatistics(),
      firstCompletions: json['firstCompletions'] != null
          ? (json['firstCompletions'] as Map<String, dynamic>)
              .map<String, DateTime>(
              (String key, value) => MapEntry<String, DateTime>(
                key,
                DateTime.parse(value as String),
              ),
            )
          : <String, DateTime>{},
      unlockableContent: json['unlockableContent'] != null
          ? Map<String, dynamic>.from(
              json['unlockableContent'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      achievementCategories: json['achievementCategories'] != null
          ? (json['achievementCategories'] as Map<String, dynamic>)
              .map<String, List<String>>(
              (String key, value) => MapEntry<String, List<String>>(
                key,
                (value as List<dynamic>)
                    .map<String>((item) => item as String)
                    .toList(),
              ),
            )
          : _defaultAchievementCategories(),
      achievementProgress: json['achievementProgress'] != null
          ? (json['achievementProgress'] as Map<String, dynamic>)
              .map<String, AchievementProgress>(
              (String key, value) => MapEntry<String, AchievementProgress>(
                key,
                AchievementProgress.fromJson(value as Map<String, dynamic>),
              ),
            )
          : <String, AchievementProgress>{},
      totalPlaytime: json['totalPlaytime'] as int? ?? 0,
      totalJumps: json['totalJumps'] as int? ?? 0,
      totalDeaths: json['totalDeaths'] as int? ?? 0,
      totalEnemiesDefeated: json['totalEnemiesDefeated'] as int? ?? 0,
      totalCoinsCollected: json['totalCoinsCollected'] as int? ?? 0,
      totalSecretsFound: json['totalSecretsFound'] as int? ?? 0,
      totalLevelsCompleted: json['totalLevelsCompleted'] as int? ?? 0,
      biomeProgress: json['biomeProgress'] != null
          ? (json['biomeProgress'] as Map<String, dynamic>)
              .map<String, BiomeProgress>(
              (String key, value) => MapEntry<String, BiomeProgress>(
                key,
                BiomeProgress.fromJson(value as Map<String, dynamic>),
              ),
            )
          : <String, BiomeProgress>{},
      allLevelsInBiome: json['allLevelsInBiome'] != null
          ? Map<String, bool>.from(
              json['allLevelsInBiome'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      allSecretsInBiome: json['allSecretsInBiome'] != null
          ? Map<String, bool>.from(
              json['allSecretsInBiome'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      allAchievementsInCategory: json['allAchievementsInCategory'] != null
          ? Map<String, bool>.from(
              json['allAchievementsInCategory'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      unlockedFeatures: json['unlockedFeatures'] != null
          ? Map<String, bool>.from(
              json['unlockedFeatures'] as Map<String, dynamic>,
            )
          : _defaultUnlockedFeatures(),
      unlockedBiomes: json['unlockedBiomes'] != null
          ? Map<String, bool>.from(
              json['unlockedBiomes'] as Map<String, dynamic>,
            )
          : <String, bool>{'grasslands': true},
      unlockedCharacters: json['unlockedCharacters'] != null
          ? Map<String, bool>.from(
              json['unlockedCharacters'] as Map<String, dynamic>,
            )
          : <String, bool>{'default_hero': true},
      unlockedAbilities: json['unlockedAbilities'] != null
          ? Map<String, bool>.from(
              json['unlockedAbilities'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      personalBests: json['personalBests'] != null
          ? (json['personalBests'] as Map<String, dynamic>)
              .map<String, PlayerRecord>(
              (String key, value) => MapEntry<String, PlayerRecord>(
                key,
                PlayerRecord.fromJson(value as Map<String, dynamic>),
              ),
            )
          : <String, PlayerRecord>{},
      speedrunRecords: json['speedrunRecords'] != null
          ? Map<String, int>.from(
              json['speedrunRecords'] as Map<String, dynamic>,
            )
          : <String, int>{},
      challengeRecords: json['challengeRecords'] != null
          ? Map<String, int>.from(
              json['challengeRecords'] as Map<String, dynamic>,
            )
          : <String, int>{},
    );
  }
  // Global progress tracking
  Map<String, bool> globalAchievements;
  Map<String, int> globalStatistics;
  Map<String, DateTime> firstCompletions;
  Map<String, dynamic> unlockableContent;

  // Achievement categories
  Map<String, List<String>> achievementCategories;
  Map<String, AchievementProgress> achievementProgress;

  // Statistics tracking
  int totalPlaytime; // in milliseconds
  int totalJumps;
  int totalDeaths;
  int totalEnemiesDefeated;
  int totalCoinsCollected;
  int totalSecretsFound;
  int totalLevelsCompleted;

  // Completion tracking
  Map<String, BiomeProgress> biomeProgress;
  Map<String, bool> allLevelsInBiome;
  Map<String, bool> allSecretsInBiome;
  Map<String, bool> allAchievementsInCategory;

  // Unlock system
  Map<String, bool> unlockedFeatures;
  Map<String, bool> unlockedBiomes;
  Map<String, bool> unlockedCharacters;
  Map<String, bool> unlockedAbilities;

  // Leaderboards and records
  Map<String, PlayerRecord> personalBests;
  Map<String, int> speedrunRecords;
  Map<String, int> challengeRecords;

  /// Default global statistics
  static Map<String, int> _defaultGlobalStatistics() {
    return <String, int>{
      'games_played': 0,
      'total_sessions': 0,
      'highest_level_reached': 1,
      'longest_session': 0, // in milliseconds
      'perfect_levels': 0,
      'no_death_runs': 0,
    };
  }

  /// Default achievement categories
  static Map<String, List<String>> _defaultAchievementCategories() {
    return <String, List<String>>{
      'progression': <String>[
        'first_jump',
        'level_1_complete',
        'first_biome_complete',
      ],
      'combat': <String>[
        'first_enemy_defeated',
        '100_enemies_defeated',
        'boss_defeated',
      ],
      'exploration': <String>[
        'first_secret_found',
        '50_secrets_found',
        'all_secrets_found',
      ],
      'collection': <String>[
        '100_coins_collected',
        '1000_coins_collected',
        'all_items_collected',
      ],
      'mastery': <String>[
        'no_death_level',
        'speedrun_complete',
        'perfect_game',
      ],
      'special': <String>[
        'easter_egg_found',
        'developer_room',
        'hidden_character',
      ],
    };
  }

  /// Default unlocked features
  static Map<String, bool> _defaultUnlockedFeatures() {
    return <String, bool>{
      'basic_movement': true,
      'basic_jump': true,
      'inventory_system': true,
      'save_system': true,
    };
  }

  /// Update global statistics from save data
  void updateFromSaveData(Map<String, dynamic> saveData) {
    // Update playtime
    final int savePlaytime = saveData['playtime'] as int? ?? 0;
    totalPlaytime = math.max(totalPlaytime, savePlaytime);

    // Update cumulative statistics
    totalJumps = math.max(totalJumps, saveData['jumpCount'] as int? ?? 0);
    totalDeaths = math.max(totalDeaths, saveData['deathCount'] as int? ?? 0);
    totalEnemiesDefeated = math.max(
      totalEnemiesDefeated,
      saveData['enemiesDefeated'] as int? ?? 0,
    );

    // Update level completion count
    final Map<String, bool> levelsCompleted =
        saveData['levelsCompleted'] != null
            ? Map<String, bool>.from(
                saveData['levelsCompleted'] as Map<String, dynamic>,
              )
            : <String, bool>{};
    totalLevelsCompleted =
        math.max(totalLevelsCompleted, levelsCompleted.length);

    // Update secrets found count
    final Map<String, bool> secretsFound = saveData['secretsFound'] != null
        ? Map<String, bool>.from(
            saveData['secretsFound'] as Map<String, dynamic>,
          )
        : <String, bool>{};
    totalSecretsFound = math.max(totalSecretsFound, secretsFound.length);

    // Update coins collected
    final Map<String, int> inventory = saveData['inventory'] != null
        ? Map<String, int>.from(saveData['inventory'] as Map<String, dynamic>)
        : <String, int>{};
    final int coins = inventory['coins'] ?? 0;
    totalCoinsCollected = math.max(totalCoinsCollected, coins);

    // Update highest level reached
    final int playerLevel = saveData['playerLevel'] as int? ?? 1;
    globalStatistics['highest_level_reached'] = math.max(
      globalStatistics['highest_level_reached'] ?? 1,
      playerLevel,
    );
  }

  /// Unlock achievement
  void unlockAchievement(String achievementId) {
    if (!globalAchievements.containsKey(achievementId)) {
      globalAchievements[achievementId] = true;
      firstCompletions[achievementId] = DateTime.now();

      // Check for category completion
      _checkCategoryCompletion(achievementId);

      // Check for unlock triggers
      _checkUnlockTriggers(achievementId);
    }
  }

  /// Check if category is complete
  void _checkCategoryCompletion(String achievementId) {
    for (final String category in achievementCategories.keys) {
      final List<String> categoryAchievements =
          achievementCategories[category]!;
      if (categoryAchievements.contains(achievementId)) {
        final bool allComplete = categoryAchievements.every(
          (String achievement) => globalAchievements[achievement] == true,
        );
        if (allComplete) {
          allAchievementsInCategory[category] = true;
        }
      }
    }
  }

  /// Check for content unlocks based on achievements
  void _checkUnlockTriggers(String achievementId) {
    switch (achievementId) {
      case 'first_biome_complete':
        unlockedBiomes['desert'] = true;
        break;
      case 'boss_defeated':
        unlockedAbilities['double_jump'] = true;
        break;
      case 'all_secrets_found':
        unlockedCharacters['secret_hero'] = true;
        break;
      case 'perfect_game':
        unlockedFeatures['developer_mode'] = true;
        break;
    }
  }

  /// Update biome progress
  void updateBiomeProgress(
    String biomeId,
    String levelId,
    bool completed,
    bool secretFound,
  ) {
    if (!biomeProgress.containsKey(biomeId)) {
      biomeProgress[biomeId] = BiomeProgress(biomeId: biomeId);
    }

    final BiomeProgress progress = biomeProgress[biomeId]!;
    if (completed) {
      progress.levelsCompleted.add(levelId);
    }
    if (secretFound) {
      progress.secretsFound.add(levelId);
    }

    // Check for biome completion
    _checkBiomeCompletion(biomeId);
  }

  /// Check if biome is fully completed
  void _checkBiomeCompletion(String biomeId) {
    final BiomeProgress? progress = biomeProgress[biomeId];
    if (progress != null) {
      // This would need to be configured based on actual level counts
      final Map<String, int> biomeLevelCounts = <String, int>{
        'grasslands': 10,
        'desert': 12,
        'forest': 15,
        'mountains': 18,
        'caves': 20,
      };

      final int totalLevels = biomeLevelCounts[biomeId] ?? 10;

      if (progress.levelsCompleted.length >= totalLevels) {
        allLevelsInBiome[biomeId] = true;
      }

      if (progress.secretsFound.length >= totalLevels) {
        allSecretsInBiome[biomeId] = true;
      }
    }
  }

  /// Record personal best
  void recordPersonalBest(String category, PlayerRecord record) {
    final PlayerRecord? currentBest = personalBests[category];
    if (currentBest == null || record.isBetterThan(currentBest)) {
      personalBests[category] = record;
    }
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    final int totalAchievements = achievementCategories.values
        .expand((List<String> achievements) => achievements)
        .length;
    final int unlockedAchievements =
        globalAchievements.values.where((bool unlocked) => unlocked).length;

    return totalAchievements > 0
        ? unlockedAchievements / totalAchievements
        : 0.0;
  }

  /// Get achievements by category
  Map<String, bool> getAchievementsByCategory(String category) {
    final List<String> categoryAchievements =
        achievementCategories[category] ?? <String>[];
    final Map<String, bool> result = <String, bool>{};

    for (final String achievement in categoryAchievements) {
      result[achievement] = globalAchievements[achievement] ?? false;
    }

    return result;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'globalAchievements': globalAchievements,
      'globalStatistics': globalStatistics,
      'firstCompletions': firstCompletions.map<String, String>(
        (String key, DateTime value) =>
            MapEntry<String, String>(key, value.toIso8601String()),
      ),
      'unlockableContent': unlockableContent,
      'achievementCategories': achievementCategories,
      'achievementProgress':
          achievementProgress.map<String, Map<String, dynamic>>(
        (String key, AchievementProgress value) =>
            MapEntry<String, Map<String, dynamic>>(key, value.toJson()),
      ),
      'totalPlaytime': totalPlaytime,
      'totalJumps': totalJumps,
      'totalDeaths': totalDeaths,
      'totalEnemiesDefeated': totalEnemiesDefeated,
      'totalCoinsCollected': totalCoinsCollected,
      'totalSecretsFound': totalSecretsFound,
      'totalLevelsCompleted': totalLevelsCompleted,
      'biomeProgress': biomeProgress.map<String, Map<String, dynamic>>(
        (String key, BiomeProgress value) =>
            MapEntry<String, Map<String, dynamic>>(key, value.toJson()),
      ),
      'allLevelsInBiome': allLevelsInBiome,
      'allSecretsInBiome': allSecretsInBiome,
      'allAchievementsInCategory': allAchievementsInCategory,
      'unlockedFeatures': unlockedFeatures,
      'unlockedBiomes': unlockedBiomes,
      'unlockedCharacters': unlockedCharacters,
      'unlockedAbilities': unlockedAbilities,
      'personalBests': personalBests.map<String, Map<String, dynamic>>(
        (String key, PlayerRecord value) =>
            MapEntry<String, Map<String, dynamic>>(key, value.toJson()),
      ),
      'speedrunRecords': speedrunRecords,
      'challengeRecords': challengeRecords,
    };
  }
}

/// Tracks progress within a specific biome
class BiomeProgress {
  BiomeProgress({
    required this.biomeId,
    Set<String>? levelsCompleted,
    Set<String>? secretsFound,
    Set<String>? achievementsUnlocked,
    DateTime? firstVisit,
    this.lastVisit,
  })  : levelsCompleted = levelsCompleted ?? <String>{},
        secretsFound = secretsFound ?? <String>{},
        achievementsUnlocked = achievementsUnlocked ?? <String>{},
        firstVisit = firstVisit ?? DateTime.now();
  factory BiomeProgress.fromJson(Map<String, dynamic> json) {
    return BiomeProgress(
      biomeId: json['biomeId'] as String,
      levelsCompleted: json['levelsCompleted'] != null
          ? (json['levelsCompleted'] as List<dynamic>)
              .map<String>((e) => e as String)
              .toSet()
          : null,
      secretsFound: json['secretsFound'] != null
          ? (json['secretsFound'] as List<dynamic>)
              .map<String>((e) => e as String)
              .toSet()
          : null,
      achievementsUnlocked: json['achievementsUnlocked'] != null
          ? (json['achievementsUnlocked'] as List<dynamic>)
              .map<String>((e) => e as String)
              .toSet()
          : null,
      firstVisit: json['firstVisit'] != null
          ? DateTime.parse(json['firstVisit'] as String)
          : null,
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'] as String)
          : null,
    );
  }
  final String biomeId;
  Set<String> levelsCompleted;
  Set<String> secretsFound;
  Set<String> achievementsUnlocked;
  DateTime firstVisit;
  DateTime? lastVisit;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'biomeId': biomeId,
      'levelsCompleted': levelsCompleted.toList(),
      'secretsFound': secretsFound.toList(),
      'achievementsUnlocked': achievementsUnlocked.toList(),
      'firstVisit': firstVisit.toIso8601String(),
      'lastVisit': lastVisit?.toIso8601String(),
    };
  }
}

/// Tracks progress towards a specific achievement
class AchievementProgress {
  AchievementProgress({
    required this.achievementId,
    required this.targetProgress,
    this.currentProgress = 0,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? <String, dynamic>{};
  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentProgress: json['currentProgress'] as int? ?? 0,
      targetProgress: json['targetProgress'] as int? ?? 1,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }
  final String achievementId;
  int currentProgress;
  int targetProgress;
  Map<String, dynamic> metadata;

  double get progressPercentage =>
      targetProgress > 0 ? currentProgress / targetProgress : 0.0;
  bool get isComplete => currentProgress >= targetProgress;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'metadata': metadata,
    };
  }
}

/// Represents a player record/personal best
class PlayerRecord {
  PlayerRecord({
    required this.category,
    required this.value,
    DateTime? achieved,
    Map<String, dynamic>? context,
  })  : achieved = achieved ?? DateTime.now(),
        context = context ?? <String, dynamic>{};
  factory PlayerRecord.fromJson(Map<String, dynamic> json) {
    return PlayerRecord(
      category: json['category'] as String,
      value: json['value'],
      achieved: json['achieved'] != null
          ? DateTime.parse(json['achieved'] as String)
          : null,
      context: json['context'] != null
          ? Map<String, dynamic>.from(json['context'] as Map<String, dynamic>)
          : null,
    );
  }
  final String category;
  final dynamic value;
  final DateTime achieved;
  final Map<String, dynamic> context;

  bool isBetterThan(PlayerRecord other) {
    // This would need category-specific logic
    // For now, assume higher values are better for most categories
    switch (category) {
      case 'fastest_completion':
      case 'speedrun':
        return (value as num) <
            (other.value as num); // Lower is better for time
      default:
        return (value as num) >
            (other.value as num); // Higher is better for scores
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category,
      'value': value,
      'achieved': achieved.toIso8601String(),
      'context': context,
    };
  }
}

// Add missing import for math
