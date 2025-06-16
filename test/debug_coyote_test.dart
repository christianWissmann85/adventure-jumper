import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debug coyote time behavior', () async {
    final player = Player(position: Vector2(100, 100));
    await player.onLoad();

    final controller = PlayerController(player);
    player.add(controller);
    await controller.onLoad();

    print('Initial state:');
    print('  isOnGround: ${player.physics!.isOnGround}');
    print('  jumpState: ${controller.jumpState}');
    print('  coyoteTimeRemaining: ${controller.coyoteTimeRemaining}');
    print('  canPerformJump: ${await controller.canPerformJump()}');

    // Start on ground
    player.physics!.setOnGround(true);
    controller.update(0.016);

    print('\nAfter setting on ground and update:');
    print('  isOnGround: ${player.physics!.isOnGround}');
    print('  jumpState: ${controller.jumpState}');
    print('  coyoteTimeRemaining: ${controller.coyoteTimeRemaining}');
    print(
      '  canPerformJump: ${await controller.canPerformJump()}',
    ); // Leave ground (walk off platform)
    player.physics!.setOnGround(false);
    player.physics!.velocity.y = 50; // Slightly falling

    print('\nAfter leaving ground (before update):');
    print('  isOnGround: ${player.physics!.isOnGround}');
    print('  velocity.y: ${player.physics!.velocity.y}');
    print('  jumpState: ${controller.jumpState}');
    print('  coyoteTimeRemaining: ${controller.coyoteTimeRemaining}');

    // Update to enter falling state with coyote time
    controller.update(0.016);

    // Wait for microtasks to complete
    await Future.delayed(Duration.zero);

    print('\nAfter update (should have coyote time):');
    print('  isOnGround: ${player.physics!.isOnGround}');
    print('  velocity.y: ${player.physics!.velocity.y}');
    print('  jumpState: ${controller.jumpState}');
    print('  coyoteTimeRemaining: ${controller.coyoteTimeRemaining}');
    print('  canPerformJump: ${await controller.canPerformJump()}');

    // This is what the test expects
    expect(await controller.canPerformJump(), isTrue);
    expect(controller.coyoteTimeRemaining, greaterThan(0));
  });
}
