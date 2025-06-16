# Crafting System - Technical Design Document

## 1. Overview

Defines the implementation of crafting mechanics for Adventure Jumper, including resource collection, recipe discovery, item creation, and gear upgrading across the various worlds of Aetheris.

*For crafting design concepts and world-specific resources, see [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) and [World Connections](../../01_Game_Design/Worlds/00-World-Connections.md).*

### Purpose
- Implement engaging crafting mechanics that enhance player progression
- Create a resource collection system that encourages exploration
- Develop recipes and blueprints for creating and upgrading items
- Tie crafting to the narrative themes and world environments
- Provide meaningful customization and specialization options

### Scope
- Resource collection and management
- Recipe discovery and organization
- Item crafting interface and feedback
- Upgrade systems for gear and abilities
- Crafting station interactions
- Recipe balancing and progression

## 2. Class Design

### Core Crafting Classes

```dart
// Main crafting system manager
class CraftingSystem extends BaseSystem {
  // Recipe management
  // Resource tracking
  // Crafting operations
  // Upgrade calculations
  
  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has resource components or is a crafting station
    return entity.children.whereType<ResourceComponent>().isNotEmpty ||
           entity.children.whereType<CraftingStationComponent>().isNotEmpty ||
           entity is ResourceNode || 
           entity is CraftingStation;
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Process resource respawn timers
    // Update crafting station states
    // Handle resource node interactions
  }
  
  @override
  void processSystem(double dt) {
    // Process ongoing crafting operations
    // Update recipe availability based on player progression
    // Handle resource discovery notifications
  }
}

// Recipe manager
class RecipeManager {
  // Recipe storage
  // Recipe discovery
  // Recipe filtering
  // Recipe validation
}

// Resource management
class ResourceManager {
  // Resource inventory
  // Collection tracking
  // Storage limits
  // Resource types
}
```

### Supporting Classes

```dart
// Recipe data
class Recipe {
  // Ingredients list
  // Result item
  // Crafting requirements
  // Discovery conditions
}

// Crafting station component
class CraftingStation extends InteractableObject {
  // Station type
  // Available recipes
  // Crafting bonuses
  // Visual effects
}

// Resource node
class ResourceNode extends InteractableObject {
  // Resource type
  // Resource amount
  // Respawn timer
  // Collection difficulty
}
```

## 3. Data Structures

### Crafting Configuration
```dart
class CraftingConfig {
  int maxInventorySpace;       // Maximum inventory space
  int maxStackSize;            // Maximum stack size per item type
  double craftingTimeBase;     // Base crafting time
  bool enableAutoCrafting;     // Auto-crafting toggle
  Map<String, int> stationLevels; // Crafting station upgrade levels
  int maxRecursiveCrafting;    // Max depth for recursive crafting
  bool requireCraftingStations; // Whether stations are required
  List<String> startingRecipes; // Initially available recipes
}
```

### Resource Data
```dart
class ResourceData {
  String resourceId;          // Unique resource identifier
  String displayName;         // Display name
  String description;         // Resource description
  String iconPath;            // Icon asset path
  String worldOrigin;         // Primary world of origin
  int rarity;                 // Rarity level (1-5)
  List<String> gatheringTools; // Tools that can collect it
  double baseGatherTime;      // Base time to gather
  bool isRenewable;           // Whether resource respawns
  int maxStackSize;           // Max stack size override
  String category;            // Resource category
}
```

### Recipe Data
```dart
class RecipeData {
  String recipeId;               // Unique recipe identifier
  String resultItemId;           // ID of crafted item
  int resultQuantity;            // Number of items produced
  List<CraftingIngredient> ingredients; // Required ingredients
  String stationType;            // Required station type
  int stationLevelRequired;      // Min station level
  int playerLevelRequired;       // Min player level
  List<String> requiredAchievements; // Required achievements
  String discoveryMethod;        // How recipe is discovered
  double craftingTime;           // Time to craft
  int experienceReward;          // XP for crafting
  bool isUpgrade;                // Whether it's an upgrade recipe
}
```

### Crafting Ingredient
```dart
class CraftingIngredient {
  String resourceId;           // Resource identifier
  int quantity;                // Required quantity
  bool isConsumed;             // Whether consumed in crafting
  bool isOptional;             // Whether ingredient is optional
  String qualityEffect;        // Effect of ingredient quality
}
```

### Crafting Station Data
```dart
class CraftingStationData {
  String stationId;            // Unique station identifier
  String displayName;          // Display name
  String description;          // Station description
  String modelPath;            // 3D model asset path
  String iconPath;             // Icon asset path
  List<String> specialtyTypes; // Recipe types with bonuses
  Map<String, double> bonuses; // Crafting bonuses by type
  int maxLevel;                // Maximum upgrade level
  List<String> worldsFound;    // Worlds where found
  bool isPortable;             // Whether station is portable
}
```

## 4. Algorithms

### Recipe Validation
```
function validateRecipe(recipeId, playerInventory, playerLevel, playerAchievements):
  // Get recipe data
  recipe = getRecipeData(recipeId)
  
  // Check player level requirement
  if playerLevel < recipe.playerLevelRequired:
    return { valid: false, reason: "LEVEL_TOO_LOW" }
  
  // Check achievements
  for achievement in recipe.requiredAchievements:
    if not playerAchievements.contains(achievement):
      return { valid: false, reason: "MISSING_ACHIEVEMENT" }
  
  // Check ingredients
  for ingredient in recipe.ingredients:
    resourceCount = playerInventory.getResourceCount(ingredient.resourceId)
    if resourceCount < ingredient.quantity:
      return { valid: false, reason: "MISSING_RESOURCES", 
               resourceId: ingredient.resourceId, 
               has: resourceCount, 
               needs: ingredient.quantity }
  
  // Check if result can fit in inventory
  if not playerInventory.canAddItem(recipe.resultItemId, recipe.resultQuantity):
    return { valid: false, reason: "INVENTORY_FULL" }
  
  // All checks passed
  return { valid: true }
```

### Crafting Execution
```
function executeCrafting(recipeId, playerInventory, craftingStation):
  // Validate recipe first
  validation = validateRecipe(recipeId, playerInventory, player.level, player.achievements)
  if not validation.valid:
    return { success: false, reason: validation.reason }
  
  recipe = getRecipeData(recipeId)
  
  // Calculate crafting time
  craftTime = recipe.craftingTime
  
  // Apply station bonuses if available
  if craftingStation != null:
    stationType = craftingStation.getStationType()
    stationLevel = craftingStation.getStationLevel()
    
    // Check if station meets level requirement
    if stationLevel < recipe.stationLevelRequired:
      return { success: false, reason: "STATION_LEVEL_TOO_LOW" }
    
    // Apply station type bonuses
    if recipe.stationType == stationType:
      craftTime *= craftingStation.getTimeMultiplier()
      
    // Apply specialty bonuses
    if craftingStation.hasSpecialtyFor(recipe.resultItemId):
      craftTime *= SPECIALTY_TIME_BONUS
  else:
    // Check if station is required
    if craftingConfig.requireCraftingStations and recipe.stationType != "none":
      return { success: false, reason: "STATION_REQUIRED" }
  
  // Start crafting process
  startCraftingProcess(recipe, craftTime)
  
  // Consume ingredients
  for ingredient in recipe.ingredients:
    if ingredient.isConsumed:
      playerInventory.removeResource(ingredient.resourceId, ingredient.quantity)
  
  // Return immediate result for tracking
  return { 
    success: true, 
    recipeId: recipeId,
    craftingTime: craftTime,
    resultItemId: recipe.resultItemId,
    resultQuantity: recipe.resultQuantity
  }
```

### Recipe Discovery
```
function checkForRecipeDiscoveries(player, worldId, event):
  discoveredRecipes = []
  
  // Get all undiscovered recipes
  undiscoveredRecipes = getAllUndiscoveredRecipes(player.knownRecipes)
  
  for recipe in undiscoveredRecipes:
    discovered = false
    
    // Check discovery method
    switch (recipe.discoveryMethod):
      case "WORLD_ENTRY":
        if event.type == "WORLD_ENTERED" and event.worldId == worldId:
          discovered = true
      
      case "RESOURCE_COLLECTION":
        if event.type == "RESOURCE_COLLECTED":
          // Check if this resource contributes to recipe discovery
          if isRecipeIngredient(recipe, event.resourceId):
            // Mark resource as seen
            player.discoveryProgress.markResourceSeen(recipe.recipeId, event.resourceId)
            
            // Check if all ingredients have been seen
            if player.discoveryProgress.allIngredientsFound(recipe.recipeId):
              discovered = true
      
      case "LEVEL_UP":
        if event.type == "PLAYER_LEVEL_UP" and player.level >= recipe.playerLevelRequired:
          discovered = true
      
      case "ACHIEVEMENT":
        if event.type == "ACHIEVEMENT_EARNED" and recipe.requiredAchievements.contains(event.achievementId):
          discovered = true
      
      case "STATION_INTERACTION":
        if event.type == "STATION_USED" and event.stationType == recipe.stationType:
          discovered = true
    
    // Add discovered recipe
    if discovered:
      player.knownRecipes.add(recipe.recipeId)
      discoveredRecipes.push(recipe)
  
  // Return list of newly discovered recipes
  return discoveredRecipes
```

### Upgrade Calculation
```
function calculateUpgradeResult(baseItem, upgradeRecipe):
  // Get base stats of the item
  baseStats = baseItem.getStats()
  
  // Get upgrade modifiers
  upgradeModifiers = upgradeRecipe.getModifiers()
  
  // Calculate new stats
  newStats = {}
  for statName, baseValue in baseStats:
    if upgradeModifiers.contains(statName):
      // Apply modifier (add, multiply, or replace)
      modType = upgradeModifiers[statName].type
      modValue = upgradeModifiers[statName].value
      
      if modType == "ADD":
        newStats[statName] = baseValue + modValue
      else if modType == "MULTIPLY":
        newStats[statName] = baseValue * modValue
      else if modType == "REPLACE":
        newStats[statName] = modValue
    else:
      // Keep existing stat unchanged
      newStats[statName] = baseValue
  
  // Check for new stats being added
  for statName, modifier in upgradeModifiers:
    if not baseStats.contains(statName) and modifier.type == "ADD":
      newStats[statName] = modifier.value
  
  // Create upgraded item
  upgradedItem = createUpgradedItem(baseItem, newStats, upgradeRecipe)
  
  return upgradedItem
```

## 5. API/Interfaces

### Crafting System Interface
```dart
interface ICraftingSystem {
  bool canCraftRecipe(String recipeId);
  Future<CraftingResult> craftItem(String recipeId, {CraftingStation station});
  List<String> getAvailableRecipes();
  List<String> getFilteredRecipes(String category);
  double getEstimatedCraftingTime(String recipeId, {CraftingStation station});
  void cancelCrafting(String craftingProcessId);
  void addResource(String resourceId, int amount);
  void removeResource(String resourceId, int amount);
  int getResourceAmount(String resourceId);
  bool discoverRecipe(String recipeId);
  List<RecipeRequirement> getMissingRequirements(String recipeId);
}

interface IResourceNode {
  Future<GatheringResult> gather(String toolId);
  bool canGather(String toolId);
  double getGatheringTime(String toolId);
  String getResourceType();
  int getResourceAmount();
}
```

### Recipe Interface
```dart
interface IRecipeManager {
  List<Recipe> getAllRecipes();
  List<Recipe> getKnownRecipes();
  List<Recipe> getRecipesByCategory(String category);
  List<Recipe> getRecipesByResource(String resourceId);
  Recipe getRecipeById(String recipeId);
  bool isRecipeKnown(String recipeId);
  void discoverRecipe(String recipeId);
  List<Recipe> getRecipesForStation(String stationType, int stationLevel);
}

interface ICraftingStation {
  String getStationType();
  int getStationLevel();
  double getTimeMultiplier();
  bool canCraftRecipe(String recipeId);
  List<String> getSpecialties();
  void upgradeStation(int newLevel);
}
```

## 6. Dependencies

### System Dependencies
- **Inventory System**: For resource storage and item management
- **Player Progression**: For level checks and experience rewards
- **Achievement System**: For recipe discovery and requirements
- **World Management**: For location-specific recipes and stations
- **UI System**: For crafting interface and feedback
- **Event System**: For triggering recipe discoveries

### Technical Dependencies
- Item data loading and processing
- Resource configuration files
- Recipe balancing data
- Station placement in worlds
- Resource node configuration

## 7. File Structure

```
lib/
  game/
    systems/
      crafting/
        crafting_system.dart        # Main crafting system
        recipe_manager.dart         # Recipe handling
        resource_manager.dart       # Resource management
        crafting_process.dart       # Crafting execution
        discovery_tracker.dart      # Recipe discovery logic
    components/
      crafting/
        crafting_station.dart       # Crafting station component
        resource_node.dart          # Resource node component
        gathering_tool.dart         # Tool component
        inventory_extension.dart    # Inventory crafting capabilities
    data/
      crafting/
        recipe_data.dart            # Recipe definitions
        resource_data.dart          # Resource definitions
        station_data.dart           # Station definitions
        upgrade_modifiers.dart      # Upgrade calculations
assets/
  crafting/
    icons/                          # Resource and recipe icons
      resources/
      recipes/
      stations/
    effects/                        # Crafting visual effects
    animations/                     # Crafting animations
```

## 8. Performance Considerations

### Optimization Strategies
- Efficient recipe filtering and lookup
- On-demand resource validation
- Batched crafting operations
- Asynchronous recipe discovery checks
- Spatial indexing for resource nodes

### Memory Management
- Resource pooling for common materials
- Template-based recipe instantiation
- Lightweight resource node representation
- Resource node level-of-detail

## 9. Testing Strategy

### Unit Tests
- Recipe validation logic
- Resource calculation accuracy
- Crafting time calculations
- Upgrade result verification

### Integration Tests
- Full crafting workflow
- Recipe discovery triggers
- Inventory-crafting interaction
- Station upgrade progression

## 10. Implementation Notes

### Development Phases
1. **Phase 1**: Basic resource collection and storage
2. **Phase 2**: Simple crafting without stations
3. **Phase 3**: Crafting stations and specialized recipes
4. **Phase 4**: Upgrade systems and advanced crafting
5. **Phase 5**: Recipe discovery and progression balancing

### Design Principles
- **Rewarding Exploration**: Link resource collection to world exploration
- **Meaningful Choices**: Recipes should offer genuine alternatives
- **Clear Progression**: Upgrade paths should be valuable and visible
- **Balanced Economy**: Resources should maintain value throughout gameplay
- **Discoverable Depth**: Easy to learn, with depth to master

## 11. Future Considerations

### Expandability
- Crafting skill progression system
- Recipe quality variations based on player skill
- Randomized or procedural recipe generation
- Temporary crafting buffs from consumables
- Player-created recipe sharing

### Advanced Features
- Resource trading between players
- Limited-time special recipes
- World events affecting resource availability
- Specialized crafting minigames
- Resource transformation over time

## Related Design Documents

- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for crafting integration with progression
- See [World Connections](../../01_Game_Design/Worlds/00-World-Connections.md) for world-specific resources
- See [UI/UX Menus and Layouts](../../01_Game_Design/UI_UX_Design/Menus_Layouts.md) for crafting interface design
- See [Main Character](../../01_Game_Design/Characters/01-main-character.md) for equipment and upgrades
