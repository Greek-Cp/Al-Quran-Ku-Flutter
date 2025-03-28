import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:alquran_ku/core/page/page_halaman_baca.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:alquran_ku/model/model_juz.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:alquran_ku/services/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// Placeholder for Doa model (add real implementation based on your app)
class Doa {
  String? id;
  String? doa;
  String? ayat;
  String? latin;
  String? artinya;

  Doa({this.id, this.doa, this.ayat, this.latin, this.artinya});

  Doa.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    doa = json['doa'];
    ayat = json['ayat'];
    latin = json['latin'];
    artinya = json['artinya'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doa'] = this.doa;
    data['ayat'] = this.ayat;
    data['latin'] = this.latin;
    data['artinya'] = this.artinya;
    return data;
  }
}

class Juz {
  int? code;
  String? message;
  List<Data>? data;

  Juz({this.code, this.message, this.data});

  Juz.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? nomor;
  String? nama;
  String? namaLatin;
  int? jumlahAyat;
  String? tempatTurun;
  String? arti;
  String? deskripsi;
  AudioFull? audioFull;

  Data({
    this.nomor,
    this.nama,
    this.namaLatin,
    this.jumlahAyat,
    this.tempatTurun,
    this.arti,
    this.deskripsi,
    this.audioFull,
  });

  Data.fromJson(Map<String, dynamic> json) {
    nomor = json['nomor'];
    nama = json['nama'];
    namaLatin = json['namaLatin'];
    jumlahAyat = json['jumlahAyat'];
    tempatTurun = json['tempatTurun'];
    arti = json['arti'];
    deskripsi = json['deskripsi'];
    audioFull = json['audioFull'] != null
        ? new AudioFull.fromJson(json['audioFull'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomor'] = this.nomor;
    data['nama'] = this.nama;
    data['namaLatin'] = this.namaLatin;
    data['jumlahAyat'] = this.jumlahAyat;
    data['tempatTurun'] = this.tempatTurun;
    data['arti'] = this.arti;
    data['deskripsi'] = this.deskripsi;
    if (this.audioFull != null) {
      data['audioFull'] = this.audioFull!.toJson();
    }
    return data;
  }
}

class AudioFull {
  String? s01;
  String? s02;
  String? s03;
  String? s04;
  String? s05;

  AudioFull({this.s01, this.s02, this.s03, this.s04, this.s05});

  AudioFull.fromJson(Map<String, dynamic> json) {
    s01 = json['01'];
    s02 = json['02'];
    s03 = json['03'];
    s04 = json['04'];
    s05 = json['05'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['01'] = this.s01;
    data['02'] = this.s02;
    data['03'] = this.s03;
    data['04'] = this.s04;
    data['05'] = this.s05;
    return data;
  }
}

// FILE: model_surat.dart
class DetailSurat {
  int? code;
  String? message;
  DataDetailSurat? data;

  DetailSurat({this.code, this.message, this.data});

  DetailSurat.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null
        ? new DataDetailSurat.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DataDetailSurat {
  int? nomor;
  String? nama;
  String? namaLatin;
  int? jumlahAyat;
  String? tempatTurun;
  String? arti;
  String? deskripsi;
  AudioFull? audioFull;
  List<Ayat>? ayat;
  SuratSelanjutnya? suratSelanjutnya;
  SuratSelanjutnya? suratSebelumnya;

  DataDetailSurat(
      {this.nomor,
      this.nama,
      this.namaLatin,
      this.jumlahAyat,
      this.tempatTurun,
      this.arti,
      this.deskripsi,
      this.audioFull,
      this.ayat,
      this.suratSelanjutnya,
      this.suratSebelumnya});

  DataDetailSurat.fromJson(Map<String, dynamic> json) {
    nomor = json['nomor'];
    nama = json['nama'];
    namaLatin = json['namaLatin'];
    jumlahAyat = json['jumlahAyat'];
    tempatTurun = json['tempatTurun'];
    arti = json['arti'];
    deskripsi = json['deskripsi'];
    audioFull = json['audioFull'] != null
        ? new AudioFull.fromJson(json['audioFull'])
        : null;
    if (json['ayat'] != null) {
      ayat = <Ayat>[];
      json['ayat'].forEach((v) {
        ayat!.add(new Ayat.fromJson(v));
      });
    }
    suratSelanjutnya = json['suratSelanjutnya'] != null
        ? new SuratSelanjutnya.fromJson(json['suratSelanjutnya'])
        : null;
    suratSebelumnya = json['suratSebelumnya'] != null
        ? new SuratSelanjutnya.fromJson(json['suratSebelumnya'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomor'] = this.nomor;
    data['nama'] = this.nama;
    data['namaLatin'] = this.namaLatin;
    data['jumlahAyat'] = this.jumlahAyat;
    data['tempatTurun'] = this.tempatTurun;
    data['arti'] = this.arti;
    data['deskripsi'] = this.deskripsi;
    if (this.audioFull != null) {
      data['audioFull'] = this.audioFull!.toJson();
    }
    if (this.ayat != null) {
      data['ayat'] = this.ayat!.map((v) => v.toJson()).toList();
    }
    if (this.suratSelanjutnya != null) {
      data['suratSelanjutnya'] = this.suratSelanjutnya!.toJson();
    }
    if (this.suratSebelumnya != null) {
      data['suratSebelumnya'] = this.suratSebelumnya!.toJson();
    }
    return data;
  }
}

class Ayat {
  int? nomorAyat;
  String? teksArab;
  String? teksLatin;
  String? teksIndonesia;
  Audio? audio;

  Ayat(
      {this.nomorAyat,
      this.teksArab,
      this.teksLatin,
      this.teksIndonesia,
      this.audio});

  Ayat.fromJson(Map<String, dynamic> json) {
    nomorAyat = json['nomorAyat'];
    teksArab = json['teksArab'];
    teksLatin = json['teksLatin'];
    teksIndonesia = json['teksIndonesia'];
    audio = json['audio'] != null ? new Audio.fromJson(json['audio']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomorAyat'] = this.nomorAyat;
    data['teksArab'] = this.teksArab;
    data['teksLatin'] = this.teksLatin;
    data['teksIndonesia'] = this.teksIndonesia;
    if (this.audio != null) {
      data['audio'] = this.audio!.toJson();
    }
    return data;
  }
}

class Audio {
  String? s01;
  String? s02;
  String? s03;
  String? s04;
  String? s05;

  Audio({this.s01, this.s02, this.s03, this.s04, this.s05});

  Audio.fromJson(Map<String, dynamic> json) {
    s01 = json['01'];
    s02 = json['02'];
    s03 = json['03'];
    s04 = json['04'];
    s05 = json['05'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['01'] = this.s01;
    data['02'] = this.s02;
    data['03'] = this.s03;
    data['04'] = this.s04;
    data['05'] = this.s05;
    return data;
  }
}

class SuratSelanjutnya {
  int? nomor;
  String? nama;
  String? namaLatin;
  int? jumlahAyat;

  SuratSelanjutnya({this.nomor, this.nama, this.namaLatin, this.jumlahAyat});

  SuratSelanjutnya.fromJson(Map<String, dynamic> json) {
    nomor = json['nomor'];
    nama = json['nama'];
    namaLatin = json['namaLatin'];
    jumlahAyat = json['jumlahAyat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomor'] = this.nomor;
    data['nama'] = this.nama;
    data['namaLatin'] = this.namaLatin;
    data['jumlahAyat'] = this.jumlahAyat;
    return data;
  }
}

// FILE: model_surat_alfatihah.dart
class DetailSuratAlFatihah {
  int? code;
  String? message;
  DataAlFatihah? data;

  DetailSuratAlFatihah({this.code, this.message, this.data});

  DetailSuratAlFatihah.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data =
        json['data'] != null ? new DataAlFatihah.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DataAlFatihah {
  int? nomor;
  String? nama;
  String? namaLatin;
  int? jumlahAyat;
  String? tempatTurun;
  String? arti;
  String? deskripsi;
  AudioFull? audioFull;
  List<AyatAlFatihah>? ayat;
  SuratSelanjutnya? suratSelanjutnya;
  bool? suratSebelumnya;

  DataAlFatihah(
      {this.nomor,
      this.nama,
      this.namaLatin,
      this.jumlahAyat,
      this.tempatTurun,
      this.arti,
      this.deskripsi,
      this.audioFull,
      this.ayat,
      this.suratSelanjutnya,
      this.suratSebelumnya});

  DataAlFatihah.fromJson(Map<String, dynamic> json) {
    nomor = json['nomor'];
    nama = json['nama'];
    namaLatin = json['namaLatin'];
    jumlahAyat = json['jumlahAyat'];
    tempatTurun = json['tempatTurun'];
    arti = json['arti'];
    deskripsi = json['deskripsi'];
    audioFull = json['audioFull'] != null
        ? new AudioFull.fromJson(json['audioFull'])
        : null;
    if (json['ayat'] != null) {
      ayat = <AyatAlFatihah>[];
      json['ayat'].forEach((v) {
        ayat!.add(new AyatAlFatihah.fromJson(v));
      });
    }
    suratSelanjutnya = json['suratSelanjutnya'] != null
        ? new SuratSelanjutnya.fromJson(json['suratSelanjutnya'])
        : null;
    suratSebelumnya = json['suratSebelumnya'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomor'] = this.nomor;
    data['nama'] = this.nama;
    data['namaLatin'] = this.namaLatin;
    data['jumlahAyat'] = this.jumlahAyat;
    data['tempatTurun'] = this.tempatTurun;
    data['arti'] = this.arti;
    data['deskripsi'] = this.deskripsi;
    if (this.audioFull != null) {
      data['audioFull'] = this.audioFull!.toJson();
    }
    if (this.ayat != null) {
      data['ayat'] = this.ayat!.map((v) => v.toJson()).toList();
    }
    if (this.suratSelanjutnya != null) {
      data['suratSelanjutnya'] = this.suratSelanjutnya!.toJson();
    }
    data['suratSebelumnya'] = this.suratSebelumnya;
    return data;
  }
}

class AyatAlFatihah {
  int? nomorAyat;
  String? teksArab;
  String? teksLatin;
  String? teksIndonesia;
  Audio? audio;

  AyatAlFatihah(
      {this.nomorAyat,
      this.teksArab,
      this.teksLatin,
      this.teksIndonesia,
      this.audio});

  AyatAlFatihah.fromJson(Map<String, dynamic> json) {
    nomorAyat = json['nomorAyat'];
    teksArab = json['teksArab'];
    teksLatin = json['teksLatin'];
    teksIndonesia = json['teksIndonesia'];
    audio = json['audio'] != null ? new Audio.fromJson(json['audio']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomorAyat'] = this.nomorAyat;
    data['teksArab'] = this.teksArab;
    data['teksLatin'] = this.teksLatin;
    data['teksIndonesia'] = this.teksIndonesia;
    if (this.audio != null) {
      data['audio'] = this.audio!.toJson();
    }
    return data;
  }
}

// FILE: model_qori.dart
class ModelQori {
  String? nameQori;
  String? gambarQori;
  String? idQori;

  ModelQori(this.nameQori, this.gambarQori, this.idQori);
}

// FILE: api.dart (for reference)
class API {
  static const String BASE_POINT_SURAT = "https://equran.id/api/v2/surat";
  static const String BASE_POINT_DETAIL_SURAT =
      "https://equran.id/api/v2/surat/";
  static const String BASE_POINT_DOA =
      "https://doa-doa-api-ahmadramadhan.fly.dev/api";
  static const String BASE_POINT_TAFSIR = "https://equran.id/api/v2/tafsir/";
}

// FILE: controller_halaman_utama.dart

class QuranController extends GetxController {
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var surahList = <Data>[].obs;
  var filteredSurahList = <Data>[].obs;
  var lastReadSurah = Rxn<Data>();
  var searchQuery = ''.obs;
  var selectedCategory = 'Semua'.obs;

  // For last read
  var nomorSurah = "".obs;
  var namaSuratLatin = "".obs;
  var namaArab = "".obs;
  var arti = "".obs;
  var descBawah = "".obs;
  var selectionSurat = 0.obs;
  var namaSuratDiPilih = "".obs;
  var idSuratDipilih = "".obs;
  var listJuz = Juz().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllSurah();
    loadLastRead();
  }

  int get getPilihSurat => selectionSurat.value;

  void setSelectionSurat(int select) {
    selectionSurat.value = select;
  }

  void setNamaSuratDiPilih(String namaSurat) {
    namaSuratDiPilih.value = namaSurat;
  }

  String get getNamaSurat => namaSuratDiPilih.value;

  // Fetch all surahs with caching
  Future<void> fetchAllSurah() async {
    try {
      isLoading(true);
      hasError(false);

      // Check connection first
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No connection, try to get from cache
        await _getSurahsFromCache();
        return;
      }

      // Check if cache is valid
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getString('surahs_cache_time');

      if (cacheTime != null) {
        final cachedTimeMs = int.tryParse(cacheTime) ?? 0;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final cacheDuration = Duration(hours: 24).inMilliseconds;

        if (currentTime - cachedTimeMs < cacheDuration) {
          // Cache is valid, use it
          bool cacheLoaded = await _getSurahsFromCache();
          if (cacheLoaded) {
            return;
          }
        }
      }

      // Cache not valid or empty, fetch from API
      Uri uri = Uri.parse(API.BASE_POINT_SURAT);
      var responseResult = await http.get(uri);

      if (responseResult.statusCode == 200) {
        Juz juzData = Juz.fromJson(json.decode(responseResult.body));

        if (juzData.data != null && juzData.data!.isNotEmpty) {
          surahList.assignAll(juzData.data!);
          filteredSurahList.assignAll(juzData.data!);
          listJuz.value = juzData;

          // Cache the data
          await _cacheSurahs(responseResult.body);
        } else {
          hasError(true);
          errorMessage.value = 'No data available from server';
        }
      } else {
        // If server returns error, try to get from cache
        bool cacheLoaded = await _getSurahsFromCache();
        if (!cacheLoaded) {
          hasError(true);
          errorMessage.value =
              'Failed to load data from server and no cache available';
        }
      }
    } catch (e) {
      // On error, try to get from cache
      bool cacheLoaded = await _getSurahsFromCache();
      if (!cacheLoaded) {
        hasError(true);
        errorMessage.value = 'Error: $e';
      }
    } finally {
      isLoading(false);
    }
  }

  // Save surahs to cache
  Future<void> _cacheSurahs(String rawData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('surahs_data', rawData);
      await prefs.setString('surahs_cache_time',
          DateTime.now().millisecondsSinceEpoch.toString());
    } catch (e) {
      print('Error caching surah data: $e');
    }
  }

  // Get surahs from cache
  Future<bool> _getSurahsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('surahs_data');

      if (cachedData != null && cachedData.isNotEmpty) {
        Juz juzData = Juz.fromJson(json.decode(cachedData));

        if (juzData.data != null && juzData.data!.isNotEmpty) {
          surahList.assignAll(juzData.data!);
          filteredSurahList.assignAll(juzData.data!);
          listJuz.value = juzData;
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error loading from cache: $e');
      return false;
    }
  }

  // Load last read surah
  Future<void> loadLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nomorSurahValue = prefs.getString('nomor_surah') ?? "";
      final namaSuratLatinValue = prefs.getString('nama_surat_latin') ?? "";
      final namaArabValue = prefs.getString('nama_arab') ?? "";
      final artiValue = prefs.getString('arti') ?? "";
      final descBawahValue = prefs.getString('desc_bawah') ?? "";
      final selectionSuratValue = prefs.getInt('selection_surat') ?? 0;

      nomorSurah.value = nomorSurahValue;
      namaSuratLatin.value = namaSuratLatinValue;
      namaArab.value = namaArabValue;
      arti.value = artiValue;
      descBawah.value = descBawahValue;
      selectionSurat.value = selectionSuratValue;

      // Find the surah in list
      if (selectionSuratValue > 0 && surahList.isNotEmpty) {
        for (var surah in surahList) {
          if (surah.nomor == selectionSuratValue) {
            lastReadSurah.value = surah;
            break;
          }
        }
      }
    } catch (e) {
      print('Error loading last read: $e');
    }
  }

  // Save last read surah
  void setLastRead(Data surah) {
    try {
      nomorSurah.value = surah.nomor.toString();
      namaSuratLatin.value = surah.namaLatin.toString();
      namaArab.value = surah.nama.toString();
      arti.value = surah.arti.toString();
      descBawah.value = "${surah.tempatTurun} • ${surah.jumlahAyat} AYAT";
      selectionSurat.value = surah.nomor!;
      namaSuratDiPilih.value = surah.nama.toString();
      lastReadSurah.value = surah;

      // Save to SharedPreferences
      saveLastReadToPrefs();
    } catch (e) {
      print('Error setting last read: $e');
    }
  }

  // Save to SharedPreferences
  Future<void> saveLastReadToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nomor_surah', nomorSurah.value);
      await prefs.setString('nama_surat_latin', namaSuratLatin.value);
      await prefs.setString('nama_arab', namaArab.value);
      await prefs.setString('arti', arti.value);
      await prefs.setString('desc_bawah', descBawah.value);
      await prefs.setInt('selection_surat', selectionSurat.value);
    } catch (e) {
      print('Error saving to preferences: $e');
    }
  }

  // Search functionality
  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredSurahList.assignAll(surahList);
    } else {
      filteredSurahList.assignAll(
        surahList.where(
          (surah) =>
              surah.namaLatin
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              surah.arti
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              surah.nomor.toString().contains(query),
        ),
      );
    }

    if (selectedCategory.value != 'Semua') {
      filterByCategory(selectedCategory.value);
    }
  }

  // Filter by category (Mekah/Madinah)
  void filterByCategory(String category) {
    selectedCategory.value = category;

    if (category == 'Semua') {
      // Reset to all surahs (but respect search query)
      if (searchQuery.isEmpty) {
        filteredSurahList.assignAll(surahList);
      } else {
        search(searchQuery.value);
      }
    } else {
      // Filter by category
      if (searchQuery.isEmpty) {
        filteredSurahList.assignAll(
          surahList.where((surah) => surah.tempatTurun == category),
        );
      } else {
        filteredSurahList.assignAll(
          surahList.where(
            (surah) =>
                surah.tempatTurun == category &&
                (surah.namaLatin
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    surah.arti
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    surah.nomor.toString().contains(searchQuery.value)),
          ),
        );
      }
    }
  }

  // Static method to fetch surah detail - maintain compatibility
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

  // Doa methods for compatibility
  static Future<List<Doa>> fetchDataDoa() async {
    Uri uri = Uri.parse(API.BASE_POINT_DOA);
    var responseResult = await http.get(uri);
    print(jsonDecode(responseResult.body));
    List<dynamic> jsonResponse = jsonDecode(responseResult.body);
    return jsonResponse.map((data) => Doa.fromJson(data)).toList();
  }
}

class PageHalamanUtama extends StatefulWidget {
  static String? routeName = "/PageHalamanUtama";

  @override
  State<PageHalamanUtama> createState() => _PageHalamanUtamaState();
}

class _PageHalamanUtamaState extends State<PageHalamanUtama>
    with SingleTickerProviderStateMixin {
  int selectedCategory = 0;
  final controller = Get.put(QuranController());

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Colors - Using same colors as Page Halaman Baca for consistency
  final Color bgGradient1 = Color(0xFF0A1931);
  final Color bgGradient2 = Color(0xFF150E56);
  final Color primaryColor = Color(0xFF1089FF);
  final Color accentColor = Color(0xFF4E9AFF);
  final Color highlightColor = Color(0xFF00D2FC);

  @override
  void initState() {
    super.initState();

    // Animation for background
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bgGradient1,
                      bgGradient2,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated circles for subtle background effects
                    Positioned(
                      top: 100 + 20 * _animation.value.abs(),
                      right: 20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [primaryColor, Colors.transparent],
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: -50 + 100 * _animation.value,
                      child: Opacity(
                        opacity: 0.08,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [accentColor, Colors.transparent],
                              stops: [0.2, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30 + 60 * _animation.value.abs(),
                      right: 50,
                      child: Opacity(
                        opacity: 0.07,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [highlightColor, Colors.transparent],
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main Content
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // App Bar with Header
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: ClipRRect(
                  child: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bgGradient1.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: _buildHeader(),
                    ),
                    centerTitle: true,
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              // Last Read
              SliverToBoxAdapter(
                child: _buildLastRead(),
              ),

              // Category Selector
              SliverToBoxAdapter(
                child: _buildCategorySelector(),
              ),

              // Surah List Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Daftar Surah",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Obx(() => Text(
                            "${controller.filteredSurahList.length} Surah",
                            style: TextStyle(
                              fontSize: 14,
                              color: accentColor,
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // Surah List
              Obx(() {
                if (controller.hasError.value) {
                  return SliverToBoxAdapter(child: _buildErrorView());
                }

                if (controller.filteredSurahList.isEmpty &&
                    !controller.isLoading.value) {
                  return SliverToBoxAdapter(child: _buildEmptyView());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = controller.filteredSurahList[index];
                      return _buildSurahCard(surah);
                    },
                    childCount: controller.filteredSurahList.length,
                  ),
                );
              }),

              // Bottom Space
              SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),

          // Loading Indicator
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  // Header with kaligrafi
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Assalamu'alaikum",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Al-Quran",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Baca Al-Quran Dengan Mudah",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: SvgPicture.asset(
              "assets/icon/ic_kaligrafi.svg",
              width: 100,
              height: 100,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Search bar with glassmorphism
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari Surah...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: controller.search,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Last read section
  Widget _buildLastRead() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Terakhir Dibaca",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => controller.nomorSurah.value.isNotEmpty
              ? _buildLastReadCard()
              : _buildNoLastReadCard()),
        ],
      ),
    );
  }

  // Last read card with glassmorphism
  Widget _buildLastReadCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              onTap: () {
                Get.toNamed(PageHalamanBaca.routeName!);
              },
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    // Number Icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          controller.nomorSurah.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.namaSuratLatin.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            controller.arti.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            controller.descBawah.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arabic Name
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        controller.namaArab.value,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // No last read card
  Widget _buildNoLastReadCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  "Belum ada surah yang dibaca",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Category selector
  Widget _buildCategorySelector() {
    List<String> categories = ['Semua', 'Mekah', 'Madinah'];
    List<IconData> icons = [Icons.apps, Icons.mosque, Icons.location_city];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.category, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Kategori",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Obx(() => Row(
                        children: List.generate(
                          categories.length,
                          (index) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.filterByCategory(categories[index]);
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.selectedCategory.value ==
                                          categories[index]
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icons[index],
                                      color:
                                          controller.selectedCategory.value ==
                                                  categories[index]
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      categories[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            controller.selectedCategory.value ==
                                                    categories[index]
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            controller.selectedCategory.value ==
                                                    categories[index]
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Surah card
  Widget _buildSurahCard(Data surah) {
    final bool isMakkiyyah = surah.tempatTurun == 'Mekah';

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              onTap: () {
                controller.setSelectionSurat(surah.nomor!);

                controller.setLastRead(surah);
                Get.toNamed(PageHalamanBaca.routeName!);
              },
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isMakkiyyah
                              ? [Color(0xFF1E88E5), Color(0xFF42A5F5)]
                              : [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isMakkiyyah
                                ? Color(0xFF1E88E5).withOpacity(0.3)
                                : Color(0xFF7B1FA2).withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          surah.nomor.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.namaLatin.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isMakkiyyah
                                      ? Color(0xFF1E88E5).withOpacity(0.2)
                                      : Color(0xFF9C27B0).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isMakkiyyah
                                          ? Icons.mosque
                                          : Icons.location_city,
                                      size: 12,
                                      color: isMakkiyyah
                                          ? Color(0xFF42A5F5)
                                          : Color(0xFFBA68C8),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      surah.tempatTurun.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMakkiyyah
                                            ? Color(0xFF42A5F5)
                                            : Color(0xFFBA68C8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.format_list_numbered,
                                      size: 12,
                                      color: accentColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "${surah.jumlahAyat} Ayat",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: accentColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arabic name
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        surah.nama.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Empty view
  Widget _buildEmptyView() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              "Tidak ada surah yang ditemukan",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error view
  Widget _buildErrorView() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.15),
            Colors.red.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[300],
                size: 50,
              ),
              SizedBox(height: 15),
              Text(
                "Terjadi Kesalahan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.fetchAllSurah(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "Coba Lagi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sliver delegate for search bar
class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverSearchBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: child,
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
