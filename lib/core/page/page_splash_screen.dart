import 'package:alquran_ku/core/page/page_halaman_utama.dart';
import 'package:alquran_ku/res/colors/list_color.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:alquran_ku/res/colors/list_color.dart';
import 'package:alquran_ku/core/page/page_halaman_utama.dart';

class PageHalamanSplashScreen extends StatefulWidget {
  static String? routeName = "/PageHalamanSplashScreen";

  @override
  State<PageHalamanSplashScreen> createState() =>
      _PageHalamanSplashScreenState();
}

class _PageHalamanSplashScreenState extends State<PageHalamanSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate to introduction page after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      Get.offAndToNamed(
        PageIntroduction.routeName.toString(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1931),
                  Color(0xFF150E56),
                ],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1089FF).withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4E9AFF).withOpacity(0.1),
              ),
            ),
          ),

          // Content with animations
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        ComponentTextDescription(
                          "Al-Quran",
                          fontSize: size.sizeTextHeaderGlobal,
                          fontWeight: FontWeight.bold,
                          teksColor: ListColor.warnaTeksPutihGlobal,
                        ),

                        // Calligraphy
                        SvgPicture.asset(
                          "assets/icon/ic_kaligrafi.svg",
                          fit: BoxFit.cover,
                          width: 300,
                          height: 100,
                        ),

                        SizedBox(height: 20),

                        // Description
                        ComponentTextDescription(
                          "Baca Al-Quran Dengan Mudah",
                          fontSize: size.sizeTextDescriptionGlobal,
                          fontWeight: FontWeight.bold,
                          teksColor: ListColor.warnaTeksPutihGlobal,
                        ),

                        SizedBox(height: 40),

                        // Loading indicator
                        Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Introduction Page
class PageIntroduction extends StatefulWidget {
  static String? routeName = "/PageIntroduction";

  @override
  State<PageIntroduction> createState() => _PageIntroductionState();
}

class _PageIntroductionState extends State<PageIntroduction> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Introduction data
  final List<IntroItem> _introItems = [
    IntroItem(
      icon: Icons.menu_book_rounded,
      title: "Baca Al-Quran",
      description:
          "Baca Al-Quran kapan saja dan di mana saja dengan tampilan yang nyaman untuk dibaca",
      color: Color(0xFF1089FF),
    ),
    IntroItem(
      icon: Icons.headset_rounded,
      title: "Dengarkan Murattal",
      description:
          "Dengarkan bacaan Al-Quran dari qari-qari ternama dengan suara yang jernih",
      color: Color(0xFF4E9AFF),
    ),
    IntroItem(
      icon: Icons.bookmark_rounded,
      title: "Tandai Ayat Favorit",
      description:
          "Simpan ayat-ayat favorit Anda untuk dibaca kembali dengan mudah",
      color: Color(0xFF00D2FC),
    ),
    IntroItem(
      icon: Icons.travel_explore_rounded,
      title: "Terjemahan & Tafsir",
      description:
          "Pahami makna Al-Quran dengan terjemahan dan tafsir yang komprehensif",
      color: Color(0xFF26C485),
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
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1931),
                  Color(0xFF150E56),
                ],
              ),
            ),
          ),

          // Decorative circles that move with page changes
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: -50 + (_currentPage * 20),
            right: -50 + (_currentPage * 30),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _introItems[_currentPage].color.withOpacity(0.15),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: -100 - (_currentPage * 20),
            left: -70 + (_currentPage * 40),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _introItems[_currentPage].color.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button at the top
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () {
                        Get.offAndToNamed(
                          PageHalamanUtama.routeName.toString(),
                        );
                      },
                      child: Text(
                        "Lewati",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _introItems.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildIntroPage(_introItems[index]);
                    },
                  ),
                ),

                // Navigation dots
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                ),

                // Next or Get Started button
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 50.0, left: 30, right: 30),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _introItems[_currentPage].color,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor:
                            _introItems[_currentPage].color.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage == _introItems.length - 1) {
                          // Last page, go to main page
                          Get.offAndToNamed(
                            PageHalamanUtama.routeName.toString(),
                          );
                        } else {
                          // Go to next page
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _introItems.length - 1
                            ? "Mulai Baca"
                            : "Lanjut",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroPage(IntroItem item) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated container
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 50),

          // Title
          Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 20),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _introItems.length; i++) {
      indicators.add(
        i == _currentPage
            ? _buildPageDot(true, _introItems[i].color)
            : _buildPageDot(false, _introItems[i].color),
      );
    }
    return indicators;
  }

  Widget _buildPageDot(bool isActive, Color color) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: isActive ? 10 : 8,
      width: isActive ? 30 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Model class for intro items
class IntroItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  IntroItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
