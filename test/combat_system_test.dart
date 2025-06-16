import 'package:flutter_test/flutter_test.dart';
import 'package:adventure_jumper/src/systems/combat_system.dart';
import 'package:adventure_jumper/src/components/health_component.dart';
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/player/player.dart'; // Using Player as a concrete Entity
// import 'package:adventure_jumper/src/entities/entity.dart'; // Likely unused if Player is consistently typed
// import 'package:flame_forge2d/flame_forge2d.dart'; // Removed, not used and target doesn't exist
import 'package:adventure_jumper/src/systems/interfaces/collision_notifier.dart' show SurfaceMaterial;
import 'package:flame/game.dart'; // For FlameGame if needed for world context

// Using FlameGame directly for tests, or FlameGameTester if more control is needed.

// Helper to create a basic test Player entity with Health and Physics components
Player createTestPlayer({
  Vector2? position,
  double currentHealth = 100.0,
  double maxHealth = 100.0,
  bool isStaticPhysics = false,
  // SurfaceMaterial groundMaterial = SurfaceMaterial.none, // We'll address this for surface tests
}) {
  // Player constructor might have specific required parameters.
  // Assuming a simple Player constructor for now, or one that matches your actual Player class.
  // If Player() takes named 'position', use it. Otherwise, set after creation.
  final player = Player(position: position ?? Vector2.zero()); 

  player.add(HealthComponent(currentHealth: currentHealth, maxHealth: maxHealth));
  final physics = PhysicsComponent(
    isStatic: isStaticPhysics,
    mass: 1.0,
    friction: 0.5,
    restitution: 0.5, // Corresponds to bounciness
  );
  // For surface material tests, we'll need a way to set this on PhysicsComponent
  // e.g., physics.setOnGround(true, groundMaterial: groundMaterial);
  player.add(physics);
  return player;
}

void main() {
  group('CombatSystem Tests', () {
    late CombatSystem combatSystem;
    late Player attacker;
    late Player target;
    late FlameGame game; // Use FlameGame directly or FlameGameTester

    setUp(() async { 
      game = FlameGame(); // Fresh game instance for each test
      // Ensure the game is 'mounted' for certain operations if needed, though ensureAdd handles onLoad.
      // game.onGameResize(Vector2.all(100)); // Example if size is needed

      combatSystem = CombatSystem();
      // CombatSystem is not a Flame Component, so it's not added to the game tree.
      // It will be used directly.

      attacker = createTestPlayer(position: Vector2(0, 0));
      target = createTestPlayer(position: Vector2(50, 0));

      await game.add(attacker);
      await game.add(target);

      // Add entities to the CombatSystem so it's aware of them
      combatSystem.addEntity(attacker);
      combatSystem.addEntity(target);
      
      game.update(0); // Initial update to process additions and onLoads
    });

    // --- Knockback Tests --- 
    test('target should receive knockback when damaged with knockbackMagnitude', () {
      final targetPhysics = target.children.whereType<PhysicsComponent>().first;
      final initialVelocity = targetPhysics.velocity.clone();

      combatSystem.processAttack(
        attacker, // Positional: attacker
        Vector2(1,0), // Positional: direction (dummy)
        100.0, // Positional: range
        10.0, // Positional: damage
        attackType: 'melee',
        knockbackMagnitude: 100.0,
        knockbackDirection: Vector2(1, 0), // Explicit knockback direction
      );
      game.update(0.01); // Allow physics system (if any) or component updates to process 

      expect(targetPhysics.velocity.x, greaterThan(initialVelocity.x), reason: 'Target should be knocked back (positive X direction)');
      expect(targetPhysics.velocity.y, equals(initialVelocity.y), reason: 'Knockback should be primarily horizontal in this setup');
    });

    test('knockback direction should be away from attacker', () {
      attacker.position.setValues(100,0); 
      target.position.setValues(50,0);
      // PhysicsComponent should use parent's (Entity) position. Update game to ensure states are synced.
      game.update(0); 

      final targetPhysics = target.children.whereType<PhysicsComponent>().first;
      final initialVelocityAway = targetPhysics.velocity.clone();

      combatSystem.processAttack(
        attacker, 
        Vector2(-1,0), // Dummy direction, actual direction is calculated inside processDamage from positions
        100.0, // Range
        10.0, // Damage
        attackType: 'melee',
        knockbackMagnitude: 100.0,
        knockbackDirection: Vector2(-1, 0), // Explicit knockback direction
      );
      game.update(0.01);

      expect(targetPhysics.velocity.x, lessThan(initialVelocityAway.x), reason: 'Target should be knocked back (negative X direction)');
    });

    test('no knockback if knockbackMagnitude is zero or null', () {
      final targetPhysics = target.children.whereType<PhysicsComponent>().first;
      targetPhysics.velocity.setZero(); // Ensure velocity is zero before test
      final initialVelocity = targetPhysics.velocity.clone();

      combatSystem.processAttack(
        attacker, 
        Vector2(1,0), 
        50.0, 
        10.0, 
        attackType: 'melee',
        knockbackMagnitude: 0.0,
      );
      game.update(0.01);
      expect(targetPhysics.velocity, equals(initialVelocity), reason: 'Velocity should not change with zero knockback');

      targetPhysics.velocity.setZero(); 

      combatSystem.processAttack(
        attacker, 
        Vector2(1,0), 
        50.0, 
        10.0, 
        attackType: 'melee',
        knockbackMagnitude: null, 
      );
      game.update(0.01);
      expect(targetPhysics.velocity, equals(initialVelocity), reason: 'Velocity should not change with null knockback');
    });

    test('static entities should not receive knockback', () async {
      final staticTarget = createTestPlayer(position: Vector2(100,0), isStaticPhysics: true);
      await game.add(staticTarget); 
      game.update(0); 

      final targetPhysics = staticTarget.children.whereType<PhysicsComponent>().first;
      final initialVelocity = targetPhysics.velocity.clone(); 

      combatSystem.processAttack(
        attacker, 
        Vector2(1,0), 
        50.0, 
        10.0, 
        attackType: 'melee',
        knockbackMagnitude: 100.0,
      );
      game.update(0.01);

      expect(targetPhysics.velocity, equals(initialVelocity), reason: 'Static entity velocity should not change');
    });

    // TODO: Add tests for knockback direction with custom knockbackDirection parameter

    group('Surface Material Damage Multiplier Tests', () {
      late HealthComponent targetHealth;

      setUp(() {
        // Ensure targetHealth is fetched in each test or here if it's always the same target
        targetHealth = target.children.whereType<HealthComponent>().first;
      });

      test('electric damage on water surface should be multiplied', () {
        final physics = target.children.whereType<PhysicsComponent>().first;
        physics.setOnGround(true, groundMaterial: SurfaceMaterial.water);
        final initialHealth = targetHealth.currentHealth;

        combatSystem.processAttack(attacker, Vector2(1, 0), 100, 10, attackType: 'electric');
        game.update(0.01); // Allow updates to process

        const baseDamage = 10;
        const electricOnWaterMultiplier = 1.5;
        const expectedDamage = baseDamage * electricOnWaterMultiplier;
        expect(targetHealth.currentHealth, initialHealth - expectedDamage,
            reason: 'Electric damage on water should be multiplied by $electricOnWaterMultiplier',);
      });

      test('fire damage on grass surface should be multiplied', () {
        final physics = target.children.whereType<PhysicsComponent>().first;
        physics.setOnGround(true, groundMaterial: SurfaceMaterial.grass);
        final initialHealth = targetHealth.currentHealth;

        combatSystem.processAttack(attacker, Vector2(1, 0), 100, 10, attackType: 'fire');
        game.update(0.01);

        const baseDamage = 10;
        const fireOnGrassMultiplier = 1.25;
        const expectedDamage = baseDamage * fireOnGrassMultiplier;
        expect(targetHealth.currentHealth, initialHealth - expectedDamage,
            reason: 'Fire damage on grass should be multiplied by $fireOnGrassMultiplier',);
      });

      test('fire damage on stone surface should not be multiplied', () {
        final physics = target.children.whereType<PhysicsComponent>().first;
        physics.setOnGround(true, groundMaterial: SurfaceMaterial.stone);
        final initialHealth = targetHealth.currentHealth;

        combatSystem.processAttack(attacker, Vector2(1, 0), 100, 10, attackType: 'fire');
        game.update(0.01);

        const expectedDamage = 10; // No multiplier
        expect(targetHealth.currentHealth, initialHealth - expectedDamage,
            reason: 'Fire damage on stone should not receive a multiplier',);
      });

      test('normal damage on water surface should not be multiplied', () {
        final physics = target.children.whereType<PhysicsComponent>().first;
        physics.setOnGround(true, groundMaterial: SurfaceMaterial.water);
        final initialHealth = targetHealth.currentHealth;

        combatSystem.processAttack(attacker, Vector2(1, 0), 100, 10, attackType: 'normal');
        game.update(0.01);

        const expectedDamage = 10; // No multiplier
        expect(targetHealth.currentHealth, initialHealth - expectedDamage,
            reason: 'Normal damage on water should not receive a multiplier',);
      });

       test('electric damage on no specific surface (SurfaceMaterial.none) should not be multiplied', () {
        final physics = target.children.whereType<PhysicsComponent>().first;
        physics.setOnGround(true, groundMaterial: SurfaceMaterial.none); 
        final initialHealth = targetHealth.currentHealth;

        combatSystem.processAttack(attacker, Vector2(1, 0), 100, 10, attackType: 'electric');
        game.update(0.01);

        const expectedDamage = 10; // No multiplier
        expect(targetHealth.currentHealth, initialHealth - expectedDamage,
            reason: 'Electric damage on SurfaceMaterial.none should not be multiplied',);
      });

      test('electric damage when not on ground should not be multiplied by surface effects', () {
        final physics = target.children.whereType<PhysicsComponent>().first;
        physics.setOnGround(false); 
        final initialHealth = targetHealth.currentHealth;

        combatSystem.processAttack(attacker, Vector2(1, 0), 100, 10, attackType: 'electric');
        game.update(0.01);

        const expectedDamage = 10; // No multiplier
        expect(targetHealth.currentHealth, initialHealth - expectedDamage,
            reason: 'Electric damage when not on ground should not be multiplied by surface effects',);
      });
    });

    // --- Slam Attack Tests --- 
    // TODO: Test slam attack succeeds if attacker airborne
    // TODO: Test slam attack fails if attacker grounded
    // TODO: Test slam attack damages entities in radius
    // TODO: Test slam attack applies knockback

  });
}
