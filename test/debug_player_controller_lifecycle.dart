// Debug test to isolate PlayerController lifecycle issue

import 'dart:developer' as developer;

import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal test to check if PlayerController lifecycle works when added directly to game
class LifecycleTestGame extends FlameGame {
  late Player player;
  late PlayerController directController;

  @override
  Future<void> onLoad() async {
    // Test 1: Add PlayerController directly to game (not through Player)
    player = Player(
      position: Vector2(100, 100),
      size: Vector2(32, 48),
    );

    directController = PlayerController(player);
    add(directController); // Add directly to game, bypass Player entity

    developer.log(
      'LifecycleTestGame.onLoad() completed',
      name: 'LifecycleTestGame',
    );
  }
}

void main() {
  group('PlayerController Lifecycle Debug Tests', () {
    testWithGame<LifecycleTestGame>(
      'Direct PlayerController lifecycle test',
      () => LifecycleTestGame(),
      (game) async {
        print('=== DIRECT CONTROLLER TEST ===');

        // Let a few update cycles pass
        for (int i = 0; i < 3; i++) {
          print('Update cycle ${i + 1}');
          game.update(0.016);
        }

        // Test input action
        print('Testing handleInputAction...');
        game.directController.handleInputAction('move_right', true);

        // More update cycles
        for (int i = 0; i < 3; i++) {
          print('Update cycle after input ${i + 1}');
          game.update(0.016);
        }

        print('=== TEST COMPLETED ===');
        expect(game.directController, isNotNull);
      },
    );
  });
}
