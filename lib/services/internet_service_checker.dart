import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetServiceChecker {
  static const Duration _timeout = Duration(seconds: 3);

  Future<bool> get isInternetConnected async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      if (connectivityResults.contains(ConnectivityResult.mobile) ||
          connectivityResults.contains(ConnectivityResult.wifi) ||
          connectivityResults.contains(ConnectivityResult.ethernet)) {
        return await _hasActiveInternetConnection();
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasActiveInternetConnection() async {
    try {
      final result =
          await InternetAddress.lookup('google.com').timeout(_timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      try {
        final result =
            await InternetAddress.lookup('8.8.8.8').timeout(_timeout);
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
  }

  Stream<bool> checkIfInternetIsConnected() async* {
    while (true) {
      try {
        final isConnected = await isInternetConnected;
        yield isConnected;
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        yield false;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }
}
