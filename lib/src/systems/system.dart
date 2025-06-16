import '../entities/entity.dart';

/// Base system class that all game systems extend
/// Systems process entities with specific components on each update cycle
abstract class System {
  System();

  /// Whether this system is currently active
  bool isActive = true;

  /// Priority for update order (higher values update first)
  int priority = 0;

  /// Process system logic for the current frame
  /// [dt] is the delta time in seconds since the last update
  void update(double dt);

  /// Initialize the system
  void initialize();

  /// Clean up resources when system is no longer needed
  void dispose();

  /// Add an entity to be processed by this system
  void addEntity(Entity entity);

  /// Remove an entity from being processed by this system
  void removeEntity(Entity entity);
}
