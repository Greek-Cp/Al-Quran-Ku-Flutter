import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Introduction/Onboarding page — migrated from page_halaman_intro.dart.
class IntroductionPage extends StatefulWidget {
  static const String routeName = '/IntroductionPage';

  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_IntroData> _introPages = [
    _IntroData(
      icon: Icons.menu_book_rounded,
      title: 'Baca Al-Quran',
      subtitle: 'Baca Al-Quran kapan saja dan dimana saja dengan mudah',
      gradient: const [Color(0xFF1089FF), Color(0xFF4E9AFF)],
    ),
    _IntroData(
      icon: Icons.headphones,
      title: 'Dengar Murottal',
      subtitle: 'Dengarkan bacaan dari berbagai Qari terkenal dunia',
      gradient: const [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
    ),
    _IntroData(
      icon: Icons.bookmark,
      title: 'Tandai Bacaan',
      subtitle: 'Simpan terakhir baca dan lanjut kapan saja',
      gradient: const [Color(0xFF00897B), Color(0xFF4DB6AC)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1931), Color(0xFF150E56)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Get.offAllNamed('/HomePage'),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _introPages.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) =>
                      _buildPage(_introPages[index]),
                ),
              ),

              // Indicators + button
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicators
                    Row(
                      children: List.generate(
                        _introPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentPage == index ? 30 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFF1089FF)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),

                    // Next/Get Started button
                    GestureDetector(
                      onTap: () {
                        if (_currentPage == _introPages.length - 1) {
                          Get.offAllNamed('/HomePage');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1089FF), Color(0xFF4E9AFF)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1089FF).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _currentPage == _introPages.length - 1
                              ? 'Mulai'
                              : 'Lanjut',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_IntroData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: data.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.gradient[0].withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(data.icon, size: 70, color: Colors.white),
          ),
          const SizedBox(height: 50),
          Text(
            data.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IntroData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  _IntroData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
