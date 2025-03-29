import 'dart:convert';
import 'package:alquran_ku/core/page/page_halaman_baca.dart';
import 'package:alquran_ku/core/page/page_halaman_utama.dart';
import 'package:alquran_ku/model/data_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import your model classes like Juz, DetailSurat, Doa, API as well

// Placeholder for ControllerHalamanUtama for backward compatibility

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
