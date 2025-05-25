# Save System - Technical Design Document

## 1. Overview

Defines the implementation of the save system for Adventure Jumper, including game state persistence, checkpoint system, save data management, data serialization, and cross-device compatibility.

*For user interface elements of save system, see [Menus and Layouts](../../01_Game_Design/UI_UX_Design/Menus_Layouts.md).*

### Purpose
- Provide reliable and consistent save/load functionality
- Implement checkpoint and auto-save features
- Handle complex game state serialization and deserialization
- Support multiple save slots and save management
- Ensure cross-platform save data compatibility

### Scope
- Save data format and structure
- Save/load operations
- Checkpoint system integration
- Auto-save functionality
- Save data corruption handling
- Save data migration for updates

## 2. Class Design

### Core Save System Classes

```dart
// Main save system manager
class SaveSystem extends BaseSystem {
  // Save file management
  // Serialization coordination
  // Load operations
  // Checkpoint integration
  
  @override
  bool canProcessEntity(Entity entity) {
    // Save system doesn't typically process entities directly
    // It will mainly use processSystem for global state operations
    return false;
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Save system doesn't typically process entities individually
    // Not used in standard operation
  }
  
  @override
  void processSystem(double dt) {
    // Handle auto-save timing
    // Process checkpoint activation events
    // Manage save queuing and background operations
  }
}

// Game state container
class GameState {
  // Player state
  // World state
  // Progress tracking
  // Statistics and collectibles
}

// Save file manager
class SaveFileManager {
  // File I/O operations
  // Save slot management
  // Platform-specific storage handling
  // Data integrity checking
}
```

### Supporting Classes

```dart
// Save data serializer
class SaveSerializer {
  // Data encoding/decoding
  // Schema versioning
  // Backwards compatibility
  // Data compression
}

// Save metadata
class SaveMetadata {
  // Save slot information
  // Timestamp management
  // Thumbnail generation
  // Summary information
}

// Checkpoint manager
class CheckpointManager {
  // Checkpoint registration
  // Auto-save coordination
  // Respawn point management
  // Checkpoint validation
}
```

## 3. Data Structures

### Save Data
```dart
class SaveData {
  int version;                // Save format version
  String gameVersion;         // Game version when saved
  DateTime timestamp;         // When save was created
  String checkpointId;        // Last activated checkpoint
  GameState gameState;        // Complete game state
  SaveMetadata metadata;      // Save file metadata
  Map<String, dynamic> customData; // Game-specific data
  String platform;           // Platform identifier
}
```

### Player Save State
```dart
class PlayerSaveState {
  Vector2 position;           // Player position
  double health;              // Current health
  double maxHealth;           // Maximum health
  double aetherEnergy;        // Current energy
  double maxAetherEnergy;     // Maximum energy
  Map<String, bool> abilities; // Unlocked abilities
  Map<String, int> upgradelevels; // Ability upgrade levels
  List<String> collectedItems; // Inventory items
  Map<String, int> resources; // Currency and resources
  Map<String, bool> flags;    // Game state flags
}
```

### World Save State
```dart
class WorldSaveState {
  String currentLevelId;      // Current level identifier
  List<String> discoveredLevels; // Discovered levels
  Map<String, bool> activatedCheckpoints; // Checkpoint states
  Map<String, bool> defeatedBosses; // Boss defeat states
  Map<String, bool> collectedSecrets; // Secret collection
  Map<String, bool> completedChallenges; // Challenge completion
  Map<String, bool> unlockedDoors; // Persistent door states
  Map<String, dynamic> puzzleStates; // Puzzle completion states
  Map<String, int> npcStates; // NPC interaction states
}
```

### Save Metadata
```dart
class SaveMetadata {
  int slotId;                // Save slot number
  String displayName;         // Player-defined save name
  int playTimeSeconds;        // Total play time
  String thumbnailPath;       // Path to save thumbnail
  DateTime lastSaveTime;      // Most recent save time
  double completionPercentage; // Game completion percentage
  String currentWorldName;    // Current world display name
  String checkpointName;      // Current checkpoint name
  int playerLevel;           // Player progression level
}
```

## 4. Algorithms

### Save Operation
```
function saveGame(slotId):
  // Create save directory if it doesn't exist
  ensureSaveDirectoryExists()
  
  // Construct save data
  saveData = new SaveData()
  saveData.version = CURRENT_SAVE_VERSION
  saveData.gameVersion = getCurrentGameVersion()
  saveData.timestamp = getCurrentDateTime()
  saveData.checkpointId = checkpointManager.getCurrentCheckpointId()
  
  // Collect game state
  saveData.gameState = collectGameState()
  
  // Generate metadata
  saveData.metadata = generateSaveMetadata(slotId)
  
  // Serialize data
  serializedData = saveSerializer.serialize(saveData)
  
  // Generate save file path
  savePath = getSaveFilePath(slotId)
  
  // Write file with backup strategy
  success = writeWithBackup(savePath, serializedData)
  
  if success:
    notifyGameSaved()
    return true
  else:
    handleSaveFailure()
    return false
```

### Load Operation
```
function loadGame(slotId):
  // Check if save file exists
  savePath = getSaveFilePath(slotId)
  if not fileExists(savePath):
    return false
  
  try:
    // Read save file
    serializedData = readFile(savePath)
    
    // Deserialize data
    saveData = saveSerializer.deserialize(serializedData)
    
    // Validate save data integrity
    if not validateSaveData(saveData):
      throw "Invalid save data"
    
    // Check version compatibility
    if saveData.version > CURRENT_SAVE_VERSION:
      throw "Save from newer game version"
    
    // Perform version migration if needed
    if saveData.version < CURRENT_SAVE_VERSION:
      saveData = migrateSaveData(saveData, CURRENT_SAVE_VERSION)
    
    // Apply game state
    applyGameState(saveData.gameState)
    
    // Set checkpoint for respawn
    checkpointManager.setActiveCheckpoint(saveData.checkpointId)
    
    // Update metadata
    updateSaveMetadata(saveData.metadata)
    
    // Notify success
    notifyGameLoaded()
    return true
  
  catch error:
    handleLoadFailure(error)
    attemptSaveRecovery(slotId)
    return false
```

### Auto-Save
```
function autoSave():
  // Check if auto-save is enabled
  if not isAutoSaveEnabled():
    return
  
  // Check if enough time has passed since last auto-save
  timeSinceLastSave = getCurrentTime() - lastAutoSaveTime
  if timeSinceLastSave < AUTO_SAVE_INTERVAL:
    return
  
  // Check if player is in a valid auto-save state
  if not canAutoSaveNow():
    return
  
  // Perform auto-save to dedicated slot
  saveGame(AUTO_SAVE_SLOT_ID)
  lastAutoSaveTime = getCurrentTime()
  
  // Show subtle auto-save notification
  showAutoSaveIndicator()
```

### Save Data Migration
```
function migrateSaveData(saveData, targetVersion):
  currentVersion = saveData.version
  
  while currentVersion < targetVersion:
    switch currentVersion:
      case 1:
        // Migrate from v1 to v2
        saveData = migrateV1toV2(saveData)
        currentVersion = 2
      
      case 2:
        // Migrate from v2 to v3
        saveData = migrateV2toV3(saveData)
        currentVersion = 3
      
      // Additional version migrations...
  
  // Update version number
  saveData.version = targetVersion
  return saveData
```

## 5. API/Interfaces

### Save System Interface
```dart
interface ISaveSystem {
  Future<bool> saveGame(int slotId);
  Future<bool> loadGame(int slotId);
  Future<bool> deleteSave(int slotId);
  bool hasSaveData(int slotId);
  List<SaveMetadata> getAvailableSaves();
  void enableAutoSave(bool enable);
  void createCheckpointSave();
}

interface IGameStateSerialization {
  Map<String, dynamic> serializeGameState();
  void deserializeGameState(Map<String, dynamic> data);
  bool validateGameState(Map<String, dynamic> data);
}
```

### Checkpoint Interface
```dart
interface ICheckpointManager {
  void registerCheckpoint(String checkpointId, Vector2 position);
  void activateCheckpoint(String checkpointId);
  String getCurrentCheckpointId();
  Vector2 getCurrentRespawnPoint();
  List<String> getActivatedCheckpoints();
  bool isCheckpointActivated(String checkpointId);
}

interface ISaveable {
  Map<String, dynamic> serialize();
  void deserialize(Map<String, dynamic> data);
}
```

## 6. Dependencies

### System Dependencies
- **File System**: For save file I/O operations
- **Level Management**: For level state and checkpoint integration
- **Player Character**: For player state serialization
- **UI System**: For save/load interface and notifications
- **Event System**: For save/load events and checkpoint activation

### Technical Dependencies
- JSON serialization library
- Data compression library
- Platform storage APIs
- File encryption (optional)

## 7. File Structure

```
lib/
  game/
    systems/
      save/
        save_system.dart          # Main save system
        save_file_manager.dart    # File operations
        save_serializer.dart      # Data serialization
        checkpoint_manager.dart   # Checkpoint handling
        save_migration.dart       # Version migration
        save_encryption.dart      # Optional encryption
    models/
      save/
        save_data.dart            # Save data structure
        game_state.dart          # Complete game state
        player_save_state.dart    # Player state
        world_save_state.dart     # World state
        save_metadata.dart        # Save metadata
    components/
      saveable.dart             # Saveable component mixin
    utils/
      save/
        save_constants.dart       # Save system constants
        save_validators.dart      # Data validation
        save_recovery.dart        # Recovery mechanisms
```

## 8. Performance Considerations

### Optimization Strategies
- Asynchronous save/load operations
- Data compression for large save files
- Efficient serialization algorithms
- Save data pruning for unnecessary information
- Background threading for save operations

### Memory Management
- Stream-based file operations
- Cleanup of temporary serialization objects
- Efficient handling of save thumbnails
- Strategic auto-save timing to avoid performance spikes

## 9. Testing Strategy

### Unit Tests
- Save serialization and deserialization
- Migration between versions
- Data integrity validation
- File I/O operations

### Integration Tests
- Complete save/load cycle
- Auto-save functionality
- Checkpoint system integration
- Cross-platform compatibility

## 10. Implementation Notes

### Development Phases
1. **Phase 1**: Basic save/load functionality
2. **Phase 2**: Checkpoint integration
3. **Phase 3**: Auto-save implementation
4. **Phase 4**: Migration and compatibility
5. **Phase 5**: Error handling and recovery

### Save System Guidelines
- **Reliability**: Prioritize data integrity above all
- **Performance**: Minimize impact on gameplay
- **Clarity**: Provide clear feedback about save operations
- **Recovery**: Include robust error recovery mechanisms
- **Compatibility**: Ensure forward/backward compatibility

## 11. Future Considerations

### Expandability
- Cloud save synchronization
- Save sharing and importing
- Save state analysis tools
- Alternative save formats

### Advanced Features
- Save states with thumbnail previews
- Save categories and organization
- Enhanced auto-save strategies
- In-game save state modification (cheats/debug)

## 12. Security Considerations

### Data Protection
- Save data encryption for sensitive information
- Checksum validation for data integrity
- Backup save creation before overwriting
- Protection against external file modification

### Anti-Cheat Measures
- Basic save tampering detection
- Achievement integrity protection
- Hidden validation values
- Secure timestamp tracking

## Related Design Documents

- See [Menus and Layouts](../../01_Game_Design/UI_UX_Design/Menus_Layouts.md) for save/load interface design
- See [World Connections](../../01_Game_Design/Worlds/00-World-Connections.md) for checkpoint location designs
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for save integration with progression
