/// All SharedPreferences and cache key constants in one place.
class CacheKeys {
  CacheKeys._();

  // ── Surah list cache ──
  static const String surahsData = 'surahs_data';
  static const String surahsCacheTime = 'surahs_cache_time';

  // ── Surah detail cache ──
  static String surahCache(int surahNumber) => 'surah_cache_$surahNumber';
  static String surahCacheTime(int surahNumber) =>
      'surah_cache_time_$surahNumber';

  // ── Last read ──
  static const String lastReadNomorSurah = 'nomor_surah';
  static const String lastReadNamaSuratLatin = 'nama_surat_latin';
  static const String lastReadNamaArab = 'nama_arab';
  static const String lastReadArti = 'arti';
  static const String lastReadDescBawah = 'desc_bawah';
  static const String lastReadSelectionSurat = 'selection_surat';

  // ── Reading position ──
  static const String lastReadSurahKey = 'last_read_surah';
  static const String lastReadAyahKey = 'last_read_ayah';
  static const String lastReadPositionKey = 'last_read_position';
  static String scrollPosition(int surahNumber) =>
      'last_scroll_position_$surahNumber';

  // ── Reading history ──
  static const String readingHistory = 'reading_history';
  static const String lastReadingSession = 'last_reading_session';

  // ── Qari selection ──
  static const String qariSelectionIndex = 'qari_selection_index';
  static const String qariSelectionId = 'qari_selection_id';
  static const String qariSelection = 'qari_selection';
  static String qariSelectionIdLegacy(String key) => '${key}_id';

  // ── Audio cache ──
  static const String quranAudioCache = 'quran_audio_cache';
  static const String quranAudioAccessTimes = 'quran_audio_access_times';
  static const String audioCacheDirName = 'quran_audio_cache';

  // ── Bookmarks ──
  static const String bookmarkedAyahs = 'bookmarked_ayahs';
}
