import 'dart:developer' as developer;

import '../interfaces/movement_request.dart';

/// Priority-based request queue for movement coordination.
///
/// This queue manages movement requests per entity, ensuring:
/// - Priority-based ordering (higher priority processed first)
/// - FIFO ordering within same priority level
/// - Automatic expiration of old requests
/// - Memory-efficient queue management
///
/// Part of PHY-2.3.2: Request processing pipeline implementation
class RequestQueue {
  /// Separate priority queues for each entity
  final Map<int, PriorityQueue<MovementRequest>> _entityQueues = {};

  /// Maximum queue size per entity
  final int maxQueueSize;

  /// Request timeout in milliseconds
  final int requestTimeoutMs;

  /// Statistics tracking
  int _totalEnqueued = 0;
  int _totalDequeued = 0;
  int _totalExpired = 0;
  int _totalOverflow = 0;

  RequestQueue({
    this.maxQueueSize = 10,
    this.requestTimeoutMs = 100,
  });

  /// Enqueue a movement request for processing.
  ///
  /// Requests are ordered by priority, with higher priority requests
  /// processed first. Within the same priority, earlier requests are
  /// processed first (FIFO).
  ///
  /// **Returns:** true if request was enqueued, false if rejected
  bool enqueue(MovementRequest request) {
    // Validate request before queuing
    if (!request.isValid) {
      developer.log(
        'Rejected invalid request for entity ${request.entityId}',
        name: 'RequestQueue',
      );
      return false;
    }

    // Check if request has already expired
    if (request.isExpired(requestTimeoutMs)) {
      developer.log(
        'Rejected expired request for entity ${request.entityId} (age: ${request.ageInMilliseconds}ms)',
        name: 'RequestQueue',
      );
      _totalExpired++;
      return false;
    }

    // Get or create priority queue for entity
    final queue = _entityQueues.putIfAbsent(
      request.entityId,
      () => PriorityQueue<MovementRequest>(_compareRequests),
    );

    // Check queue size limit
    if (queue.length >= maxQueueSize) {
      // Remove lowest priority (or oldest if same priority) request
      final removed = _removeLeastImportant(queue);
      if (removed != null) {
        _totalOverflow++;
        developer.log(
          'Queue overflow for entity ${request.entityId} - removed ${removed.type} request',
          name: 'RequestQueue',
        );
      }
    }

    // Enqueue the request
    queue.add(request);
    _totalEnqueued++;

    developer.log(
      'Enqueued ${request.type} request for entity ${request.entityId} (priority: ${request.priority}, queue size: ${queue.length})',
      name: 'RequestQueue',
    );

    return true;
  }

  /// Dequeue the highest priority request for processing.
  ///
  /// **Returns:** Next request to process, or null if queue is empty
  MovementRequest? dequeue() {
    // Clean expired requests first
    _cleanExpiredRequests();

    // Find entity with highest priority request
    MovementRequest? highestPriority;
    int? highestPriorityEntityId;

    for (final entry in _entityQueues.entries) {
      if (entry.value.isEmpty) continue;

      final topRequest = entry.value.first;
      if (highestPriority == null ||
          _compareRequests(topRequest, highestPriority) < 0) {
        highestPriority = topRequest;
        highestPriorityEntityId = entry.key;
      }
    }

    if (highestPriority != null && highestPriorityEntityId != null) {
      final queue = _entityQueues[highestPriorityEntityId]!;
      queue.removeFirst();
      _totalDequeued++;

      // Clean up empty queue
      if (queue.isEmpty) {
        _entityQueues.remove(highestPriorityEntityId);
      }

      developer.log(
        'Dequeued ${highestPriority.type} request for entity $highestPriorityEntityId',
        name: 'RequestQueue',
      );

      return highestPriority;
    }

    return null;
  }

  /// Get all queued requests for a specific entity.
  ///
  /// **Returns:** List of requests ordered by priority
  List<MovementRequest> getRequestsForEntity(int entityId) {
    final queue = _entityQueues[entityId];
    if (queue == null) return [];

    // Clean expired requests first
    _cleanExpiredRequestsForEntity(entityId);

    return queue.toList();
  }

  /// Peek at the next request without removing it.
  ///
  /// **Returns:** Next request that would be dequeued, or null if empty
  MovementRequest? peek() {
    // Clean expired requests first
    _cleanExpiredRequests();

    MovementRequest? highestPriority;

    for (final queue in _entityQueues.values) {
      if (queue.isEmpty) continue;

      final topRequest = queue.first;
      if (highestPriority == null ||
          _compareRequests(topRequest, highestPriority) < 0) {
        highestPriority = topRequest;
      }
    }

    return highestPriority;
  }

  /// Clear all requests for a specific entity.
  void clearEntity(int entityId) {
    final removed = _entityQueues.remove(entityId);
    if (removed != null && removed.length > 0) {
      developer.log(
        'Cleared ${removed.length} requests for entity $entityId',
        name: 'RequestQueue',
      );
    }
  }

  /// Clear all requests in the queue.
  void clear() {
    final totalCleared =
        _entityQueues.values.fold(0, (sum, queue) => sum + queue.length);

    _entityQueues.clear();

    if (totalCleared > 0) {
      developer.log(
        'Cleared all queues ($totalCleared total requests)',
        name: 'RequestQueue',
      );
    }
  }

  /// Get total number of queued requests across all entities.
  int get length =>
      _entityQueues.values.fold(0, (sum, queue) => sum + queue.length);

  /// Check if queue is empty.
  bool get isEmpty =>
      _entityQueues.isEmpty ||
      _entityQueues.values.every((queue) => queue.isEmpty);

  /// Get queue statistics.
  Map<String, int> get statistics => {
        'totalEnqueued': _totalEnqueued,
        'totalDequeued': _totalDequeued,
        'totalExpired': _totalExpired,
        'totalOverflow': _totalOverflow,
        'currentSize': length,
        'entityCount': _entityQueues.length,
      };

  /// Reset statistics counters.
  void resetStatistics() {
    _totalEnqueued = 0;
    _totalDequeued = 0;
    _totalExpired = 0;
    _totalOverflow = 0;
  }

  /// Compare requests for priority ordering.
  ///
  /// Returns negative if a has higher priority than b.
  int _compareRequests(MovementRequest a, MovementRequest b) {
    // First compare by priority level (higher priority first)
    final priorityDiff = b.priority.index - a.priority.index;
    if (priorityDiff != 0) return priorityDiff;

    // Same priority - compare by timestamp (earlier first)
    return a.timestamp.compareTo(b.timestamp);
  }

  /// Remove the least important request from a queue.
  MovementRequest? _removeLeastImportant(PriorityQueue<MovementRequest> queue) {
    if (queue.isEmpty) return null;

    // Convert to list to find least important
    final requests = queue.toList();

    // Find request with lowest priority (highest index) and latest timestamp
    MovementRequest? leastImportant;
    for (final request in requests) {
      if (leastImportant == null ||
          _compareRequests(request, leastImportant) > 0) {
        leastImportant = request;
      }
    }

    if (leastImportant != null) {
      queue.remove(leastImportant);
    }

    return leastImportant;
  }

  /// Clean expired requests from all queues.
  void _cleanExpiredRequests() {
    final entitiesToClean = List<int>.from(_entityQueues.keys);

    for (final entityId in entitiesToClean) {
      _cleanExpiredRequestsForEntity(entityId);
    }
  }

  /// Clean expired requests for a specific entity.
  void _cleanExpiredRequestsForEntity(int entityId) {
    final queue = _entityQueues[entityId];
    if (queue == null) return;

    final expiredRequests = <MovementRequest>[];

    // Find expired requests
    for (final request in queue.toList()) {
      if (request.isExpired(requestTimeoutMs)) {
        expiredRequests.add(request);
      }
    }

    // Remove expired requests
    for (final expired in expiredRequests) {
      queue.remove(expired);
      _totalExpired++;
    }

    if (expiredRequests.isNotEmpty) {
      developer.log(
        'Removed ${expiredRequests.length} expired requests for entity $entityId',
        name: 'RequestQueue',
      );
    }

    // Clean up empty queue
    if (queue.isEmpty) {
      _entityQueues.remove(entityId);
    }
  }
}

/// Priority queue implementation for movement requests.
///
/// Uses a binary heap for efficient priority-based operations.
class PriorityQueue<T> {
  final List<T> _heap = [];
  final Comparator<T> _comparator;

  PriorityQueue(this._comparator);

  /// Add an element to the queue.
  void add(T element) {
    _heap.add(element);
    _bubbleUp(_heap.length - 1);
  }

  /// Remove and return the highest priority element.
  T removeFirst() {
    if (_heap.isEmpty) {
      throw StateError('Cannot remove from empty queue');
    }

    final first = _heap[0];
    final last = _heap.removeLast();

    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _bubbleDown(0);
    }

    return first;
  }

  /// Remove a specific element from the queue.
  bool remove(T element) {
    final index = _heap.indexOf(element);
    if (index == -1) return false;

    final last = _heap.removeLast();
    if (index < _heap.length) {
      _heap[index] = last;
      _bubbleUp(index);
      _bubbleDown(index);
    }

    return true;
  }

  /// Check if the queue is not empty.
  bool get isNotEmpty => _heap.isNotEmpty;

  /// Get the highest priority element without removing it.
  T get first {
    if (_heap.isEmpty) {
      throw StateError('Queue is empty');
    }
    return _heap[0];
  }

  /// Check if queue is empty.
  bool get isEmpty => _heap.isEmpty;

  /// Get number of elements in queue.
  int get length => _heap.length;

  /// Convert queue to list (ordered by priority).
  List<T> toList() {
    final result = <T>[];
    final tempHeap = List<T>.from(_heap);
    final tempQueue = PriorityQueue<T>(_comparator);
    tempQueue._heap.addAll(tempHeap);

    while (tempQueue.isNotEmpty) {
      result.add(tempQueue.removeFirst());
    }

    return result;
  }

  /// Bubble up element at index to maintain heap property.
  void _bubbleUp(int index) {
    while (index > 0) {
      final parentIndex = (index - 1) ~/ 2;

      if (_comparator(_heap[index], _heap[parentIndex]) >= 0) {
        break;
      }

      // Swap with parent
      final temp = _heap[index];
      _heap[index] = _heap[parentIndex];
      _heap[parentIndex] = temp;

      index = parentIndex;
    }
  }

  /// Bubble down element at index to maintain heap property.
  void _bubbleDown(int index) {
    while (true) {
      final leftChild = 2 * index + 1;
      final rightChild = 2 * index + 2;
      var smallest = index;

      if (leftChild < _heap.length &&
          _comparator(_heap[leftChild], _heap[smallest]) < 0) {
        smallest = leftChild;
      }

      if (rightChild < _heap.length &&
          _comparator(_heap[rightChild], _heap[smallest]) < 0) {
        smallest = rightChild;
      }

      if (smallest == index) break;

      // Swap with smallest child
      final temp = _heap[index];
      _heap[index] = _heap[smallest];
      _heap[smallest] = temp;

      index = smallest;
    }
  }
}
