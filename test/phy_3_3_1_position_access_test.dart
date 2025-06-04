import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_coordinator.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock physics coordinator for testing position access refactor
class MockPhysicsCoordinator extends Mock implements IPhysicsCoordinator {}

void main() {
  group('PHY-3.3.1: Player Position Access Refactor Tests', () {
    late Player player;
    late MockPhysicsCoordinator mockCoordinator;

    setUp(() {
      player = Player(position: Vector2(100, 200));
      mockCoordinator = MockPhysicsCoordinator();
    });

    group('Direct Position Access Validation', () {
      test('Legacy playerPosition getter returns fallback position', () {
        // Access legacy getter - should trigger validation (printed to console)
        final position = player.playerPosition;

        // Verify position is returned (fallback behavior)
        expect(position, equals(Vector2(100, 200)));
      });

      test('getPlayerPosition without coordinator falls back with validation',
          () async {
        // Call new async method without coordinator
        final position = await player.getPlayerPosition();

        // Verify fallback position is returned
        expect(position, equals(Vector2(100, 200)));
      });
    });

    group('Physics Coordinator Integration', () {
      test('setPhysicsCoordinator properly injects coordinator', () {
        // Inject physics coordinator
        player.setPhysicsCoordinator(mockCoordinator);

        // Test succeeds if no exception is thrown
        // Injection message is printed to console
      });

      test('getPlayerPosition uses coordinator when available', () async {
        // Setup mock coordinator to return specific position
        final mockPosition = Vector2(150, 250);
        when(() => mockCoordinator.getPosition(any()))
            .thenAnswer((_) async => mockPosition);

        // Inject coordinator
        player.setPhysicsCoordinator(mockCoordinator);

        // Call position getter
        final position = await player.getPlayerPosition();

        // Verify coordinator was called and position returned
        expect(position, equals(mockPosition));
        verify(() => mockCoordinator.getPosition(any())).called(1);
      });

      test('getPhysicsVelocity uses coordinator when available', () async {
        // Setup mock coordinator
        final mockVelocity = Vector2(50, -100);
        when(() => mockCoordinator.getVelocity(any()))
            .thenAnswer((_) async => mockVelocity);

        // Inject coordinator
        player.setPhysicsCoordinator(mockCoordinator);

        // Call velocity getter
        final velocity = await player.getPhysicsVelocity();

        // Verify coordinator was called and velocity returned
        expect(velocity, equals(mockVelocity));
        verify(() => mockCoordinator.getVelocity(any())).called(1);
      });

      test('getPhysicsGroundedState uses coordinator when available', () async {
        // Setup mock coordinator
        when(() => mockCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);

        // Inject coordinator
        player.setPhysicsCoordinator(mockCoordinator);

        // Call grounded state getter
        final isGrounded = await player.getPhysicsGroundedState();

        // Verify coordinator was called and state returned
        expect(isGrounded, isTrue);
        verify(() => mockCoordinator.isGrounded(any())).called(1);
      });
    });

    group('Fallback Behavior', () {
      test('Physics queries work without coordinator (fallback mode)',
          () async {
        // Test fallback behavior without coordinator injection

        // Position should fall back to direct access
        final position = await player.getPlayerPosition();
        expect(position, equals(Vector2(100, 200)));

        // Velocity should fall back to physics component or zero
        final velocity = await player.getPhysicsVelocity();
        expect(
          velocity,
          equals(Vector2.zero()),
        ); // Default when no physics component

        // Grounded state should fall back to physics component or false
        final isGrounded = await player.getPhysicsGroundedState();
        expect(isGrounded, isFalse); // Default when no physics component
      });
    });

    group('Position Ownership Enforcement', () {
      test('Direct position access patterns are identified', () {
        // Access legacy getter - validation warnings printed to console
        final position = player.playerPosition;

        // Verify position is still accessible (for backward compatibility)
        expect(position, equals(Vector2(100, 200)));

        // Note: In a production system, validation would be logged
        // to a proper logging framework for monitoring unauthorized access
      });

      test('Physics coordinator methods provide proper abstraction', () async {
        // Setup mock coordinator
        final mockPosition = Vector2(300, 400);
        when(() => mockCoordinator.getPosition(any()))
            .thenAnswer((_) async => mockPosition);

        // Inject coordinator
        player.setPhysicsCoordinator(mockCoordinator);

        // Verify all physics queries go through coordinator
        final physicsPosition = await player.getPhysicsPosition();
        final playerPosition = await player.getPlayerPosition();

        expect(physicsPosition, equals(mockPosition));
        expect(playerPosition, equals(mockPosition));

        // Verify coordinator was called for both methods
        verify(() => mockCoordinator.getPosition(any())).called(2);
      });
    });

    group('Integration Requirements', () {
      test('Player can be used without breaking existing functionality', () {
        // Verify that existing functionality still works
        expect(player.isAlive, isTrue);
        expect(player.id, equals('player'));
        expect(player.type, equals('player'));

        // Legacy position access still works (with validation warnings)
        final position = player.playerPosition;
        expect(position, equals(Vector2(100, 200)));
      });

      test('New async position methods are available', () async {
        // Verify new async methods are available and functional
        final position = await player.getPlayerPosition();
        final velocity = await player.getPhysicsVelocity();
        final isGrounded = await player.getPhysicsGroundedState();

        expect(position, isA<Vector2>());
        expect(velocity, isA<Vector2>());
        expect(isGrounded, isA<bool>());
      });
    });
  });
}
