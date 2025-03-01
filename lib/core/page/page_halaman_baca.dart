import 'package:alquran_ku/core/widget/button/button_back.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:alquran_ku/model/model_qori.dart';
import 'package:alquran_ku/model/model_surat_alfatihah.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/model_surat.dart';
import '../../res/colors/list_color.dart';
import '../controller/controller_halaman_utama.dart';

class PageHalamanBaca extends StatefulWidget {
  static String? routeName = "/PageHalamanBaca";

  @override
  State<PageHalamanBaca> createState() => _PageHalamanBacaState();
}

class _PageHalamanBacaState extends State<PageHalamanBaca>
    with TickerProviderStateMixin {
  int selectedIndex = 1;
  List<ModelQori> listQori = [
    ModelQori("Abdullah Al Juhhany", "assets/icon/syeikh_1.png", "01"),
    ModelQori("Abdullah Muhsin Al Qasim", "assets/icon/syeikh_2.png", "02"),
    ModelQori("Abdurrahman as Sudais", "assets/icon/syeikh_3.png", "03"),
    ModelQori("Ibrahim-Al-Dossari", "assets/icon/syeikh_4.png", "04"),
    ModelQori("Misyari Rasyid Al-'Afasi", "assets/icon/syeikh_5.png", "05")
  ];
  String qoriSelected = "01";
  final controller = Get.put(ControllerHalamanUtama());
  late AudioPlayer audioPlayer;
  late Source audioUrl;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    audioPlayer = AudioPlayer();

    return Scaffold(
      body: Container(
          child: Stack(children: [
        Image.asset(
          "assets/icon/ic_background_baca.png",
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Container(
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: size.sizeSymetricMarginPage),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonBack(
                            () {
                              Navigator.of(context).pop();
                              audioPlayer.stop();
                            },
                            isArrowLeft: true,
                          ),
                          Column(
                            children: [
                              ComponentTextDescription(
                                controller.namaSuratLatin.value,
                                fontSize: size.sizeTextHeaderGlobal,
                                fontWeight: FontWeight.bold,
                                teksColor: Colors.white,
                              ),
                              ComponentTextDescription(
                                controller.arti.value,
                                fontSize: size.sizeTextDescriptionGlobal,
                                fontWeight: FontWeight.w500,
                                teksColor: Colors.white,
                              ),
                            ],
                          ),
                          Card(
                            elevation: 2,
                            color: ListColor.warnaNonPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ComponentTextDescription(
                                controller.namaArab.value,
                                teksColor: ListColor.warnaTeksPutihGlobal,
                                fontSize: size.sizeTextDescriptionGlobal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: size.sizeSymetricMarginPage),
                      child: ComponentTextDescription(
                        "Qari Bacaan",
                        fontSize: size.sizeTextDescriptionGlobal,
                        fontWeight: FontWeight.bold,
                        teksColor: ListColor.warnaTeksPutihGlobal,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              listQori.length,
                              (index) => buildItem(
                                  index,
                                  listQori[index].nameQori!,
                                  listQori[index].gambarQori!,
                                  listQori[index].idQori!),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ComponentTextDescription(
                        " بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْم ",
                        fontSize: size.sizeTextHeaderGlobal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.sizeSymetricMarginPage),
                        child: ComponentTextDescription(
                          "Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang",
                          fontSize: size.sizeTextDescriptionGlobal,
                          teksColor: ListColor.warnaTeksHitamGlobal,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (controller.getPilihSurat == 1)
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.sizeSymetricMarginPage),
                        child: FutureBuilder<DetailSuratAlFatihah>(
                          future: ControllerHalamanUtama
                              .fetchDataDetailSuratAlFatihah(noSurat: "1"),
                          builder: (context, snapshot) {
                            print("${snapshot.error} error");
                            print("${snapshot.data} data");

                            if (snapshot.hasData) {
                              DetailSuratAlFatihah? detailSurat = snapshot.data;
                              List<AyatAlFatihah>? listAyat =
                                  detailSurat!.data!.ayat;

                              if (listAyat != null) {
                                listAyat.removeAt(0);
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: detailSurat.data!.ayat!.length,
                                itemBuilder: (context, index) {
                                  String? urlSuaraBacaan;

                                  switch (qoriSelected) {
                                    case "01":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s01
                                          .toString();
                                      break;
                                    case "02":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s02
                                          .toString();
                                      break;
                                    case "03":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s03
                                          .toString();
                                      break;
                                    case "04":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s04
                                          .toString();
                                      break;
                                    case "05":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s05
                                          .toString();
                                      break;
                                  }

                                  return WidgetSurat(
                                    nomorAyat: index.toString(),
                                    arti: listAyat![index].teksIndonesia,
                                    ayat: listAyat![index].teksArab,
                                    latin: listAyat![index].teksLatin,
                                    urlSuaraBacaan: urlSuaraBacaan,
                                  );
                                },
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      )
                    else
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.sizeSymetricMarginPage),
                        child: FutureBuilder<DetailSurat>(
                          future: ControllerHalamanUtama.fetchDataDetailSurat(
                              noSurat: controller.getPilihSurat.toString()),
                          builder: (context, snapshot) {
                            print("${snapshot.error} error");
                            print("${snapshot.data} data");

                            if (snapshot.hasData) {
                              DetailSurat? detailSurat = snapshot.data;
                              List<Ayat>? listAyat = detailSurat!.data!.ayat;

                              if (listAyat != null) {
                                listAyat.removeAt(0);
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: detailSurat.data!.ayat!.length,
                                itemBuilder: (context, index) {
                                  String? urlSuaraBacaan;
                                  switch (qoriSelected) {
                                    case "01":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s01
                                          .toString();
                                      break;
                                    case "02":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s02
                                          .toString();
                                      break;
                                    case "03":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s03
                                          .toString();
                                      break;
                                    case "04":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s04
                                          .toString();
                                      break;
                                    case "05":
                                      urlSuaraBacaan = listAyat![index]
                                          .audio!
                                          .s05
                                          .toString();
                                      break;
                                  }

                                  return WidgetSurat(
                                    nomorAyat: index.toString(),
                                    arti: listAyat![index].teksIndonesia,
                                    ayat: listAyat![index].teksArab,
                                    latin: listAyat![index].teksLatin,
                                    urlSuaraBacaan: urlSuaraBacaan,
                                  );
                                },
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      )
                  ]),
            ),
          ),
        ),
      ])),
    );
  }

  Widget WidgetSurat(
      {String? nomorAyat,
      String? ayat,
      String? latin,
      String? arti,
      String? urlSuaraBacaan}) {
    bool isPlay = false;
    late AnimationController animationControllerPlayButton;
    animationControllerPlayButton =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Color.fromARGB(235, 246, 241, 251),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ListColor.warnaNonPrimary,
                    child: ComponentTextDescription(
                      "${int.parse(nomorAyat.toString()) + 1}",
                      fontSize: size.sizeTextDescriptionGlobal,
                    ),
                  ),
                  Expanded(child: Container()),
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                    ),
                    onPressed: () {},
                    color: ListColor.warnaNonPrimary,
                  ),
                  GestureDetector(
                    key: ValueKey(nomorAyat),
                    onTap: () async {
                      if (isPlay == false) {
                        isPlay = true;
                        audioUrl = UrlSource(urlSuaraBacaan.toString());
                        audioPlayer.play(audioUrl);
                        animationControllerPlayButton.forward();
                        audioPlayer.onPlayerComplete.listen((event) {
                          audioPlayer.stop();
                          animationControllerPlayButton.reverse();
                        });
                        audioPlayer.onPlayerStateChanged.listen((event) {
                          if (event == PlayerState.stopped) {
                            animationControllerPlayButton.reverse();
                          } else if (event == PlayerState.paused) {
                            animationControllerPlayButton.reverse();
                          }
                        });
                      } else if (isPlay == true) {
                        isPlay = false;
                        audioPlayer.pause();
                        animationControllerPlayButton.reverse();
                      }
                    },
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: animationControllerPlayButton,
                      color: ListColor.warnaNonPrimary,
                    ),
                  ),
                  Icon(Icons.bookmark_outline, color: ListColor.warnaNonPrimary)
                ],
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: Align(
              alignment: Alignment.centerRight,
              child: ComponentTextDescription(
                "${ayat}",
                fontSize: size.sizeTextDescriptionGlobal,
                fontWeight: FontWeight.bold,
              )),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: ComponentTextDescription(
                "${latin}",
                fontSize: size.sizeTextDescriptionGlobal,
                maxLines: 4,
              ),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Container(
            child: Align(
                alignment: Alignment.topLeft,
                child: ComponentTextDescription(
                  "${arti}",
                  fontSize: size.sizeTextDescriptionGlobal,
                  maxLines: 4,
                  teksColor: ListColor.warnaTeksGrayGlobal,
                )),
          ),
        ),
      ],
    );
  }

  Widget buildItem(
      int index, String namaQori, String gambarQori, String idQori) {
    double width = selectedIndex == index
        ? 90
        : 70; // Mengubah lebar berdasarkan apakah item terpilih
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          qoriSelected = idQori;
          audioPlayer.stop();
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300), // durasi animasi
        curve: Curves.easeOut, // jenis animasi
        width: width, // lebar yang akan diubah
        margin: EdgeInsets.all(9),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: selectedIndex != index
                ? Border.all(width: 0, color: Colors.transparent)
                : Border.all(color: ListColor.selectedColor, width: 5),
            boxShadow: selectedIndex == index
                ? [
                    BoxShadow(
                      color: ListColor.selectedColor.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ]
                : null),
        child: Column(
          children: [
            Image.asset(
              "${gambarQori}",
            ),
            ComponentTextDescription(
              "$namaQori",
              fontWeight: FontWeight.w500,
              fontSize: size.sizeTextDescriptionGlobal - 4,
              teksColor: selectedIndex == index
                  ? ListColor.selectedColor
                  : ListColor.warnaTeksHitamGlobal,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
