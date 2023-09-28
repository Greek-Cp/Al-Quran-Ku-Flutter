import 'dart:ui';

import 'package:alquran_ku/core/page/page_halaman_baca.dart';
import 'package:alquran_ku/core/widget/button/button_back.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:alquran_ku/model/model_doa.dart';
import 'package:alquran_ku/res/colors/list_color.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:alquran_ku/res/style/decoration/decoration_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/model_juz.dart';
import '../controller/controller_halaman_utama.dart';

class PageHalamanUtama extends StatefulWidget {
  static String? routeName = "/PageHalamanUtama";

  @override
  State<PageHalamanUtama> createState() => _PageHalamanUtamaState();
}

class _PageHalamanUtamaState extends State<PageHalamanUtama> {
  int selectedIndex = 0;
  final controller = Get.put(ControllerHalamanUtama());
  late List<Data> listDataJuz;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ControllerHalamanUtama.fetchDataJuz().then((juzData) {
      // Set your controller's value here
      controller.listJuz.value = juzData;
    }).catchError((error) {
      // Handle the error here
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(children: [
        Image.asset(
          "assets/icon/wp_background.png",
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: size.sizeSymetricMarginPage.w),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ComponentTextDescription(
                              "Al-Quran",
                              fontSize: size.sizeTextHeaderGlobal.sp,
                              fontWeight: FontWeight.bold,
                              teksColor: ListColor.warnaTeksPutihGlobal,
                            ),
                            ComponentTextDescription(
                              "Baca Al-Quran Dengan Mudah",
                              fontSize: size.sizeTextDescriptionGlobal.sp,
                              fontWeight: FontWeight.w500,
                              teksColor: ListColor.warnaTeksPutihGlobal,
                              maxLines: 2,
                            )
                          ],
                        ),
                      ),
                      Container(
                        transform: Matrix4.translationValues(0, 20.h, 0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_kaligrafi.svg",
                          fit: BoxFit.cover,
                          width: 110.w,
                          height: 80.h,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ComponentTextDescription(
                        "Terakhir Dibaca",
                        fontSize: size.sizeTextDescriptionGlobal.sp,
                        fontWeight: FontWeight.bold,
                        teksColor: ListColor.warnaTeksPutihGlobal,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Obx(() {
                    return Card(
                      elevation: 5,
                      child: controller.nomorSurah.value == ""
                          ? Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ComponentTextDescription(
                                  "Harap Baca Surah Terlebih Dahulu",
                                  fontSize: size.sizeTextDescriptionGlobal.sp,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(
                                            "assets/icon/ic_ayat.svg"),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                            child: ComponentTextDescription(
                                          controller.nomorSurah.value,
                                          fontSize:
                                              size.sizeTextDescriptionGlobal.sp,
                                        )),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ComponentTextDescription(
                                            controller.namaSuratLatin.value,
                                            fontSize: size
                                                .sizeTextDescriptionGlobal.sp,
                                            teksColor:
                                                ListColor.warnaTeksHitamGlobal,
                                          ),
                                          ComponentTextDescription(
                                            controller.arti.value,
                                            fontSize: size
                                                .sizeTextDescriptionGlobal.sp,
                                            teksColor:
                                                ListColor.warnaTeksGrayGlobal,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 2,
                                    color: ListColor.warnaNonPrimary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ComponentTextDescription(
                                        controller.namaArab.value,
                                        teksColor: Colors.white,
                                        fontSize:
                                            size.sizeTextDescriptionGlobal.sp,
                                      ),
                                    ),
                                  )
                                ]),
                    );
                  }),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ComponentTextDescription(
                        "Kategori",
                        fontSize: size.sizeTextDescriptionGlobal.sp,
                        fontWeight: FontWeight.bold,
                        teksColor: ListColor.warnaTeksPutihGlobal,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      buildItem(0, "Surah"),
                      buildItem(1, "Doa Pendek"),
                    ]),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  if (selectedIndex == 0)
                    FutureBuilder<Juz>(
                      future: ControllerHalamanUtama.fetchDataJuz(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          Juz juzData = snapshot.data!;
                          controller.listJuz.value.data = juzData.data;
                          List<Data>? listData = controller.listJuz.value.data;
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: listData!.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 2375),
                                  child: FadeInAnimation(
                                      child: GestureDetector(
                                    onTap: () {},
                                    child: cardJuz(
                                        noJuz:
                                            listData![index].nomor.toString(),
                                        namaJuz:
                                            listData[index].nama.toString(),
                                        namaLatin: listData[index]
                                            .namaLatin
                                            .toString(),
                                        tempatTurun: listData[index]
                                            .tempatTurun
                                            .toString(),
                                        jumlahAyat: listData[index]
                                            .jumlahAyat
                                            .toString(),
                                        arti: listData[index].arti,
                                        nama: listData[index].nama),
                                  )));
                            },
                          );
                        }
                      },
                    )
                  else
                    FutureBuilder<List<Doa>>(
                        future: ControllerHalamanUtama.fetchDataDoa(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Doa>? listData = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: listData!.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration:
                                        const Duration(milliseconds: 2375),
                                    child: cardDoa(
                                        noDoa: listData[index].id.toString(),
                                        namaDoa: listData[index].doa.toString(),
                                        doaArab: listData[index].ayat,
                                        doaLatin: listData[index].latin));
                              },
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        })
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget cardDoa(
      {String? noDoa, String? namaDoa, String? doaArab, String? doaLatin}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Card(
            elevation: 5.0,
            color: Colors.white,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {},
              splashColor: ListColor.warnaNonPrimary,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Stack(
                    children: [
                      SvgPicture.asset(
                        "assets/icon/ic_ayat.svg",
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            "${noDoa}",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ComponentTextDescription(
                            "${namaDoa}",
                            fontSize: size.sizeTextDescriptionGlobal.sp,
                            fontWeight: FontWeight.normal,
                          ),
                          ComponentTextDescription(
                            "${doaArab}",
                            teksColor: ListColor.warnaTeksGrayGlobal,
                            fontSize: size.sizeTextDescriptionGlobal.sp,
                          ),
                          ComponentTextDescription(
                            "${doaLatin}",
                            fontSize: size.sizeTextDescriptionGlobal.sp,
                            teksColor: ListColor.warnaTeksHitamGlobal,
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cardJuz(
      {String? noJuz,
      String? namaJuz,
      String? tempatTurun,
      String? jumlahAyat,
      String? namaLatin,
      String? arti,
      String? nama}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Card(
            elevation: 2.0,
            color: Colors.white,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                controller.setNamaSuratDiPilih(namaJuz!);
                controller.nomorSurah.value = noJuz!;
                controller.setSelectionSurat(int.parse(noJuz!));
                controller.descBawah.value =
                    "${tempatTurun} * ${jumlahAyat} AYAT";
                controller.arti.value = "$arti";
                controller.namaArab.value = nama!;
                controller.namaSuratLatin.value = namaLatin.toString();
                Get.toNamed(PageHalamanBaca.routeName.toString());
              },
              splashColor: ListColor.warnaNonPrimary,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Stack(
                    children: [
                      SvgPicture.asset(
                        "assets/icon/ic_ayat.svg",
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            "${noJuz}",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ComponentTextDescription(
                          "${namaLatin}",
                          fontSize: size.sizeTextDescriptionGlobal.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        ComponentTextDescription(
                          "${tempatTurun} * ${jumlahAyat} AYAT",
                          teksColor: ListColor.warnaTeksGrayGlobal,
                          fontSize: size.sizeTextDescriptionGlobal.sp,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  ComponentTextDescription(
                    "${namaJuz}",
                    fontSize: size.sizeTextDescriptionGlobal.sp,
                    teksColor: ListColor.warnaTeksHitamGlobal,
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded buildItem(int index, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color:
                selectedIndex == index ? ListColor.selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ComponentTextDescription(
            "$title",
            fontWeight: FontWeight.w500,
            fontSize: size.sizeTextDescriptionGlobal.sp,
            teksColor: selectedIndex == index
                ? ListColor.warnaTeksPutihGlobal
                : ListColor.warnaTeksHitamGlobal,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
