import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information checker
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    // ignore: unnecessary_cast
    if (result is List) {
      return _isConnected((result as List).first);
    }
    return _isConnected(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((result) {
      if (result is List) {
        return _isConnected((result as List).first);
      }
      return _isConnected(result);
    });
  }

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
}
