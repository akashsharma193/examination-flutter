import 'package:connectivity_plus/connectivity_plus.dart';

class InternetServiceChecker {
  Future<bool> get isInternetConnected async {
    final results = (await Connectivity().checkConnectivity())
        .where((e) => e != ConnectivityResult.none);

    return results.isNotEmpty;
  }

  Stream<bool> checkIfInternetIsConnected() async* {
    while (true) {
      final isConnected = await isInternetConnected;
      yield isConnected; // Yield the current connection status
      await Future.delayed(const Duration(seconds: 1)); // Check every second
    }
  }
}
