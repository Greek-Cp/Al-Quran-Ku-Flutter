import 'dart:io';

import 'package:alquran_ku/app/app.dart';
import 'package:alquran_ku/core/network/http_override.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = AppHttpOverrides();

  // Pre-initialize SharedPreferences so it's available synchronously
  // in all GetX bindings via Get.find<SharedPreferences>()
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  runApp(const App());
}
