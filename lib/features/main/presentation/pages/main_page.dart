import 'dart:ui';
import 'package:alquran_ku/core/theme/app_colors.dart';
import 'package:alquran_ku/features/main/presentation/controllers/main_controller.dart';
import 'package:alquran_ku/features/quran/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends GetView<MainController> {
  static const String routeName = '/MainPage';

  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to go behind bottom nav
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              _buildPlaceholder(
                  'Bacaan Hari Ini', Icons.chrome_reader_mode_outlined),
              _buildPlaceholder('Jadwal Sholat', Icons.access_time),
              const HomePage(), // Tab 3: Al Quran feature
            ],
          )),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgGradient1, AppColors.bgGradient2],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white.withAlpha(50)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Akan Segera Hadir',
              style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Obx(() {
      final currentIndex = controller.selectedIndex.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withAlpha(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF25294A).withAlpha(200),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withAlpha(15),
                    Colors.white.withAlpha(5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.chrome_reader_mode_outlined, 'Bacaan',
                      currentIndex),
                  _buildNavItem(1, Icons.access_time_filled_outlined, 'Sholat',
                      currentIndex),
                  _buildNavItem(2, Icons.menu_book, 'Al Quran', currentIndex),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, int currentIndex) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1089FF).withAlpha(40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF32A0FF)
                  : Colors.white.withAlpha(150),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF32A0FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
