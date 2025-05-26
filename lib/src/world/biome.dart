import 'dart:ui';

import '../audio/ambient_sound.dart';
import 'level.dart';

/// Biome-specific configuration
/// Defines environmental themes, effects, and properties for different world areas
class Biome {
  Biome({
    required this.type,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    this.gravity,
    this.ambientSoundtrack,
    this.particleEffects = const <String>[],
    this.environmentalHazards = const <String>[],
    this.backgroundFar,
    this.backgroundMid,
    this.backgroundNear,
    this.windIntensity = 0,
    this.hasAetherEnhancement = false,
  });

  /// Create a Forest biome instance
  factory Biome.forest() {
    return Biome(
      type: BiomeType.forest,
      name: 'Whispering Woods',
      description: 'Lush forests with tall trees and flowing streams.',
      primaryColor: const Color(0xFF2D5F2D), // Forest green
      secondaryColor: const Color(0xFF83B271), // Light green
      ambientSoundtrack: 'ambient/forest.mp3',
      particleEffects: <String>['leaves', 'dust'],
      environmentalHazards: <String>['pitfall'],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF2D5F2D), // Forest green
        const Color(0xFF83B271), // Light green
        const Color(0xFF9C6428), // Brown (tree trunks)
        const Color(0xFF71A6D2), // Blue (water/sky)
      ]);
  }

  /// Create a Cave biome instance
  factory Biome.cave() {
    return Biome(
      type: BiomeType.cave,
      name: 'Echoing Depths',
      description:
          'Dark caverns with crystal formations and underground lakes.',
      primaryColor: const Color(0xFF3A3A4D), // Dark blue-grey
      secondaryColor: const Color(0xFF5E5E7A), // Medium blue-grey
      ambientSoundtrack: 'ambient/cave.mp3',
      particleEffects: <String>['dust', 'drips'],
      environmentalHazards: <String>['spikes', 'collapse'],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF3A3A4D), // Dark blue-grey
        const Color(0xFF5E5E7A), // Medium blue-grey
        const Color(0xFF7D7DA3), // Light blue-grey
        const Color(0xFFA9A1B8), // Pale purple
      ]);
  }

  /// Create a Mountain biome instance
  factory Biome.mountain() {
    return Biome(
      type: BiomeType.mountain,
      name: 'Crystal Peaks',
      description:
          'Snow-capped mountains with treacherous cliffs and howling winds.',
      primaryColor: const Color(0xFF6F8AA0), // Slate blue
      secondaryColor: const Color(0xFFD5DEE6), // Light grey-blue
      gravity: 10.2, // Slightly higher gravity
      windIntensity: 0.5,
      ambientSoundtrack: 'ambient/mountain.mp3',
      particleEffects: <String>['snow', 'mist'],
      environmentalHazards: <String>['avalanche', 'wind'],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF6F8AA0), // Slate blue
        const Color(0xFFD5DEE6), // Light grey-blue
        const Color(0xFFFFFFFF), // White (snow)
        const Color(0xFF4A5B6E), // Dark blue (rocks)
      ]);
  }

  /// Create an Aether Realm biome instance
  factory Biome.aetherRealm() {
    return Biome(
      type: BiomeType.aetherRealm,
      name: 'Flowing Aether',
      description:
          'Ethereal spaces where reality bends and Aether flows freely.',
      primaryColor: const Color(0xFF4D3A78), // Deep purple
      secondaryColor: const Color(0xFF8A6FC4), // Medium purple
      gravity: 7.5, // Lower gravity
      hasAetherEnhancement: true,
      ambientSoundtrack: 'ambient/aether.mp3',
      particleEffects: <String>['aether_motes', 'energy_ripples'],
      environmentalHazards: <String>['unstable_ground', 'energy_surge'],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF4D3A78), // Deep purple
        const Color(0xFF8A6FC4), // Medium purple
        const Color(0xFFA17DE6), // Light purple
        const Color(0xFFD9C2FF), // Pale purple
      ]);
  }

  /// Create a Ruins biome instance
  factory Biome.ruins() {
    return Biome(
      type: BiomeType.ruins,
      name: 'Forgotten Remnants',
      description: 'Ancient collapsed structures from a bygone civilization.',
      primaryColor: const Color(0xFF8A7359), // Tan
      secondaryColor: const Color(0xFFB3A18F), // Light tan
      ambientSoundtrack: 'ambient/ruins.mp3',
      particleEffects: <String>['dust', 'debris'],
      environmentalHazards: <String>['collapse', 'falling_debris'],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF8A7359), // Tan
        const Color(0xFFB3A18F), // Light tan
        const Color(0xFF52473A), // Dark brown
        const Color(0xFF6F8C72), // Moss green
      ]);
  }

  /// Create a Settlement biome instance
  factory Biome.settlement() {
    return Biome(
      type: BiomeType.settlement,
      name: 'Haven Outskirts',
      description: 'Small communities where survivors gather for safety.',
      primaryColor: const Color(0xFF9C7C5C), // Wood brown
      secondaryColor: const Color(0xFFB8A88E), // Light wood
      ambientSoundtrack: 'ambient/settlement.mp3',
      particleEffects: <String>['smoke', 'embers'],
      environmentalHazards: <String>[],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF9C7C5C), // Wood brown
        const Color(0xFFB8A88E), // Light wood
        const Color(0xFF7C8A95), // Slate (roof)
        const Color(0xFFD9C9AB), // Pale tan (walls)
      ]);
  }

  /// Create a Luminara biome instance
  factory Biome.luminara() {
    return Biome(
      type: BiomeType.luminara,
      name: 'Crystal Spires of Luminara',
      description:
          'Crystalline hub city with floating platforms and Aether-infused architecture.',
      primaryColor: const Color(0xFF87CEEB), // Sky blue
      secondaryColor: const Color(0xFFE6F3FF), // Very light blue
      gravity: 8.5, // Slightly lower gravity due to Aether influence
      hasAetherEnhancement: true,
      ambientSoundtrack: 'ambient/luminara.mp3',
      particleEffects: <String>[
        'aether_particles',
        'crystal_sparkles',
        'floating_light_orbs'
      ],
      environmentalHazards: <String>[],
    )..paletteColors.addAll(<Color>[
        const Color(0xFF87CEEB), // Sky blue
        const Color(0xFFE6F3FF), // Very light blue
        const Color(0xFFADD8E6), // Light blue
        const Color(0xFFB0E0E6), // Powder blue
        const Color(0xFFF0F8FF), // Alice blue
        const Color(0xFFE0FFFF), // Light cyan
      ]);
  }

  /// Create biome instance from BiomeType
  factory Biome.fromType(BiomeType type) {
    switch (type) {
      case BiomeType.forest:
        return Biome.forest();
      case BiomeType.cave:
        return Biome.cave();
      case BiomeType.mountain:
        return Biome.mountain();
      case BiomeType.aetherRealm:
        return Biome.aetherRealm();
      case BiomeType.ruins:
        return Biome.ruins();
      case BiomeType.settlement:
        return Biome.settlement();
      case BiomeType.luminara:
        return Biome.luminara();
    }
  }

  // Basic biome information
  final BiomeType type;
  final String name;
  final String description;

  // Visual theming
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> paletteColors = <Color>[];
  // Parallax backgrounds
  final String? backgroundFar;
  final String? backgroundMid;
  final String? backgroundNear;

  // Environmental settings
  final double? gravity; // Overrides level gravity if set
  final String? ambientSoundtrack;
  final List<String> particleEffects;
  final List<String> environmentalHazards;

  // Biome properties
  final bool hasAetherEnhancement;
  bool hasDarknessEffect = false;
  final double windIntensity;

  /// Get ambient sound for this biome (will be implemented in future sprints)
  AmbientSound? getAmbientSound() {
    if (ambientSoundtrack == null) return null;

    // Implementation will be added in future sprints
    return null;
  }

  /// Apply biome effects to a level (will be implemented in future sprints)
  void applyToLevel(Level level) {
    // Set biome-specific gravity if defined
    if (gravity != null) {
      // Level gravity application will be implemented in future sprints
    }

    // Apply other biome effects
    // Implementation will be added in future sprints
  }
}
