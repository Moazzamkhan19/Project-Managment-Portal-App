import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
class InternetServices
{
  static Future<bool> checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

}