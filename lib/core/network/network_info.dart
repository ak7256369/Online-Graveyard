/// Abstract class for checking network connectivity.
///
/// Implement this with a concrete class that uses
/// a connectivity package (e.g., `connectivity_plus`).
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Concrete implementation of [NetworkInfo].
///
/// Replace the body with actual connectivity checking logic
/// once a connectivity package is added.
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Mock implementation for MVP
    // Example with connectivity_plus:
    // final result = await Connectivity().checkConnectivity();
    // return result != ConnectivityResult.none;
    return true;
  }
}
