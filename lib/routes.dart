import 'package:flutter/material.dart';
import 'package:tractian/assets/apex.dart';
import 'package:tractian/assets/jaguar.dart';
import 'package:tractian/assets/tobias.dart';
import 'main.dart';

class Routes {
  static const String home = '/';
  static const String apex = '/apex';
  static const String jaguar = '/jaguar';
  static const String tobias = '/tobias';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => MyHomePage(),
      apex: (context) => Apex(),
      jaguar: (context) => Jaguar(),
      tobias: (context) => Tobias()
    };
  }
}