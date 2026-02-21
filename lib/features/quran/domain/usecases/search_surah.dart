import '../entities/surah_entity.dart';

/// Search use case — operates on a pre-fetched list (no need for UseCase base).
class SearchSurah {
  /// Filters surah list by query matching namaLatin, arti, or nomor.
  List<SurahEntity> call(List<SurahEntity> surahList, String query) {
    if (query.isEmpty) return surahList;

    final lowerQuery = query.toLowerCase();
    return surahList.where((surah) {
      return surah.namaLatin.toLowerCase().contains(lowerQuery) ||
          surah.arti.toLowerCase().contains(lowerQuery) ||
          surah.nomor.toString().contains(query);
    }).toList();
  }
}
