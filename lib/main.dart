import 'dart:io';

import 'package:alquran_ku/core/page/page_halaman_baca.dart';
import 'package:alquran_ku/core/page/page_halaman_utama.dart';
import 'package:alquran_ku/core/page/page_splash_screen.dart';
import 'package:alquran_ku/httpovveride.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/page/page_halaman_intro.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      initialRoute: PageHalamanSplashScreen.routeName,
      getPages: [
        GetPage(
            name: PageHalamanSplashScreen.routeName.toString(),
            page: () => PageHalamanSplashScreen(),
            transition: Transition.fadeIn),
        GetPage(
            name: PageIntroduction.routeName.toString(),
            page: () => PageIntroduction(),
            transition: Transition.fadeIn),
        GetPage(
            name: PageHalamanUtama.routeName.toString(),
            page: () => PageHalamanUtama(),
            transition: Transition.leftToRight),
        GetPage(
            name: PageHalamanBaca.routeName.toString(),
            page: () => PageHalamanBaca(),
            transition: Transition.rightToLeft),
      ],
    );
  }
}
