import '../entities/surah_entity.dart';

/// Filters surah list by revelation place (Mekah / Madinah / Semua).
class FilterSurahByRevelationPlace {
  List<SurahEntity> call(List<SurahEntity> surahList, String place) {
    if (place == 'Semua') return surahList;
    return surahList.where((s) => s.tempatTurun == place).toList();
  }
}
