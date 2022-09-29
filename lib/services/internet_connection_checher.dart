import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnection {
  Future<bool> isConnected(context) async {
    var hasInternet = await InternetConnectionChecker().hasConnection;

    print("Has connection : $hasInternet");
    return hasInternet;
  }
}
