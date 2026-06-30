import 'package:flutter/foundation.dart';

class Urls {
  static const String apiUrlDev = 'http://27.116.52.24:8060';
  static const String apiUrlProd = 'http://27.116.52.24:8160';

  static String get baseUrl => kReleaseMode ? apiUrlProd : apiUrlDev;

  static String endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalizedPath';
  }

  static String get mainDomain => '$baseUrl/';
  static String get getItems => endpoint('/getData/');
}
