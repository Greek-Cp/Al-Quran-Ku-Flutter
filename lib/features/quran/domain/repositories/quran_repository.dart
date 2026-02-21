import '../entities/doa_entity.dart';
import '../entities/last_read_entity.dart';
import '../entities/qari_entity.dart';
import '../entities/surah_detail_entity.dart';
import '../entities/surah_entity.dart';

/// Repository contract for all Quran-related data operations.
///
/// The domain layer depends on this contract; the data layer provides
/// the implementation via [QuranRepositoryImpl].
abstract class QuranRepository {
  // ── Surah ──
  Future<List<SurahEntity>> getSurahList();
  Future<SurahDetailEntity> getSurahDetail(int surahNumber);

  // ── Doa ──
  Future<List<DoaEntity>> getDoaList();

  // ── Last Read ──
  Future<LastReadEntity?> getLastRead();
  Future<void> saveLastRead(LastReadEntity data);

  // ── Reading Position ──
  Future<void> saveReadingPosition({
    required int surahNumber,
    required int ayahNumber,
    required double scrollPosition,
  });
  Future<Map<String, dynamic>> getReadingPosition();
  Future<double?> getScrollPosition(int surahNumber);
  Future<void> saveScrollPosition(int surahNumber, double position);

  // ── Qari ──
  Future<void> saveQariSelection(QariEntity qari);
  Future<QariEntity?> getQariSelection();

  // ── Audio ──
  Future<String> resolveAyahAudioSource({
    required String url,
    required bool offlineAllowed,
  });

  // ── Bookmarks ──
  Future<void> toggleBookmark({required int surah, required int ayah});
  Future<List<String>> getBookmarks();
}
