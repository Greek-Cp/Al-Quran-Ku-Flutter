/// Base failure class for domain layer error handling.
abstract class Failure {
  final String message;

  const Failure({required this.message});

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure originating from a server/API error.
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Terjadi kesalahan pada server'});
}

/// Failure originating from a local cache error.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Terjadi kesalahan pada cache lokal'});
}

/// Failure originating from a network connectivity issue.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet'});
}
