import 'package:alquran_ku/core/page/page_halaman_intro.dart';
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
