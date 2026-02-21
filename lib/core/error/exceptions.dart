/// Thrown when the server returns an error response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(
      {this.message = 'Server error occurred', this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Thrown when a local cache operation fails.
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when there is no internet connection.
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}
