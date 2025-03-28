import 'dart:convert';
import 'package:alquran_ku/core/page/page_halaman_baca.dart';
import 'package:alquran_ku/core/page/page_halaman_utama.dart';
import 'package:alquran_ku/model/model_surat_alfatihah.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../model/model_doa.dart';
import '../../model/model_juz.dart';
import '../../model/model_surat.dart';
// Import your model classes like Juz, DetailSurat, Doa, API as well

// Placeholder for ControllerHalamanUtama for backward compatibility
class ControllerHalamanUtama extends GetxController {
  var selectionSurat = 0.obs;
  var namaSuratDiPilih = "".obs;
  var listJuz = Juz().obs;
  var idSuratDipilih = "".obs;
  var arti = "".obs;
  var descBawah = "".obs;
  var namaArab = "".obs;
  var namaSuratLatin = "".obs;
  var nomorSurah = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchDataJuz().then((data) {
      listJuz.value = data;
    });
  }

  int get getPilihSurat => selectionSurat.value;

  void setSelectionSurat(int select) {
    selectionSurat.value = select;
    print("Surat Berhasil Dipilih");
  }

  void setNamaSuratDiPilih(String namaSurat) {
    namaSuratDiPilih.value = namaSurat;
    print("Surat Berhasil Di Set");
  }

  String get getNamaSurat => namaSuratDiPilih.value;

  static Future<Juz> fetchDataJuz() async {
    Uri uri = Uri.parse(API.BASE_POINT_SURAT);
    var responseResult = await http.get(uri);
    return Juz.fromJson(jsonDecode(responseResult.body));
  }

  static Future<DetailSurat> fetchDataDetailSurat({String? noSurat}) async {
    Uri uri = Uri.parse(API.BASE_POINT_DETAIL_SURAT + noSurat.toString());
    print(uri.toString());
    var responseResult = await http.get(uri);
    print("response ${responseResult.body}");
    return DetailSurat.fromJson(jsonDecode(responseResult.body));
  }

  static Future<DetailSuratAlFatihah> fetchDataDetailSuratAlFatihah(
      {String? noSurat}) async {
    Uri uri = Uri.parse(API.BASE_POINT_DETAIL_SURAT + noSurat.toString());
    print(uri.toString());
    var responseResult = await http.get(uri);
    print("response ${responseResult.body}");
    return DetailSuratAlFatihah.fromJson(jsonDecode(responseResult.body));
  }

  static Future<List<Doa>> fetchDataDoa() async {
    Uri uri = Uri.parse(API.BASE_POINT_DOA);
    var responseResult = await http.get(uri);
    print(jsonDecode(responseResult.body));
    List<dynamic> jsonResponse = jsonDecode(responseResult.body);
    return jsonResponse.map((data) => Doa.fromJson(data)).toList();
  }
}
