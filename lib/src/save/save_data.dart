/// Core save data structure for Adventure Jumper game
/// Contains all persistent game state information
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
        playerPosition = playerPosition ?? <String, dynamic>{'x': 0.0, 'y': 0.0, 'facing': 'right'},
        checkpointData = checkpointData ?? <String, dynamic>{},
        unlockedAreas = unlockedAreas ?? <String>['grasslands'],
        npcsInteracted = npcsInteracted ?? <String, bool>{},
        questStates = questStates ?? <String, dynamic>{},
        playtime = playtime ?? Duration.zero,
        gameplaySettings = gameplaySettings ?? <String, dynamic>{};

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
          json['achievementsUnlocked'] as Map<dynamic, dynamic>? ?? <String, bool>{},
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
      'jumpCount': jumpCount,
      'enemiesDefeated': enemiesDefeated,
      'gameplaySettings': gameplaySettings,
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
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'SaveData(slot: $slotId, level: $playerLevel, playtime: ${playtime.inHours}h ${playtime.inMinutes % 60}m)';
  }
}
