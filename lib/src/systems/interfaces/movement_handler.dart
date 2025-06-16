import 'movement_request.dart';

/// Primary interface for input-movement coordination
///
/// This interface defines the contract for systems that need to handle
/// movement input and coordinate with the movement system through
/// MovementRequest objects.
///
/// Implemented by: InputSystem
/// Used by: MovementSystem, PlayerController
abstract class IMovementHandler {
  // Movement request submission
  Future<bool> submitMovementRequest(MovementRequest request);
  Future<bool> submitMovementSequence(List<MovementRequest> requests);

  // Input validation queries
  Future<bool> canProcessInput(int entityId);
  Future<bool> canProcessMovementType(int entityId, MovementType movementType);

  // Input state coordination
  Future<void> notifyInputProcessed(MovementRequest request);
  Future<void> notifyInputFailed(MovementRequest request, String reason);

  // Buffer management
  void clearInputBuffer(int entityId);
  void setInputBufferEnabled(bool enabled);

  // Error handling
  void onInputProcessingError(String error);
}
