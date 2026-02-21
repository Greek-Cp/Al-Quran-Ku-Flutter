import 'package:alquran_ku/features/onboarding/presentation/bindings/introduction_binding.dart';
import 'package:alquran_ku/features/onboarding/presentation/pages/introduction_page.dart';
import 'package:alquran_ku/features/quran/presentation/bindings/home_binding.dart';
import 'package:alquran_ku/features/quran/presentation/bindings/read_surah_binding.dart';
import 'package:alquran_ku/features/quran/presentation/pages/home_page.dart';
import 'package:alquran_ku/features/quran/presentation/pages/read_surah_page.dart';
import 'package:alquran_ku/features/splash/presentation/bindings/splash_binding.dart';
import 'package:alquran_ku/features/splash/presentation/pages/splash_page.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

/// Centralized GetX route pages with bindings.
class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.introduction,
      page: () => const IntroductionPage(),
      binding: IntroductionBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.readSurah,
      page: () => const ReadSurahPage(),
      binding: ReadSurahBinding(),
    ),
  ];
}
