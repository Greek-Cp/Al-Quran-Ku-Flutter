import 'package:alquran_ku/core/page/page_halaman_utama.dart';
import 'package:alquran_ku/res/colors/list_color.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PageHalamanSplashScreen extends StatefulWidget {
  static String? routeName = "/PageHalamanSplashScreen";

  @override
  State<PageHalamanSplashScreen> createState() =>
      _PageHalamanSplashScreenState();
}

class _PageHalamanSplashScreenState extends State<PageHalamanSplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Get.offAndToNamed(
        PageHalamanUtama.routeName.toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ListColor.gradientTopColor, // #08F4F9
                ListColor.gradientBottomColor
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafeArea(
                child: ComponentTextDescription(
                  "Al-Quran",
                  fontSize: size.sizeTextHeaderGlobal,
                  fontWeight: FontWeight.bold,
                  teksColor: ListColor.warnaTeksPutihGlobal,
                ),
              ),
              SvgPicture.asset(
                "assets/icon/ic_kaligrafi.svg",
                fit: BoxFit.cover,
                width: 300,
                height: 100,
              ),
              SizedBox(
                height: 20,
              ),
              ComponentTextDescription(
                "Baca Al-Quran Dengan Mudah",
                fontSize: size.sizeTextDescriptionGlobal,
                fontWeight: FontWeight.bold,
                teksColor: ListColor.warnaTeksPutihGlobal,
              )
            ],
          ),
        )
      ],
    ));
  }
}
