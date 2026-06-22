abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // TODO: Replace with connectivity_plus when real offline handling is needed.
    return true;
  }
}
