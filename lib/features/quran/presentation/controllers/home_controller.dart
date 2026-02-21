import 'package:alquran_ku/core/usecase/usecase.dart';
import 'package:alquran_ku/features/quran/domain/entities/last_read_entity.dart';
import 'package:alquran_ku/features/quran/domain/entities/surah_entity.dart';
import 'package:alquran_ku/features/quran/domain/usecases/filter_surah_by_revelation_place.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_last_read.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_surah_list.dart';
import 'package:alquran_ku/features/quran/domain/usecases/save_last_read.dart';
import 'package:alquran_ku/features/quran/domain/usecases/search_surah.dart';
import 'package:get/get.dart';

/// Controller for the home page.
///
/// Uses only domain use cases — no direct HTTP, SharedPreferences, or data layer access.
class HomeController extends GetxController {
  final GetSurahList getSurahListUseCase;
  final GetLastRead getLastReadUseCase;
  final SaveLastRead saveLastReadUseCase;
  final SearchSurah searchSurahUseCase;
  final FilterSurahByRevelationPlace filterSurahUseCase;

  HomeController({
    required this.getSurahListUseCase,
    required this.getLastReadUseCase,
    required this.saveLastReadUseCase,
    required this.searchSurahUseCase,
    required this.filterSurahUseCase,
  });

  // ── Observable state ──
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var surahList = <SurahEntity>[].obs;
  var filteredSurahList = <SurahEntity>[].obs;
  var searchQuery = ''.obs;
  var selectedCategory = 'Semua'.obs;

  // ── Last read ──
  var nomorSurah = ''.obs;
  var namaSuratLatin = ''.obs;
  var namaArab = ''.obs;
  var arti = ''.obs;
  var descBawah = ''.obs;
  var selectionSurat = 0.obs;

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

  // ── Fetch all surahs ──

  Future<void> fetchAllSurah() async {
    try {
      isLoading(true);
      hasError(false);

      final result = await getSurahListUseCase(const NoParams());
      surahList.assignAll(result);
      filteredSurahList.assignAll(result);
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  // ── Load last read ──

  Future<void> loadLastRead() async {
    try {
      final lastRead = await getLastReadUseCase(const NoParams());
      if (lastRead != null) {
        nomorSurah.value = lastRead.surahNumber.toString();
        namaSuratLatin.value = lastRead.surahName;
        namaArab.value = lastRead.arabicName;
        arti.value = lastRead.arti;
        descBawah.value = lastRead.descBawah;
        selectionSurat.value = lastRead.surahNumber;
      }
    } catch (e) {
      // Silently handle — last read is optional
    }
  }

  // ── Save last read ──

  void setLastRead(SurahEntity surah) {
    nomorSurah.value = surah.nomor.toString();
    namaSuratLatin.value = surah.namaLatin;
    namaArab.value = surah.namaArab;
    arti.value = surah.arti;
    descBawah.value = '${surah.tempatTurun} • ${surah.jumlahAyat} AYAT';
    selectionSurat.value = surah.nomor;

    saveLastReadUseCase(LastReadEntity(
      surahNumber: surah.nomor,
      surahName: surah.namaLatin,
      arabicName: surah.namaArab,
      arti: surah.arti,
      descBawah: '${surah.tempatTurun} • ${surah.jumlahAyat} AYAT',
    ));
  }

  // ── Search ──

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // ── Filter by category ──

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void _applyFilters() {
    var result = surahList.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      result = searchSurahUseCase(result, searchQuery.value);
    }

    // Apply category filter
    if (selectedCategory.value != 'Semua') {
      result = filterSurahUseCase(result, selectedCategory.value);
    }

    filteredSurahList.assignAll(result);
  }
}
