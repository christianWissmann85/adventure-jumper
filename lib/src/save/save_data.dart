import 'dart:math' as math;

/// Core save data structure for Adventure Jumper game
/// Contains all persistent game state information including player progress,
/// dialogue states, achievement tracking, and world state
class SaveData {
  SaveData({
    required this.slotId,
    DateTime? created,
    DateTime? lastSaved,
    this.saveVersion = 1,
    this.playerLevel = 1,
    this.experience = 0,
    this.skillPoints = 0,
    Map<String, int>? unlockedSkills,
    Map<String, dynamic>? playerStats,
    this.currentLevel = 'tutorial_1',
    this.currentBiome = 'grasslands',
    Map<String, bool>? levelsCompleted,
    Map<String, bool>? secretsFound,
    Map<String, bool>? achievementsUnlocked,
    Map<String, int>? inventory,
    Map<String, bool>? itemsCollected,
    this.equippedWeapon = 'basic_sword',
    this.equippedArmor = 'cloth_armor',
    List<String>? equippedAccessories,
    Map<String, dynamic>? playerPosition,
    Map<String, dynamic>? checkpointData,
    List<String>? unlockedAreas,
    Map<String, bool>? npcsInteracted,
    Map<String, dynamic>? questStates,
    Duration? playtime,
    this.deathCount = 0,
    this.jumpCount = 0,
    this.enemiesDefeated = 0,
    Map<String, dynamic>? gameplaySettings,
    // Enhanced dialogue and interaction tracking
    Map<String, dynamic>? dialogueStates,
    Map<String, dynamic>? npcInteractionHistory,
    List<String>? conversationHistory,
    Map<String, int>? dialogueNodeVisitCounts,
    Map<String, DateTime>? dialogueNodeLastVisited,
    // Enhanced achievement tracking
    Map<String, DateTime>? achievementUnlockTimes,
    Map<String, dynamic>? achievementProgress,
    // Enhanced player stats tracking (from PlayerStats class)
    Map<String, bool>? unlockedAbilities,
    int? aetherShards,
    // Enhanced level progression tracking
    Map<String, dynamic>? levelCheckpoints,
    Map<String, double>? levelBestTimes,
    Map<String, int>? levelDeathCounts,
    Map<String, List<String>>? levelSecretsFound,
  })  : created = created ?? DateTime.now(),
        lastSaved = lastSaved ?? DateTime.now(),
        unlockedSkills = unlockedSkills ?? <String, int>{},
        playerStats = playerStats ?? _defaultPlayerStats(),
        levelsCompleted = levelsCompleted ?? <String, bool>{},
        secretsFound = secretsFound ?? <String, bool>{},
        achievementsUnlocked = achievementsUnlocked ?? <String, bool>{},
        inventory = inventory ?? _defaultInventory(),
        itemsCollected = itemsCollected ?? <String, bool>{},
        equippedAccessories = equippedAccessories ?? <String>[],
        playerPosition = playerPosition ??
            <String, dynamic>{'x': 0.0, 'y': 0.0, 'facing': 'right'},
        checkpointData = checkpointData ?? <String, dynamic>{},
        unlockedAreas = unlockedAreas ?? <String>['grasslands'],
        npcsInteracted = npcsInteracted ?? <String, bool>{},
        questStates = questStates ?? <String, dynamic>{},
        playtime = playtime ?? Duration.zero,
        gameplaySettings = gameplaySettings ?? <String, dynamic>{},
        // Enhanced dialogue and interaction tracking
        dialogueStates = dialogueStates ?? <String, dynamic>{},
        npcInteractionHistory = npcInteractionHistory ?? <String, dynamic>{},
        conversationHistory = conversationHistory ?? <String>[],
        dialogueNodeVisitCounts = dialogueNodeVisitCounts ?? <String, int>{},
        dialogueNodeLastVisited =
            dialogueNodeLastVisited ?? <String, DateTime>{},
        // Enhanced achievement tracking
        achievementUnlockTimes = achievementUnlockTimes ?? <String, DateTime>{},
        achievementProgress = achievementProgress ?? <String, dynamic>{},
        // Enhanced player stats tracking
        unlockedAbilities = unlockedAbilities ??
            <String, bool>{
              'doubleJump': false,
              'dash': false,
              'wallJump': false,
            },
        aetherShards = aetherShards ?? 0,
        // Enhanced level progression tracking
        levelCheckpoints = levelCheckpoints ?? <String, dynamic>{},
        levelBestTimes = levelBestTimes ?? <String, double>{},
        levelDeathCounts = levelDeathCounts ?? <String, int>{},
        levelSecretsFound = levelSecretsFound ?? <String, List<String>>{};

  /// Create from JSON data
  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      slotId: json['slotId'] as int? ?? 0,
      created: DateTime.parse(
        json['created'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastSaved: DateTime.parse(
        json['lastSaved'] as String? ?? DateTime.now().toIso8601String(),
      ),
      saveVersion: (json['saveVersion'] as int?) ?? 1,
      playerLevel: (json['playerLevel'] as int?) ?? 1,
      experience: (json['experience'] as int?) ?? 0,
      skillPoints: (json['skillPoints'] as int?) ?? 0,
      unlockedSkills: json['unlockedSkills'] != null
          ? Map<String, int>.from(
              json['unlockedSkills'] as Map<String, dynamic>,
            )
          : <String, int>{},
      playerStats: (json['playerStats'] != null)
          ? Map<String, dynamic>.from(
              json['playerStats'] as Map<String, dynamic>,
            )
          : _defaultPlayerStats(),
      currentLevel: json['currentLevel'] as String? ?? 'tutorial_1',
      currentBiome: json['currentBiome'] as String? ?? 'grasslands',
      levelsCompleted: Map<String, bool>.from(
        Map<String, bool>.from(
          json['levelsCompleted'] as Map<dynamic, dynamic>? ?? <String, bool>{},
        ),
      ),
      secretsFound: Map<String, bool>.from(
        json['secretsFound'] as Map<dynamic, dynamic>? ?? <String, bool>{},
      ),
      achievementsUnlocked: Map<String, bool>.from(
        Map<String, bool>.from(
          json['achievementsUnlocked'] as Map<dynamic, dynamic>? ??
              <String, bool>{},
        ),
      ),
      inventory: json['inventory'] != null
          ? Map<String, int>.from(json['inventory'] as Map<String, dynamic>)
          : _defaultInventory(),
      itemsCollected: json['itemsCollected'] != null
          ? Map<String, bool>.from(
              json['itemsCollected'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      equippedWeapon: json['equippedWeapon'] as String? ?? 'basic_sword',
      equippedArmor: json['equippedArmor'] as String? ?? 'cloth_armor',
      equippedAccessories: json['equippedAccessories'] != null
          ? List<String>.from(json['equippedAccessories'] as List<dynamic>)
          : <String>[],
      playerPosition: json['playerPosition'] != null
          ? Map<String, dynamic>.from(
              json['playerPosition'] as Map<String, dynamic>,
            )
          : <String, dynamic>{'x': 0.0, 'y': 0.0, 'facing': 'right'},
      checkpointData: json['checkpointData'] != null
          ? Map<String, dynamic>.from(
              json['checkpointData'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      unlockedAreas: json['unlockedAreas'] != null
          ? List<String>.from(json['unlockedAreas'] as List<dynamic>)
          : <String>['grasslands'],
      npcsInteracted: json['npcsInteracted'] != null
          ? Map<String, bool>.from(
              json['npcsInteracted'] as Map<String, dynamic>,
            )
          : <String, bool>{},
      questStates: json['questStates'] != null
          ? Map<String, dynamic>.from(
              json['questStates'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      playtime: Duration(milliseconds: json['playtime'] as int? ?? 0),
      deathCount: (json['deathCount'] as int?) ?? 0,
      jumpCount: (json['jumpCount'] as int?) ?? 0,
      enemiesDefeated: (json['enemiesDefeated'] as int?) ?? 0,
      gameplaySettings: json['gameplaySettings'] != null
          ? Map<String, dynamic>.from(
              json['gameplaySettings'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      // Enhanced dialogue and interaction tracking
      dialogueStates: json['dialogueStates'] != null
          ? Map<String, dynamic>.from(
              json['dialogueStates'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      npcInteractionHistory: json['npcInteractionHistory'] != null
          ? Map<String, dynamic>.from(
              json['npcInteractionHistory'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      conversationHistory: json['conversationHistory'] != null
          ? List<String>.from(json['conversationHistory'] as List<dynamic>)
          : <String>[],
      dialogueNodeVisitCounts: json['dialogueNodeVisitCounts'] != null
          ? Map<String, int>.from(
              json['dialogueNodeVisitCounts'] as Map<String, dynamic>,
            )
          : <String, int>{},
      dialogueNodeLastVisited: json['dialogueNodeLastVisited'] != null
          ? (json['dialogueNodeLastVisited'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                DateTime.fromMillisecondsSinceEpoch(value as int),
              ),
            )
          : <String, DateTime>{},
      // Enhanced achievement tracking
      achievementUnlockTimes: json['achievementUnlockTimes'] != null
          ? (json['achievementUnlockTimes'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                DateTime.fromMillisecondsSinceEpoch(value as int),
              ),
            )
          : <String, DateTime>{},
      achievementProgress: json['achievementProgress'] != null
          ? Map<String, dynamic>.from(
              json['achievementProgress'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      // Enhanced player stats tracking
      unlockedAbilities: json['unlockedAbilities'] != null
          ? Map<String, bool>.from(
              json['unlockedAbilities'] as Map<String, dynamic>,
            )
          : <String, bool>{
              'doubleJump': false,
              'dash': false,
              'wallJump': false,
            },
      aetherShards: (json['aetherShards'] as int?) ?? 0,
      // Enhanced level progression tracking
      levelCheckpoints: json['levelCheckpoints'] != null
          ? Map<String, dynamic>.from(
              json['levelCheckpoints'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      levelBestTimes: json['levelBestTimes'] != null
          ? Map<String, double>.from(
              json['levelBestTimes'] as Map<String, dynamic>,
            )
          : <String, double>{},
      levelDeathCounts: json['levelDeathCounts'] != null
          ? Map<String, int>.from(
              json['levelDeathCounts'] as Map<String, dynamic>,
            )
          : <String, int>{},
      levelSecretsFound: json['levelSecretsFound'] != null
          ? (json['levelSecretsFound'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                List<String>.from(value as List<dynamic>),
              ),
            )
          : <String, List<String>>{},
    );
  }
  // Save metadata
  final int slotId;
  DateTime created;
  DateTime lastSaved;
  int saveVersion;

  // Player progression
  int playerLevel;
  int experience;
  int skillPoints;
  Map<String, int> unlockedSkills;
  Map<String, dynamic> playerStats;

  // World progression
  String currentLevel;
  String currentBiome;
  Map<String, bool> levelsCompleted;
  Map<String, bool> secretsFound;
  Map<String, bool> achievementsUnlocked;

  // Player inventory
  Map<String, int> inventory;
  Map<String, bool> itemsCollected;
  String equippedWeapon;
  String equippedArmor;
  List<String> equippedAccessories;

  // Game state
  Map<String, dynamic> playerPosition;
  Map<String, dynamic> checkpointData;
  List<String> unlockedAreas;
  Map<String, bool> npcsInteracted;
  Map<String, dynamic> questStates;

  // Time tracking
  Duration playtime;
  int deathCount;
  int jumpCount;
  int enemiesDefeated;
  // Settings snapshot (for save-specific settings)
  Map<String, dynamic> gameplaySettings;

  // Enhanced dialogue and interaction tracking
  Map<String, dynamic> dialogueStates;
  Map<String, dynamic> npcInteractionHistory;
  List<String> conversationHistory;
  Map<String, int> dialogueNodeVisitCounts;
  Map<String, DateTime> dialogueNodeLastVisited;

  // Enhanced achievement tracking
  Map<String, DateTime> achievementUnlockTimes;
  Map<String, dynamic> achievementProgress;

  // Enhanced player stats tracking (from PlayerStats class)
  Map<String, bool> unlockedAbilities;
  int aetherShards;

  // Enhanced level progression tracking
  Map<String, dynamic> levelCheckpoints;
  Map<String, double> levelBestTimes;
  Map<String, int> levelDeathCounts;
  Map<String, List<String>> levelSecretsFound;

  /// Create default player stats
  static Map<String, dynamic> _defaultPlayerStats() {
    return <String, dynamic>{
      'maxHealth': 100,
      'currentHealth': 100,
      'maxMana': 50,
      'currentMana': 50,
      'strength': 10,
      'agility': 10,
      'intelligence': 10,
      'defense': 10,
      'luck': 10,
      'movementSpeed': 1.0,
      'jumpHeight': 1.0,
      'criticalChance': 0.05,
      'criticalDamage': 1.5,
    };
  }

  /// Create default inventory
  static Map<String, int> _defaultInventory() {
    return <String, int>{
      'health_potion': 3,
      'mana_potion': 2,
      'coins': 100,
    };
  }

  /// Convert to JSON for saving
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slotId': slotId,
      'created': created.toIso8601String(),
      'lastSaved': lastSaved.toIso8601String(),
      'saveVersion': saveVersion,
      'playerLevel': playerLevel,
      'experience': experience,
      'skillPoints': skillPoints,
      'unlockedSkills': unlockedSkills,
      'playerStats': playerStats,
      'currentLevel': currentLevel,
      'currentBiome': currentBiome,
      'levelsCompleted': levelsCompleted,
      'secretsFound': secretsFound,
      'achievementsUnlocked': achievementsUnlocked,
      'inventory': inventory,
      'itemsCollected': itemsCollected,
      'equippedWeapon': equippedWeapon,
      'equippedArmor': equippedArmor,
      'equippedAccessories': equippedAccessories,
      'playerPosition': playerPosition,
      'checkpointData': checkpointData,
      'unlockedAreas': unlockedAreas,
      'npcsInteracted': npcsInteracted,
      'questStates': questStates,
      'playtime': playtime.inMilliseconds,
      'deathCount': deathCount,
      'jumpCount': jumpCount, 'enemiesDefeated': enemiesDefeated,
      'gameplaySettings': gameplaySettings,
      // Enhanced dialogue and interaction tracking
      'dialogueStates': dialogueStates,
      'npcInteractionHistory': npcInteractionHistory,
      'conversationHistory': conversationHistory,
      'dialogueNodeVisitCounts': dialogueNodeVisitCounts,
      'dialogueNodeLastVisited': dialogueNodeLastVisited
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
      // Enhanced achievement tracking
      'achievementUnlockTimes': achievementUnlockTimes
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
      'achievementProgress': achievementProgress,
      // Enhanced player stats tracking
      'unlockedAbilities': unlockedAbilities,
      'aetherShards': aetherShards,
      // Enhanced level progression tracking
      'levelCheckpoints': levelCheckpoints,
      'levelBestTimes': levelBestTimes,
      'levelDeathCounts': levelDeathCounts,
      'levelSecretsFound': levelSecretsFound,
    };
  }

  /// Update player stats
  void updatePlayerStats(Map<String, dynamic> newStats) {
    playerStats.addAll(newStats);
  }

  /// Add experience and handle level up
  bool addExperience(int exp) {
    experience += exp;
    final int requiredExp = getRequiredExperience(playerLevel + 1);

    if (experience >= requiredExp) {
      playerLevel++;
      skillPoints += 2; // Gain skill points on level up
      experience -= requiredExp;
      return true; // Level up occurred
    }
    return false;
  }

  /// Calculate required experience for a level
  int getRequiredExperience(int level) {
    return (level * level * 100) + (level * 50);
  }

  /// Add item to inventory
  void addItem(String itemId, int quantity) {
    inventory[itemId] = (inventory[itemId] ?? 0) + quantity;
  }

  /// Remove item from inventory
  bool removeItem(String itemId, int quantity) {
    final int currentQuantity = inventory[itemId] ?? 0;
    if (currentQuantity >= quantity) {
      inventory[itemId] = currentQuantity - quantity;
      if (inventory[itemId] == 0) {
        inventory.remove(itemId);
      }
      return true;
    }
    return false;
  }

  /// Mark level as completed
  void completeLevel(String levelId) {
    levelsCompleted[levelId] = true;
  }

  /// Mark secret as found
  void findSecret(String secretId) {
    secretsFound[secretId] = true;
  }

  /// Unlock achievement
  void unlockAchievement(String achievementId) {
    achievementsUnlocked[achievementId] = true;
  }

  /// Update player position
  void updatePosition(double x, double y, String facing) {
    playerPosition = <String, dynamic>{'x': x, 'y': y, 'facing': facing};
  }

  /// Set checkpoint data
  void setCheckpoint(String levelId, Map<String, dynamic> data) {
    checkpointData[levelId] = data;
  }

  /// Update playtime
  void updatePlaytime(Duration additionalTime) {
    playtime += additionalTime;
  }

  // Enhanced dialogue and interaction methods

  /// Update dialogue state from DialogueSystem
  void updateDialogueState(Map<String, dynamic> dialogueState) {
    dialogueStates.addAll(dialogueState);
  }

  /// Record NPC interaction
  void recordNPCInteraction(
    String npcId,
    Map<String, dynamic> interactionData,
  ) {
    npcInteractionHistory[npcId] = <String, dynamic>{
      'lastInteraction': DateTime.now().millisecondsSinceEpoch,
      'interactionCount':
          (npcInteractionHistory[npcId]?['interactionCount'] ?? 0) + 1,
      'dialogueTriggered': interactionData['dialogueTriggered'] ?? false,
      'questOffered': interactionData['questOffered'] ?? false,
      'lastDialogueId': interactionData['dialogueId'],
    };
    npcsInteracted[npcId] = true;
  }

  /// Add conversation history entry
  void addConversationHistoryEntry(String nodeId) {
    conversationHistory.add(nodeId);
    dialogueNodeVisitCounts[nodeId] =
        (dialogueNodeVisitCounts[nodeId] ?? 0) + 1;
    dialogueNodeLastVisited[nodeId] = DateTime.now();
  }

  /// Import conversation state from DialogueSystem
  void importConversationState(Map<String, dynamic> savedDialogueData) {
    if (savedDialogueData.containsKey('state')) {
      dialogueStates.addAll(savedDialogueData['state'] as Map<String, dynamic>);
    }
    if (savedDialogueData.containsKey('history')) {
      conversationHistory
          .addAll((savedDialogueData['history'] as List).cast<String>());
    }
    if (savedDialogueData.containsKey('visitCounts')) {
      dialogueNodeVisitCounts.addAll(
        (savedDialogueData['visitCounts'] as Map).cast<String, int>(),
      );
    }
    if (savedDialogueData.containsKey('lastVisited')) {
      final Map<String, dynamic> lastVisitedData =
          savedDialogueData['lastVisited'] as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in lastVisitedData.entries) {
        dialogueNodeLastVisited[entry.key] =
            DateTime.fromMillisecondsSinceEpoch(entry.value as int);
      }
    }
  }

  /// Export conversation state for DialogueSystem
  Map<String, dynamic> exportConversationState() {
    return <String, dynamic>{
      'state': Map<String, dynamic>.from(dialogueStates),
      'history': List<String>.from(conversationHistory),
      'visitCounts': Map<String, int>.from(dialogueNodeVisitCounts),
      'lastVisited': dialogueNodeLastVisited
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
    };
  }

  // Enhanced achievement tracking methods

  /// Unlock achievement with timestamp and progress tracking
  void unlockAchievementWithProgress(
    String achievementId, {
    Map<String, dynamic>? progressData,
  }) {
    if (!achievementsUnlocked.containsKey(achievementId) ||
        !achievementsUnlocked[achievementId]!) {
      achievementsUnlocked[achievementId] = true;
      achievementUnlockTimes[achievementId] = DateTime.now();
      if (progressData != null) {
        achievementProgress[achievementId] = progressData;
      }
    }
  }

  /// Update achievement progress
  void updateAchievementProgress(
    String achievementId,
    Map<String, dynamic> progressData,
  ) {
    achievementProgress[achievementId] = progressData;
  }

  /// Get achievement unlock time
  DateTime? getAchievementUnlockTime(String achievementId) {
    return achievementUnlockTimes[achievementId];
  }

  /// Get achievement progress
  Map<String, dynamic>? getAchievementProgress(String achievementId) {
    return achievementProgress[achievementId];
  }

  // Enhanced player stats methods (integrated with PlayerStats class)

  /// Update from PlayerStats component
  void updateFromPlayerStats({
    required double currentHealth,
    required double maxHealth,
    required double currentEnergy,
    required double maxEnergy,
    required int currentAether,
    required int maxAether,
    required int aetherShardsCount,
    required int level,
    required int experience,
    required bool canDoubleJump,
    required bool canDash,
    required bool canWallJump,
  }) {
    // Update basic player stats
    playerLevel = level;
    this.experience = experience;
    aetherShards = aetherShardsCount;

    // Update detailed stats
    playerStats.addAll(<String, dynamic>{
      'currentHealth': currentHealth,
      'maxHealth': maxHealth,
      'currentEnergy': currentEnergy,
      'maxEnergy': maxEnergy,
      'currentAether': currentAether,
      'maxAether': maxAether,
    });

    // Update unlocked abilities
    unlockedAbilities['doubleJump'] = canDoubleJump;
    unlockedAbilities['dash'] = canDash;
    unlockedAbilities['wallJump'] = canWallJump;
  }

  /// Unlock ability
  void unlockAbility(String abilityId) {
    unlockedAbilities[abilityId] = true;
  }

  /// Check if ability is unlocked
  bool isAbilityUnlocked(String abilityId) {
    return unlockedAbilities[abilityId] ?? false;
  }

  // Enhanced level progression methods

  /// Record level completion with detailed metrics
  void completeLevelWithMetrics(
    String levelId, {
    required double completionTime,
    required int deathCount,
    required List<String> secretsFound,
    Map<String, dynamic>? checkpointData,
  }) {
    // Mark level as completed
    levelsCompleted[levelId] = true;

    // Record completion metrics
    levelBestTimes[levelId] = levelBestTimes.containsKey(levelId)
        ? math.min(levelBestTimes[levelId]!, completionTime)
        : completionTime;

    levelDeathCounts[levelId] = deathCount;
    levelSecretsFound[levelId] = List<String>.from(secretsFound);

    // Update checkpoint data if provided
    if (checkpointData != null) {
      levelCheckpoints[levelId] = checkpointData;
    }

    // Mark individual secrets as found
    for (final String secret in secretsFound) {
      this.secretsFound['${levelId}_$secret'] = true;
    }
  }

  /// Get level completion metrics
  Map<String, dynamic> getLevelMetrics(String levelId) {
    return <String, dynamic>{
      'completed': levelsCompleted[levelId] ?? false,
      'bestTime': levelBestTimes[levelId],
      'deathCount': levelDeathCounts[levelId] ?? 0,
      'secretsFound': levelSecretsFound[levelId] ?? <String>[],
      'hasCheckpoint': levelCheckpoints.containsKey(levelId),
    };
  }

  /// Update checkpoint with enhanced data
  void updateLevelCheckpoint(
    String levelId,
    Map<String, dynamic> checkpointData,
  ) {
    levelCheckpoints[levelId] = <String, dynamic>{
      ...checkpointData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'playerStats': Map<String, dynamic>.from(playerStats),
      'inventory': Map<String, int>.from(inventory),
    };
  }

  /// Create a deep copy of the save data
  SaveData copy() {
    return SaveData.fromJson(toJson());
  }

  /// Validate save data integrity
  bool isValid() {
    try {
      // Basic validation checks
      if (slotId < 0 || playerLevel < 1) return false;
      if (experience < 0 || skillPoints < 0) return false;
      if (currentLevel.isEmpty || currentBiome.isEmpty) return false;
      if (playerStats.isEmpty || inventory.isEmpty) return false;

      // Validate required player stats
      final List<String> requiredStats = <String>[
        'maxHealth',
        'currentHealth',
        'maxMana',
        'currentMana',
      ];
      for (final String stat in requiredStats) {
        if (!playerStats.containsKey(stat)) return false;
      } // Validate enhanced data structures
      if (aetherShards < 0) return false;
      if (dialogueStates.isEmpty && conversationHistory.isNotEmpty) {
        return false;
      } // Validate ability unlocks keys are not empty
      for (final MapEntry<String, bool> entry in unlockedAbilities.entries) {
        if (entry.key.isEmpty) return false;
      }

      // Validate level metrics consistency
      for (final String levelId in levelsCompleted.keys) {
        if (levelsCompleted[levelId] == true) {
          // Completed levels should have some metrics
          if (!levelBestTimes.containsKey(levelId) &&
              !levelDeathCounts.containsKey(levelId)) {
            // This is a warning, not an error - legacy saves might not have metrics
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    final int completedLevels =
        levelsCompleted.values.where((completed) => completed).length;
    final int totalAchievements =
        achievementsUnlocked.values.where((unlocked) => unlocked).length;
    final int totalAbilities =
        unlockedAbilities.values.where((unlocked) => unlocked).length;

    return 'SaveData(slot: $slotId, level: $playerLevel, playtime: ${playtime.inHours}h ${playtime.inMinutes % 60}m, '
        'completed levels: $completedLevels, achievements: $totalAchievements, abilities: $totalAbilities, '
        'aether shards: $aetherShards)';
  }
}
