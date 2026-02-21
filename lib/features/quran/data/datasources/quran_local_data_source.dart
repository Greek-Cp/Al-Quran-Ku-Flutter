import 'dart:convert';

import 'package:alquran_ku/core/constants/cache_keys.dart';
import 'package:alquran_ku/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/last_read_entity.dart';
import '../../domain/entities/qari_entity.dart';

/// Local data source — handles SharedPreferences operations for
/// last read, reading position, qari selection, surah cache, and bookmarks.
abstract class QuranLocalDataSource {
  // ── Surah list cache ──
  Future<String?> getCachedSurahListRaw();
  Future<void> cacheSurahListRaw(String rawJson);

  // ── Surah detail cache ──
  Future<String?> getCachedSurahDetailRaw(int surahNumber);
  Future<void> cacheSurahDetailRaw(int surahNumber, String rawJson);
  Future<bool> isSurahDetailCacheValid(int surahNumber);

  // ── Last read ──
  Future<LastReadEntity?> getLastRead();
  Future<void> saveLastRead(LastReadEntity data);

  // ── Reading position ──
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

  // ── Bookmarks ──
  Future<void> toggleBookmark({required int surah, required int ayah});
  Future<List<String>> getBookmarks();
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  final SharedPreferences prefs;

  QuranLocalDataSourceImpl({required this.prefs});

  // ────────────── Surah List Cache ──────────────

  @override
  Future<String?> getCachedSurahListRaw() async {
    final cacheTime = prefs.getString(CacheKeys.surahsCacheTime);
    if (cacheTime != null) {
      final cachedTimeMs = int.tryParse(cacheTime) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - cachedTimeMs <
          const Duration(hours: 24).inMilliseconds) {
        return prefs.getString(CacheKeys.surahsData);
      }
    }
    // Return data anyway for offline fallback (even if expired)
    return prefs.getString(CacheKeys.surahsData);
  }

  @override
  Future<void> cacheSurahListRaw(String rawJson) async {
    await prefs.setString(CacheKeys.surahsData, rawJson);
    await prefs.setString(
      CacheKeys.surahsCacheTime,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  // ────────────── Surah Detail Cache ──────────────

  @override
  Future<String?> getCachedSurahDetailRaw(int surahNumber) async {
    return prefs.getString(CacheKeys.surahCache(surahNumber));
  }

  @override
  Future<void> cacheSurahDetailRaw(int surahNumber, String rawJson) async {
    await prefs.setString(CacheKeys.surahCache(surahNumber), rawJson);
    await prefs.setString(
      CacheKeys.surahCacheTime(surahNumber),
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<bool> isSurahDetailCacheValid(int surahNumber) async {
    final cacheTimeStr = prefs.getString(CacheKeys.surahCacheTime(surahNumber));
    if (cacheTimeStr == null) return false;
    final cacheTime = int.tryParse(cacheTimeStr) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - cacheTime) < const Duration(hours: 24).inMilliseconds;
  }

  // ────────────── Last Read ──────────────

  @override
  Future<LastReadEntity?> getLastRead() async {
    final nomorSurah = prefs.getString(CacheKeys.lastReadNomorSurah);
    if (nomorSurah == null || nomorSurah.isEmpty) return null;

    return LastReadEntity(
      surahNumber: int.tryParse(nomorSurah) ?? 0,
      surahName: prefs.getString(CacheKeys.lastReadNamaSuratLatin) ?? '',
      arabicName: prefs.getString(CacheKeys.lastReadNamaArab) ?? '',
      arti: prefs.getString(CacheKeys.lastReadArti) ?? '',
      descBawah: prefs.getString(CacheKeys.lastReadDescBawah) ?? '',
    );
  }

  @override
  Future<void> saveLastRead(LastReadEntity data) async {
    await prefs.setString(
        CacheKeys.lastReadNomorSurah, data.surahNumber.toString());
    await prefs.setString(CacheKeys.lastReadNamaSuratLatin, data.surahName);
    await prefs.setString(CacheKeys.lastReadNamaArab, data.arabicName);
    await prefs.setString(CacheKeys.lastReadArti, data.arti);
    await prefs.setString(CacheKeys.lastReadDescBawah, data.descBawah);
    await prefs.setInt(CacheKeys.lastReadSelectionSurat, data.surahNumber);
  }

  // ────────────── Reading Position ──────────────

  @override
  Future<void> saveReadingPosition({
    required int surahNumber,
    required int ayahNumber,
    required double scrollPosition,
  }) async {
    await prefs.setInt(CacheKeys.lastReadSurahKey, surahNumber);
    await prefs.setInt(CacheKeys.lastReadAyahKey, ayahNumber);
    await prefs.setDouble(CacheKeys.lastReadPositionKey, scrollPosition);
  }

  @override
  Future<Map<String, dynamic>> getReadingPosition() async {
    final surahNumber = prefs.getInt(CacheKeys.lastReadSurahKey);
    final ayahNumber = prefs.getInt(CacheKeys.lastReadAyahKey);
    final scrollPosition = prefs.getDouble(CacheKeys.lastReadPositionKey);

    if (surahNumber != null && ayahNumber != null) {
      return {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'scrollPosition': scrollPosition ?? 0.0,
      };
    }
    return {};
  }

  @override
  Future<double?> getScrollPosition(int surahNumber) async {
    return prefs.getDouble(CacheKeys.scrollPosition(surahNumber));
  }

  @override
  Future<void> saveScrollPosition(int surahNumber, double position) async {
    await prefs.setDouble(CacheKeys.scrollPosition(surahNumber), position);
  }

  // ────────────── Qari Selection ──────────────

  @override
  Future<void> saveQariSelection(QariEntity qari) async {
    await prefs.setString(CacheKeys.qariSelectionId, qari.id);
    // Store index by finding it in the known list
    final index = _qariIds.indexOf(qari.id);
    if (index >= 0) {
      await prefs.setInt(CacheKeys.qariSelectionIndex, index);
    }
  }

  @override
  Future<QariEntity?> getQariSelection() async {
    final qariId = prefs.getString(CacheKeys.qariSelectionId);
    final qariIndex = prefs.getInt(CacheKeys.qariSelectionIndex);

    if (qariId != null && qariIndex != null) {
      return QariEntity(
        id: qariId,
        nama: _qariNames.length > qariIndex ? _qariNames[qariIndex] : '',
        imageAsset:
            _qariImages.length > qariIndex ? _qariImages[qariIndex] : '',
      );
    }
    return null;
  }

  // ────────────── Bookmarks ──────────────

  @override
  Future<void> toggleBookmark({required int surah, required int ayah}) async {
    final bookmarks = await getBookmarks();
    final key = '$surah:$ayah';
    if (bookmarks.contains(key)) {
      bookmarks.remove(key);
    } else {
      bookmarks.add(key);
    }
    await prefs.setStringList(CacheKeys.bookmarkedAyahs, bookmarks);
  }

  @override
  Future<List<String>> getBookmarks() async {
    return prefs.getStringList(CacheKeys.bookmarkedAyahs) ?? [];
  }

  // ── Static qari data for lookup ──
  static const _qariIds = ['01', '02', '03', '04', '05'];
  static const _qariNames = [
    'Abdullah Al Juhhany',
    'Abdullah Muhsin Al Qasim',
    'Abdurrahman as Sudais',
    'Ibrahim-Al-Dossari',
    "Misyari Rasyid Al-'Afasi",
  ];
  static const _qariImages = [
    'assets/icon/syeikh_1.png',
    'assets/icon/syeikh_2.png',
    'assets/icon/syeikh_3.png',
    'assets/icon/syeikh_4.png',
    'assets/icon/syeikh_5.png',
  ];
}
