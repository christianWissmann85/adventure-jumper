import 'dart:developer' as developer;

import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerController Component Lifecycle', () {
    testWithFlameGame('PlayerController update cycle through Player entity',
        (game) async {
      // Create player entity
      final player = Player(
        position: Vector2(100, 300),
        size: Vector2(32, 48),
      );

      // Add to game and wait for loading
      game.add(player);
      await player.loaded;

      developer.log('=== PLAYER CONTROLLER INTEGRATION TEST ===');
      developer.log(
        'Player children count: ${player.children.length}',
      ); // Find the PlayerController
      PlayerController? controller;
      for (final child in player.children) {
        if (child is PlayerController) {
          controller = child;
          break;
        }
      }

      expect(
        controller,
        isNotNull,
        reason: 'PlayerController should be found in Player children',
      );
      developer.log('PlayerController found: ${controller.runtimeType}');
      developer.log('PlayerController mounted: ${controller!.isMounted}');
      developer.log('PlayerController loaded: ${controller.isLoaded}');

      // Test one update cycle
      developer.log('--- Running update cycle ---');
      game.update(0.016);

      // Test input handling
      developer.log('--- Testing input handling ---');
      controller.handleInputAction('move_right', true);

      // Run several update cycles
      for (int i = 0; i < 5; i++) {
        developer.log('Update cycle ${i + 1}');
        game.update(0.016);
      }

      controller.handleInputAction('move_right', false);

      developer.log('=== TEST COMPLETED ===');
    });
  });
}
