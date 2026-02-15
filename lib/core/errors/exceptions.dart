/// Base class for all exceptions in the data layer.
///
/// These exceptions are caught in the repository layer
/// and converted into [Failure] objects for the domain layer.

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'An unexpected server error occurred',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'An unexpected cache error occurred',
  });

  @override
  String toString() => 'CacheException(message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'No internet connection available',
  });

  @override
  String toString() => 'NetworkException(message: $message)';
}

class AppFirebaseException implements Exception {
  final String message;
  final String? plugin;

  const AppFirebaseException({
    this.message = 'A Firebase error occurred',
    this.plugin,
  });

  @override
  String toString() => 'AppFirebaseException(message: $message, plugin: $plugin)';
}
