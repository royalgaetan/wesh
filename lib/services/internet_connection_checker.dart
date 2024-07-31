import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnection {
  static Future<bool> isConnected(context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    log("Has connection : $connectivityResult");
    if (connectivityResult.first != ConnectivityResult.none) {
      return true;
    } else {
      return false;
    }
  }
}
