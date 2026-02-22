import 'package:alquran_ku/app/routes/app_routes.dart';
import 'package:alquran_ku/features/main/presentation/bindings/main_binding.dart';
import 'package:alquran_ku/features/main/presentation/pages/main_page.dart';
import 'package:alquran_ku/features/onboarding/presentation/bindings/introduction_binding.dart';
import 'package:alquran_ku/features/onboarding/presentation/pages/introduction_page.dart';
import 'package:alquran_ku/features/quran/presentation/bindings/home_binding.dart';
import 'package:alquran_ku/features/quran/presentation/bindings/read_surah_binding.dart';
import 'package:alquran_ku/features/quran/presentation/pages/home_page.dart';
import 'package:alquran_ku/features/quran/presentation/pages/read_surah_page.dart';
import 'package:alquran_ku/features/splash/presentation/bindings/splash_binding.dart';
import 'package:alquran_ku/features/splash/presentation/pages/splash_page.dart';
import 'package:get/get.dart';

/// Centralized GetX route pages with bindings.
class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroductionPage(),
      binding: IntroductionBinding(),
    ),
    GetPage(
      name: AppRoutes.mainPage,
      page: () => const MainPage(),
      bindings: [
        MainBinding(),
        HomeBinding(), // Load HomeBinding here since HomePage is a tab in MainPage
      ],
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding:
          MainBinding(), // Changed to MainBinding as it controls the main view
    ),
    GetPage(
      name: AppRoutes.readSurah,
      page: () => const ReadSurahPage(),
      binding: ReadSurahBinding(),
    ),
  ];
}
