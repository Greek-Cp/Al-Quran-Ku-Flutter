import 'dart:convert';

import 'package:alquran_ku/core/error/exceptions.dart';
import 'package:alquran_ku/core/network/network_info.dart';

import '../../domain/entities/doa_entity.dart';
import '../../domain/entities/last_read_entity.dart';
import '../../domain/entities/qari_entity.dart';
import '../../domain/entities/surah_detail_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_audio_cache_data_source.dart';
import '../datasources/quran_local_data_source.dart';
import '../datasources/quran_remote_data_source.dart';
import '../models/doa_model.dart';
import '../models/surah_detail_model.dart';
import '../models/surah_model.dart';

/// Concrete implementation of [QuranRepository].
///
/// Orchestrates remote/local/audio-cache data sources with network awareness.
class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;
  final QuranLocalDataSource localDataSource;
  final QuranAudioCacheDataSource audioCacheDataSource;
  final NetworkInfo networkInfo;

  QuranRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.audioCacheDataSource,
    required this.networkInfo,
  });

  // ────────────── Surah List ──────────────

  @override
  Future<List<SurahEntity>> getSurahList() async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      // Offline — try cache
      final cachedRaw = await localDataSource.getCachedSurahListRaw();
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        final response = SurahListResponse.fromJson(json.decode(cachedRaw));
        return (response.data ?? []).map((m) => m.toEntity()).toList();
      }
      throw const NetworkException(
          message: 'Tidak ada koneksi internet dan cache kosong');
    }

    // Online — check cache validity first
    final cachedRaw = await localDataSource.getCachedSurahListRaw();
    if (cachedRaw != null && cachedRaw.isNotEmpty) {
      try {
        final response = SurahListResponse.fromJson(json.decode(cachedRaw));
        if (response.data != null && response.data!.isNotEmpty) {
          // Return cached data; refresh in background
          _refreshSurahListInBackground();
          return response.data!.map((m) => m.toEntity()).toList();
        }
      } catch (_) {
        // Cache corrupt, fetch fresh
      }
    }

    // No valid cache, fetch from API
    try {
      final models = await remoteDataSource.getSurahList();
      // Cache the raw JSON
      final rawJson = json.encode({
        'data': models.map((m) => m.toJson()).toList(),
      });
      await localDataSource.cacheSurahListRaw(rawJson);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException {
      // API failed and no cache
      throw const ServerException(message: 'Gagal memuat daftar surah');
    }
  }

  void _refreshSurahListInBackground() async {
    try {
      final models = await remoteDataSource.getSurahList();
      final rawJson = json.encode({
        'data': models.map((m) => m.toJson()).toList(),
      });
      await localDataSource.cacheSurahListRaw(rawJson);
    } catch (_) {
      // Silently ignore — we already have cache data
    }
  }

  // ────────────── Surah Detail ──────────────

  @override
  Future<SurahDetailEntity> getSurahDetail(int surahNumber) async {
    final isConnected = await networkInfo.isConnected;

    // Try cache first
    final cachedRaw =
        await localDataSource.getCachedSurahDetailRaw(surahNumber);
    final cacheValid =
        await localDataSource.isSurahDetailCacheValid(surahNumber);

    if (!isConnected) {
      if (cachedRaw != null) {
        final model = SurahDetailModel.fromJson(json.decode(cachedRaw));
        return model.data!.toEntity();
      }
      throw const NetworkException(
          message: 'Tidak ada data cache untuk mode offline');
    }

    if (cacheValid && cachedRaw != null) {
      // Return cached, refresh background
      _refreshSurahDetailInBackground(surahNumber);
      final model = SurahDetailModel.fromJson(json.decode(cachedRaw));
      return model.data!.toEntity();
    }

    // Fetch fresh
    final model = await remoteDataSource.getSurahDetail(surahNumber);
    await localDataSource.cacheSurahDetailRaw(
      surahNumber,
      json.encode(model.toJson()),
    );
    return model.data!.toEntity();
  }

  void _refreshSurahDetailInBackground(int surahNumber) async {
    try {
      final model = await remoteDataSource.getSurahDetail(surahNumber);
      await localDataSource.cacheSurahDetailRaw(
        surahNumber,
        json.encode(model.toJson()),
      );
    } catch (_) {}
  }

  // ────────────── Doa ──────────────

  @override
  Future<List<DoaEntity>> getDoaList() async {
    final models = await remoteDataSource.getDoaList();
    return models.map((m) => m.toEntity()).toList();
  }

  // ────────────── Last Read ──────────────

  @override
  Future<LastReadEntity?> getLastRead() => localDataSource.getLastRead();

  @override
  Future<void> saveLastRead(LastReadEntity data) =>
      localDataSource.saveLastRead(data);

  // ────────────── Reading Position ──────────────

  @override
  Future<void> saveReadingPosition({
    required int surahNumber,
    required int ayahNumber,
    required double scrollPosition,
  }) =>
      localDataSource.saveReadingPosition(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        scrollPosition: scrollPosition,
      );

  @override
  Future<Map<String, dynamic>> getReadingPosition() =>
      localDataSource.getReadingPosition();

  @override
  Future<double?> getScrollPosition(int surahNumber) =>
      localDataSource.getScrollPosition(surahNumber);

  @override
  Future<void> saveScrollPosition(int surahNumber, double position) =>
      localDataSource.saveScrollPosition(surahNumber, position);

  // ────────────── Qari ──────────────

  @override
  Future<void> saveQariSelection(QariEntity qari) =>
      localDataSource.saveQariSelection(qari);

  @override
  Future<QariEntity?> getQariSelection() => localDataSource.getQariSelection();

  // ────────────── Audio ──────────────

  @override
  Future<String> resolveAyahAudioSource({
    required String url,
    required bool offlineAllowed,
  }) async {
    if (offlineAllowed) {
      return audioCacheDataSource.getAudioFile(url);
    }
    return url; // Stream directly
  }

  // ────────────── Bookmarks ──────────────

  @override
  Future<void> toggleBookmark({required int surah, required int ayah}) =>
      localDataSource.toggleBookmark(surah: surah, ayah: ayah);

  @override
  Future<List<String>> getBookmarks() => localDataSource.getBookmarks();
}
