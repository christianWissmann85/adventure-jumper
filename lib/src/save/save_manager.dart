import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../utils/error_handler.dart';
import '../utils/logger.dart';
import 'progress_tracker.dart';
import 'save_data.dart';
import 'settings.dart';

/// Manages all save/load operations for the Adventure Jumper game
/// Handles automatic saves, manual saves, and data validation
class SaveManager {
  SaveManager._internal();
  static SaveManager? _instance;
  static SaveManager get instance => _instance ??= SaveManager._internal();

  // Save data components
  SaveData? _currentSave;
  ProgressTracker? _progressTracker;
  Settings? _settings;

  // Save file management
  late String _saveDirectory;
  late String _settingsFile;
  static const String saveFileName = 'adventure_jumper_save.json';
  static const String settingsFileName = 'adventure_jumper_settings.json';
  static const String progressFileName = 'adventure_jumper_progress.json';
  // Auto-save configuration
  Timer? _autoSaveTimer;
  static const Duration autoSaveInterval = Duration(minutes: 5);
  bool _autoSaveEnabled = true;
  bool _isDirty = false;

  // Save slots
  static const int maxSaveSlots = 5;
  int _currentSlot = 0;

  /// Initialize the save manager and load existing data
  Future<void> initialize() async {
    await _setupDirectories();
    await _loadSettings();
    await _loadProgress();
    await loadGame(_currentSlot);
    _startAutoSave();
  }

  /// Set up save directories
  Future<void> _setupDirectories() async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    _saveDirectory = '${documentsDir.path}/AdventureJumper/saves';
    _settingsFile = '${documentsDir.path}/AdventureJumper/$settingsFileName';

    // Create directories if they don't exist
    final Directory saveDir = Directory(_saveDirectory);
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }
  }

  /// Load game settings
  Future<void> _loadSettings() async {
    try {
      final File file = File(_settingsFile);
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> jsonData =
            json.decode(jsonString) as Map<String, dynamic>;
        _settings = Settings.fromJson(jsonData);
      } else {
        _settings = Settings(); // Create default settings
        await _saveSettings();
      }
    } catch (e) {
      logger.warning('Error loading settings', e);
      _settings = Settings(); // Fallback to default
    }
  }

  /// Save game settings
  Future<void> _saveSettings() async {
    return ErrorHandler.handleSaveError(
      () async {
        final File file = File(_settingsFile);
        final String jsonString = json.encode(_settings!.toJson());
        await file.writeAsString(jsonString);
        ErrorHandler.logInfo(
          'Settings saved successfully',
          context: 'SaveManager',
        );
      },
      'save_settings',
      context: 'SaveManager._saveSettings',
    );
  }

  /// Load progress tracker
  Future<void> _loadProgress() async {
    final ProgressTracker? result = await ErrorHandler.handleSaveError(
      () async {
        final File file = File('$_saveDirectory/$progressFileName');
        if (await file.exists()) {
          final String jsonString = await file.readAsString();
          final Map<String, dynamic> jsonData =
              json.decode(jsonString) as Map<String, dynamic>;
          return ProgressTracker.fromJson(jsonData);
        } else {
          final ProgressTracker newTracker = ProgressTracker();
          _progressTracker = newTracker;
          await _saveProgress();
          return newTracker;
        }
      },
      'load_progress',
      fallback: ProgressTracker(),
      context: 'SaveManager._loadProgress',
    );

    _progressTracker = result ?? ProgressTracker();
    if (result != null) {
      ErrorHandler.logInfo(
        'Progress tracker loaded successfully',
        context: 'SaveManager',
      );
    }
  }

  /// Save progress tracker
  Future<void> _saveProgress() async {
    return ErrorHandler.handleSaveError(
      () async {
        final File file = File('$_saveDirectory/$progressFileName');
        final String jsonString = json.encode(_progressTracker!.toJson());
        await file.writeAsString(jsonString);
        ErrorHandler.logInfo(
          'Progress tracker saved successfully',
          context: 'SaveManager',
        );
      },
      'save_progress',
      context: 'SaveManager._saveProgress',
    );
  }

  /// Load game from specific slot
  Future<bool> loadGame(int slot) async {
    final bool? result = await ErrorHandler.handleSaveError(
      () async {
        final File saveFile = File('$_saveDirectory/save_slot_$slot.json');
        if (await saveFile.exists()) {
          final String jsonString = await saveFile.readAsString();
          final Map<String, dynamic> jsonData =
              json.decode(jsonString) as Map<String, dynamic>;
          _currentSave = SaveData.fromJson(jsonData);
          _currentSlot = slot;
          _isDirty = false;
          ErrorHandler.logInfo(
            'Game loaded successfully from slot $slot',
            context: 'SaveManager',
          );
          return true;
        } else {
          // Create new save data
          _currentSave = SaveData(slotId: slot);
          _currentSlot = slot;
          _isDirty = true;
          ErrorHandler.logInfo(
            'Created new save data for slot $slot',
            context: 'SaveManager',
          );
          return false;
        }
      },
      'load_game',
      fallback: false,
      context: 'SaveManager.loadGame',
    );

    // Ensure we have valid save data even on error
    if (result == null) {
      _currentSave = SaveData(slotId: slot);
      _currentSlot = slot;
      _isDirty = true;
      return false;
    }
    return result;
  }

  /// Save current game to slot
  Future<bool> saveGame([int? slot]) async {
    try {
      final int saveSlot = slot ?? _currentSlot;
      final File saveFile = File('$_saveDirectory/save_slot_$saveSlot.json');

      if (_currentSave != null) {
        _currentSave!.lastSaved = DateTime.now();
        final String jsonString = json.encode(_currentSave!.toJson());
        await saveFile.writeAsString(jsonString);
        _isDirty = false;
        return true;
      }
      return false;
    } catch (e) {
      logger.warning('Error saving game', e);
      return false;
    }
  }

  /// Get save slot information
  Future<List<SaveSlotInfo>> getSaveSlots() async {
    final List<SaveSlotInfo> slots = <SaveSlotInfo>[];

    for (int i = 0; i < maxSaveSlots; i++) {
      final File saveFile = File('$_saveDirectory/save_slot_$i.json');
      if (await saveFile.exists()) {
        try {
          final String jsonString = await saveFile.readAsString();
          final Map<String, dynamic> jsonData =
              json.decode(jsonString) as Map<String, dynamic>;
          final SaveData saveData = SaveData.fromJson(jsonData);
          slots.add(
            SaveSlotInfo(
              slotId: i,
              exists: true,
              lastSaved: saveData.lastSaved,
              playerLevel: saveData.playerLevel,
              currentLevel: saveData.currentLevel,
              playtime: saveData.playtime,
            ),
          );
        } catch (e) {
          slots.add(SaveSlotInfo(slotId: i, exists: false));
        }
      } else {
        slots.add(SaveSlotInfo(slotId: i, exists: false));
      }
    }

    return slots;
  }

  /// Delete save slot
  Future<bool> deleteSave(int slot) async {
    try {
      final File saveFile = File('$_saveDirectory/save_slot_$slot.json');
      if (await saveFile.exists()) {
        await saveFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      logger.warning('Error deleting save', e);
      return false;
    }
  }

  /// Start auto-save timer
  void _startAutoSave() {
    if (_autoSaveEnabled) {
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer.periodic(autoSaveInterval, (Timer timer) {
        if (_isDirty) {
          saveGame();
        }
      });
    }
  }

  /// Stop auto-save timer
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Mark save data as dirty (needs saving)
  void markDirty() {
    _isDirty = true;
  }

  /// Export save data to external file
  Future<String?> exportSave(int slot) async {
    try {
      final File saveFile = File('$_saveDirectory/save_slot_$slot.json');
      if (await saveFile.exists()) {
        return await saveFile.readAsString();
      }
      return null;
    } catch (e) {
      logger.warning('Error exporting save', e);
      return null;
    }
  }

  /// Import save data from external source
  Future<bool> importSave(String jsonData, int slot) async {
    try {
      // Validate JSON data
      final Map<String, dynamic> decodedData =
          json.decode(jsonData) as Map<String, dynamic>;
      final SaveData saveData = SaveData.fromJson(decodedData);

      // Use saveData for validation purposes
      if (!saveData.isValid()) {
        return false;
      }

      // Save to slot
      final File saveFile = File('$_saveDirectory/save_slot_$slot.json');
      await saveFile.writeAsString(jsonData);

      return true;
    } catch (e) {
      logger.warning('Error importing save', e);
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _autoSaveTimer?.cancel();
  }

  // Getters
  SaveData? get currentSave => _currentSave;
  ProgressTracker? get progressTracker => _progressTracker;
  Settings? get settings => _settings;
  int get currentSlot => _currentSlot;
  bool get autoSaveEnabled => _autoSaveEnabled;

  // Setters
  set autoSaveEnabled(bool enabled) {
    _autoSaveEnabled = enabled;
    if (enabled) {
      _startAutoSave();
    } else {
      stopAutoSave();
    }
  }
}

/// Information about a save slot
class SaveSlotInfo {
  SaveSlotInfo({
    required this.slotId,
    required this.exists,
    this.lastSaved,
    this.playerLevel,
    this.currentLevel,
    this.playtime,
  });
  final int slotId;
  final bool exists;
  final DateTime? lastSaved;
  final int? playerLevel;
  final String? currentLevel;
  final Duration? playtime;
}
