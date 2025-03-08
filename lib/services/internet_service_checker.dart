import 'package:connectivity_plus/connectivity_plus.dart';

class InternetServiceChecker{

  Future<bool> get isInternetConnected async{
    final results = (await Connectivity().checkConnectivity()).where((e)=>e!=ConnectivityResult.none);

    return results.isNotEmpty;
}
}