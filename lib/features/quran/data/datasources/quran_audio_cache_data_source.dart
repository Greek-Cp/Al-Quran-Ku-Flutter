import 'dart:convert';
import 'dart:io';

import 'package:alquran_ku/core/constants/cache_keys.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio cache data source — manages downloading and caching audio files
/// for offline playback.
///
/// Ported from both `QuranAudioCache` in cache_system.dart and the
/// duplicated cache logic in page_halaman_baca.dart.
abstract class QuranAudioCacheDataSource {
  /// Returns a local file path if cached, or downloads and caches the file.
  /// Falls back to the original URL if download fails.
  Future<String> getAudioFile(String url);

  /// Clear all cached audio files.
  Future<void> clearCache();
}

class QuranAudioCacheDataSourceImpl implements QuranAudioCacheDataSource {
  final SharedPreferences prefs;
  final http.Client client;

  // Cache configuration
  static const int _maxCacheSize = 200 * 1024 * 1024; // 200 MB
  static const Duration _maxCacheAge = Duration(days: 30);

  Map<String, String> _audioCache = {};
  bool _isInitialized = false;

  QuranAudioCacheDataSourceImpl({
    required this.prefs,
    required this.client,
  });

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final cacheData = prefs.getString(CacheKeys.quranAudioCache);
      if (cacheData != null) {
        final Map<String, dynamic> cacheMap = json.decode(cacheData);
        _audioCache = Map<String, String>.from(cacheMap);
      }
      await _cleanupCache();
      _isInitialized = true;
    } catch (e) {
      _audioCache = {};
      _isInitialized = true;
    }
  }

  @override
  Future<String> getAudioFile(String url) async {
    await _initialize();

    final String fileKey = _createHash(url);

    // Check cache
    if (_audioCache.containsKey(fileKey)) {
      final String filePath = _audioCache[fileKey]!;
      final File file = File(filePath);
      if (await file.exists()) {
        await _updateAccessTime(fileKey);
        return filePath;
      } else {
        _audioCache.remove(fileKey);
        await _saveIndex();
      }
    }

    // Download
    return await _downloadFile(url, fileKey);
  }

  @override
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      _audioCache = {};
      await prefs.remove(CacheKeys.quranAudioCache);
      await prefs.remove(CacheKeys.quranAudioAccessTimes);
    } catch (_) {}
  }

  // ── Private helpers ──

  Future<String> _downloadFile(String url, String fileKey) async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      final String filePath = '${cacheDir.path}/$fileKey.mp3';
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        _audioCache[fileKey] = filePath;
        await _saveIndex();
        await _checkCacheSize();
        return filePath;
      } else {
        return url; // Fallback to streaming
      }
    } catch (_) {
      return url; // Fallback to streaming
    }
  }

  String _createHash(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  Future<Directory> _getCacheDirectory() async {
    final Directory appCacheDir = await getTemporaryDirectory();
    final Directory cacheDir =
        Directory('${appCacheDir.path}/${CacheKeys.audioCacheDirName}');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> _saveIndex() async {
    await prefs.setString(CacheKeys.quranAudioCache, json.encode(_audioCache));
  }

  Future<void> _updateAccessTime(String fileKey) async {
    try {
      final accessTimesStr = prefs.getString(CacheKeys.quranAudioAccessTimes);
      Map<String, dynamic> times = {};
      if (accessTimesStr != null) {
        times = json.decode(accessTimesStr);
      }
      times[fileKey] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(
        CacheKeys.quranAudioAccessTimes,
        json.encode(times),
      );
    } catch (_) {}
  }

  Future<void> _checkCacheSize() async {
    try {
      int totalSize = 0;
      final cacheDir = await _getCacheDirectory();
      await for (FileSystemEntity entity
          in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      if (totalSize > _maxCacheSize) {
        await _cleanupCache();
      }
    } catch (_) {}
  }

  Future<void> _cleanupCache() async {
    try {
      final accessTimesStr = prefs.getString(CacheKeys.quranAudioAccessTimes);
      if (accessTimesStr == null) return;

      Map<String, dynamic> times = json.decode(accessTimesStr);
      final now = DateTime.now().millisecondsSinceEpoch;

      // Remove files older than max age
      final keysToRemove = <String>[];
      for (final entry in times.entries) {
        if (now - (entry.value as int) > _maxCacheAge.inMilliseconds) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        if (_audioCache.containsKey(key)) {
          final file = File(_audioCache[key]!);
          if (await file.exists()) await file.delete();
          _audioCache.remove(key);
        }
        times.remove(key);
      }

      await prefs.setString(
        CacheKeys.quranAudioAccessTimes,
        json.encode(times),
      );
      await _saveIndex();
    } catch (_) {}
  }
}
