import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnection {
  Future<bool> isConnected(context) async {
    var hasInternet = await InternetConnectionChecker().hasConnection;

    debugPrint("Has connection : $hasInternet");
    return hasInternet;
  }
}
