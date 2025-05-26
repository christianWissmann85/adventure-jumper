// filepath: test/aether_component_integration_test.dart

import 'package:adventure_jumper/src/components/aether_component.dart';
import 'package:adventure_jumper/src/events/player_events.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.8.5: AetherComponent Integration Tests - Player Entity Integration',
      () {
    late Player player;
    late AetherComponent aetherComponent;
    late PlayerEventBus eventBus;
    late FlameGame game;
    List<PlayerEvent> capturedEvents = [];
    setUp(() async {
      // Create a test game to properly mount components
      game = FlameGame();

      player = Player(position: Vector2.zero());

      // Add player to game and wait for onLoad to complete
      await game.add(player);

      // Ensure the game is fully loaded and ready
      await game.onLoad();
      await game.ready();

      // Manually ensure the player has been loaded completely
      // Check if player is loaded and if not, wait
      if (!player.isLoaded) {
        await player.onLoad();
      }

      // Access the aether component after everything is loaded
      aetherComponent = player.aether;

      // Set up event capture for testing event system integration
      eventBus = PlayerEventBus.instance;
      capturedEvents.clear();

      // Capture all events for verification
      eventBus.addListener((event) {
        capturedEvents.add(event);
      });
    });

    tearDown(() {
      capturedEvents.clear();
      eventBus.clearListeners();
    });

    group('Player-AetherComponent Integration', () {
      test('should have AetherComponent properly integrated in Player entity',
          () {
        expect(player.aether, isNotNull);
        expect(player.aether, isA<AetherComponent>());
        expect(player.aether.currentAether, equals(100));
        expect(player.aether.maxAether, equals(100));
        expect(player.aether.aetherPercentage, equals(100));
      });
      test('should handle component mounting within Player entity', () {
        // AetherComponent is created and added to the player in the player.setupEntity method
        // which is called by player.onLoad. This test verifies the component is added properly.

        // Verify that the component is properly connected to the player
        expect(aetherComponent, equals(player.aether));

        // Verify that the component has been properly added to the game hierarchy
        expect(aetherComponent.parent, equals(player));

        // Test that the component is functionally working (which indicates it's properly set up)
        expect(aetherComponent.currentAether, equals(100));
        expect(aetherComponent.maxAether, equals(100));

        // The player should be the parent of the AetherComponent
        expect(player.children.whereType<AetherComponent>().isNotEmpty, isTrue);
      });

      test('should access AetherComponent properties through Player', () {
        expect(aetherComponent.currentAether, equals(100));
        expect(aetherComponent.maxAether, equals(100));
        expect(aetherComponent.aetherPercentage, equals(100));
        // Test that we can activate abilities through basic checks
        expect(
          aetherComponent.hasAbility('dash'),
          isFalse,
        ); // No abilities unlocked by default
      });

      test('should maintain AetherComponent state through Player lifecycle',
          () {
        // Consume some Aether
        aetherComponent.consumeAether(30);
        expect(aetherComponent.currentAether, equals(70));

        // Add Aether back
        aetherComponent.addAether(20);
        expect(aetherComponent.currentAether, equals(90));

        // Change max Aether
        aetherComponent.setMaxAether(150);
        expect(aetherComponent.maxAether, equals(150));
        expect(aetherComponent.currentAether, equals(90));
      });
    });

    group('Event System Integration with Player Entity', () {
      test('should fire AetherChangedEvents when AetherComponent state changes',
          () {
        // Clear any existing events
        capturedEvents.clear();

        // Change Aether and verify event is fired
        final oldAether = aetherComponent.currentAether;
        aetherComponent.consumeAether(25);

        // Should have captured one event
        expect(capturedEvents.length, equals(1));

        // Verify event details
        final event = capturedEvents.first as PlayerAetherChangedEvent;
        expect(event.oldAmount, equals(oldAether.round()));
        expect(event.newAmount, equals(75));
        expect(event.changeAmount, equals(-25));
        expect(event.changeReason, equals('consume_aether'));
      });
      test('should handle Aether addition events correctly', () {
        // Ensure we start with full aether for this test
        aetherComponent.setMaxAether(100);
        aetherComponent.addAether(100); // Fill to max

        // Clear any existing events from the setup
        capturedEvents.clear();

        // Add Aether and verify event is fired
        final oldAether = aetherComponent.currentAether;
        aetherComponent.addAether(10);

        // Should have captured one event
        expect(capturedEvents.length, equals(1));

        // Verify event details
        final event = capturedEvents.first as PlayerAetherChangedEvent;
        expect(event.oldAmount, equals(oldAether.round()));
        expect(event.newAmount, equals(100)); // Capped at max
        expect(event.changeAmount, equals(0)); // No change since already at max
        expect(event.changeReason, equals('add_aether'));
      });
    });

    group('Ability System Integration with Player Entity', () {
      test('should handle ability activation through Player', () {
        // Unlock an ability
        aetherComponent.unlockAbility('dash');
        expect(aetherComponent.hasAbility('dash'), isTrue);

        // Clear any existing events
        capturedEvents.clear();

        // Activate the ability
        final activated = aetherComponent.activateAbility('dash');
        expect(activated, isTrue);

        // Verify Aether was consumed
        expect(
          aetherComponent.currentAether,
          equals(80),
        ); // 100 - 20 (dash cost)

        // Verify ability is active and on cooldown
        expect(aetherComponent.isAbilityActive('dash'), isTrue);
        expect(aetherComponent.isAbilityOnCooldown('dash'), isTrue);

        // Should have captured one event for ability activation
        expect(capturedEvents.length, equals(1));
        final event = capturedEvents.first as PlayerAetherChangedEvent;
        expect(event.changeReason, equals('ability_dash'));
      });

      test('should prevent ability activation without sufficient Aether', () {
        // Unlock an expensive ability
        aetherComponent.unlockAbility('aether_blast');
        expect(aetherComponent.hasAbility('aether_blast'), isTrue);

        // Consume most Aether
        aetherComponent.consumeAether(70);
        expect(aetherComponent.currentAether, equals(30));

        // Try to activate expensive ability (costs 35)
        final activated = aetherComponent.activateAbility('aether_blast');
        expect(activated, isFalse);

        // Verify Aether wasn't consumed
        expect(aetherComponent.currentAether, equals(30));

        // Verify ability is not active
        expect(aetherComponent.isAbilityActive('aether_blast'), isFalse);
      });
    });
  });
}
