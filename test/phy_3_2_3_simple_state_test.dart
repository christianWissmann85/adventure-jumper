import 'package:adventure_jumper/src/systems/interfaces/movement_request.dart';
import 'package:adventure_jumper/src/systems/interfaces/player_movement_request.dart';
import 'package:adventure_jumper/src/systems/interfaces/respawn_state.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PHY-3.2.3 Simple State Management Tests', () {
    test('retry mechanism creates retry request with fallback speed', () {
      // Test the retry request creation directly
      final originalRequest = PlayerMovementRequest.playerWalk(
        entityId: 123,
        direction: Vector2(1, 0),
        speed: 200.0,
        previousAction: PlayerAction.idle,
        isInputSequence: false,
      );
      
      final retryRequest = originalRequest.createRetryRequest(
        additionalErrorContext: {
          'originalFailure': 'blocked',
          'attemptTime': DateTime.now().toIso8601String(),
        },
      );
      
      // Verify retry properties
      expect(retryRequest.retryCount, 1);
      expect(retryRequest.magnitude, 150.0); // 75% of 200
      expect(retryRequest.retrySpeed, retryRequest.magnitude * retryRequest.fallbackSpeedMultiplier); // Should be 112.5
      expect(retryRequest.errorContext?['retryAttempt'], 1);
      expect(retryRequest.errorContext?['originalSpeed'], 200.0);
      expect(retryRequest.errorContext?['originalFailure'], 'blocked');
    });
    
    test('respawn state contains necessary reset flags', () {
      // Test RespawnState creation
      final respawnState = RespawnState.outOfBounds(
        lastSafePosition: Vector2(100, 300),
        metadata: {
          'fallPosition': Vector2(100, 1500).toString(),
          'timestamp': DateTime.now().toIso8601String(),
          'reason': 'fell_out_of_bounds',
        },
      );
      
      // Verify respawn state properties
      expect(respawnState.spawnPosition, Vector2(100, 300));
      expect(respawnState.spawnVelocity, Vector2.zero());
      expect(respawnState.resetPhysicsAccumulation, true);
      expect(respawnState.respawnReason, 'out_of_bounds');
      expect(respawnState.isSafeRespawn, true);
      expect(respawnState.metadata?['reason'], 'fell_out_of_bounds');
    });
    
    test('rapid input detection calculates correct frequency', () {
      // Test rapid input detection
      final request1 = PlayerMovementRequest.playerWalk(
        entityId: 123,
        direction: Vector2(1, 0),
        speed: 200.0,
        previousAction: PlayerAction.idle,
        isInputSequence: false,
      );
      
      // Simulate rapid input by creating another request quickly
      final request2 = PlayerMovementRequest.playerWalk(
        entityId: 123,
        direction: Vector2(1, 0),
        speed: 200.0,
        previousAction: PlayerAction.walk,
        isInputSequence: true,
        previousRequestTime: request1.timestamp,
      );
      
      // The frequency should be high if requests are close together
      expect(request2.isInputSequence, true);
      expect(request2.isRapidInput, false); // Depends on actual time difference
      
      // Create a request with known rapid timing
      final now = DateTime.now();
      final rapidRequest = PlayerMovementRequest(
        entityId: 123,
        action: PlayerAction.walk,
        type: MovementType.walk,
        direction: Vector2(1, 0),
        magnitude: 200.0,
        previousRequestTime: now.subtract(Duration(milliseconds: 40)), // 25 Hz
      );
      
      expect(rapidRequest.requestFrequency, greaterThan(20.0));
      expect(rapidRequest.isRapidInput, true);
    });
    
    test('player movement request validation works correctly', () {
      // Valid request
      final validRequest = PlayerMovementRequest.playerWalk(
        entityId: 123,
        direction: Vector2(1, 0),
        speed: 200.0,
        previousAction: PlayerAction.idle,
      );
      expect(validRequest.isValid, true);
      
      // Invalid: jump while crouching
      final invalidRequest = PlayerMovementRequest.playerJump(
        entityId: 123,
        force: 300.0,
        previousAction: PlayerAction.crouch,
      );
      expect(invalidRequest.isValid, false);
      
      // Invalid: dash with no direction
      final invalidDash = PlayerMovementRequest.playerDash(
        entityId: 123,
        direction: Vector2.zero(),
        distance: 150.0,
      );
      expect(invalidDash.isValid, false);
    });
    
    test('respawn state factories create correct configurations', () {
      // Death respawn
      final deathRespawn = RespawnState.deathRespawn(
        spawnPosition: Vector2(100, 200),
        deathReason: 'fell_into_void',
      );
      expect(deathRespawn.resetPhysicsAccumulation, true);
      expect(deathRespawn.isSafeRespawn, false);
      expect(deathRespawn.respawnReason, 'fell_into_void');
      
      // Checkpoint respawn
      final checkpointRespawn = RespawnState.checkpointRespawn(
        checkpointPosition: Vector2(200, 300),
      );
      expect(checkpointRespawn.resetPhysicsAccumulation, true);
      expect(checkpointRespawn.isSafeRespawn, true);
      expect(checkpointRespawn.respawnReason, 'checkpoint');
    });
  });
}