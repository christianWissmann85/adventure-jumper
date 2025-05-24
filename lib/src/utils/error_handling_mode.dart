/// Defines error handling behavior for utility operations
///
/// This enum provides clear semantics for how errors should be handled
/// in utility methods instead of relying on boolean flags.
enum ErrorHandlingMode {
  /// Suppress the exception and return a fallback value
  /// The operation will not throw and instead return null, false,
  /// or another appropriate fallback value
  suppressAndReturnFallback,

  /// Rethrow the exception after logging
  /// The operation will log the error and then rethrow the exception
  rethrowAfterLogging,
}
