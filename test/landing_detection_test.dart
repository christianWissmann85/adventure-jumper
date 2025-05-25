import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/events/player_events.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.5: Landing Detection Tests', () {
    late PlayerEventBus eventBus;
    late List<PlayerEvent> capturedEvents;

    setUp(() {
      eventBus = PlayerEventBus.instance;
      capturedEvents = [];
      eventBus.clearListeners();
      eventBus.clearHistory();
      eventBus.addListener((event) => capturedEvents.add(event));
    });

    tearDown(() {
      eventBus.clearListeners();
      eventBus.clearHistory();
    });

    test('T2.5.1: Enhanced PhysicsComponent stores collision normal data', () {
      final physics = PhysicsComponent();

      // Test setting landing data
      physics.setLandingData(
        collisionNormal: Vector2(0, -1),
        separationVector: Vector2(0, -5),
        landingVelocity: 150.0,
        landingPosition: Vector2(100, 200),
        platformType: 'solid_platform',
      );

      // Verify data is stored correctly
      expect(physics.lastCollisionNormal, equals(Vector2(0, -1)));
      expect(physics.lastSeparationVector, equals(Vector2(0, -5)));
      expect(physics.lastLandingVelocity, equals(150.0));
      expect(physics.lastLandingPosition, equals(Vector2(100, 200)));
      expect(physics.lastPlatformType, equals('solid_platform'));
    });

    test('T2.5.2: Ground state tracking with justLanded detection', () {
      final physics = PhysicsComponent();

      // Initially not on ground
      expect(physics.isOnGround, isFalse);
      expect(physics.wasOnGround, isFalse);
      expect(physics.justLanded, isFalse);
      expect(physics.justLeftGround, isFalse);

      // Simulate one frame update
      physics.update(0.016);

      // Set on ground
      physics.setOnGround(true);

      // Check landing detection
      expect(physics.isOnGround, isTrue);
      expect(physics.justLanded, isTrue);
      expect(physics.justLeftGround, isFalse);

      // Simulate another frame
      physics.update(0.016);

      // No longer "just landed"
      expect(physics.justLanded, isFalse);
      expect(physics.isOnGround, isTrue);

      // Leave ground
      physics.setOnGround(false);
      expect(physics.justLeftGround, isTrue);
    });

    test('T2.5.3: Landing event system fires events correctly', () async {
      // Create player with physics
      final player = Player(position: Vector2(100, 100));
      await player.onLoad();

      final controller = PlayerController(player);
      player.add(controller);
      await controller.onLoad();

      // Simulate landing by setting up physics state
      player.physics!.velocity.y = 200; // Falling downward
      player.physics!.setOnGround(false);

      // Update to falling state
      controller.update(0.016);

      // Clear any events from setup
      capturedEvents.clear();

      // Simulate landing
      player.physics!.setLandingData(
        collisionNormal: Vector2(0, -1),
        separationVector: Vector2(0, -5),
        landingVelocity: 200.0,
        landingPosition: Vector2(100, 150),
        platformType: 'solid_platform',
      );
      player.physics!.setOnGround(true);

      // Update to trigger landing state transition
      controller.update(0.016);

      // Verify landing event was fired
      expect(capturedEvents.length, greaterThan(0));

      final landingEvents = capturedEvents.whereType<PlayerLandedEvent>();
      expect(landingEvents.length, equals(1));

      final landingEvent = landingEvents.first;
      expect(landingEvent.landingVelocity.y, equals(200.0));
      expect(landingEvent.groundNormal, equals(Vector2(0, -1)));
      expect(landingEvent.platformType, equals('solid_platform'));
    });

    test('T2.5.4: Coyote time allows jumping after leaving ground', () async {
      final player = Player(position: Vector2(100, 100));
      await player.onLoad();

      final controller = PlayerController(player);
      player.add(controller);
      await controller.onLoad();

      // Start on ground
      player.physics!.setOnGround(true);
      controller.update(0.016);

      // Leave ground (walk off platform)
      player.physics!.setOnGround(false);
      player.physics!.velocity.y = 50; // Slightly falling

      // Clear events
      capturedEvents.clear();

      // Update to enter falling state with coyote time
      controller.update(0.016);

      // Should still be able to jump within coyote time
      expect(controller.canPerformJump(), isTrue);
      expect(controller.coyoteTimeRemaining, greaterThan(0));

      // Attempt jump
      final jumpSuccessful = controller.attemptJump();
      expect(jumpSuccessful, isTrue);

      // Verify jump event with coyote flag
      final jumpEvents = capturedEvents.whereType<PlayerJumpedEvent>();
      expect(jumpEvents.length, equals(1));
      expect(jumpEvents.first.isCoyoteJump, isTrue);
    });

    test('T2.5.5: Landing detection works across different platform types', () {
      final physics = PhysicsComponent();

      // Test solid platform
      physics.setLandingData(
        collisionNormal: Vector2(0, -1),
        landingVelocity: 100.0,
        platformType: 'solid_platform',
      );
      expect(physics.lastPlatformType, equals('solid_platform'));

      // Test one-way platform
      physics.setLandingData(
        collisionNormal: Vector2(0, -1),
        landingVelocity: 80.0,
        platformType: 'one_way_platform',
      );
      expect(physics.lastPlatformType, equals('one_way_platform'));

      // Test angled platform (collision normal not straight up)
      physics.setLandingData(
        collisionNormal: Vector2(0.3, -0.7).normalized(),
        landingVelocity: 120.0,
        platformType: 'angled_platform',
      );

      final normal = physics.lastCollisionNormal!;
      expect(normal.x, closeTo(0.3, 0.1));
      expect(normal.y, lessThan(0)); // Pointing generally upward
      expect(physics.lastPlatformType, equals('angled_platform'));
    });

    test('T2.5: Event bus maintains event history', () {
      // Fire multiple events
      final event1 = PlayerLandedEvent(
        timestamp: 1.0,
        landingVelocity: Vector2(0, 100),
        landingPosition: Vector2(0, 0),
        groundNormal: Vector2(0, -1),
      );

      final event2 = PlayerJumpedEvent(
        timestamp: 2.0,
        jumpPosition: Vector2(0, 0),
        jumpForce: 450,
        isFromGround: true,
      );

      eventBus.fireEvent(event1);
      eventBus.fireEvent(event2);

      // Check event history
      final recentLandings = eventBus.getRecentEvents(PlayerEventType.landed);
      expect(recentLandings.length, equals(1));

      final recentJumps = eventBus.getRecentEvents(PlayerEventType.jumped);
      expect(recentJumps.length, equals(1));
    });
  });
}
