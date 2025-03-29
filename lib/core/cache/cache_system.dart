import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class QuranAudioCache {
  // Singleton pattern
  static final QuranAudioCache _instance = QuranAudioCache._internal();
  factory QuranAudioCache() => _instance;
  QuranAudioCache._internal();

  // Cache configuration
  final int maxCacheSize = 200 * 1024 * 1024; // 200 MB
  final Duration maxCacheAge = Duration(days: 30);

  // Cache for tracking downloaded files
  Map<String, String> _audioCache = {};
  bool _isInitialized = false;

  // Initialize the cache
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load cache index from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString('quran_audio_cache');

      if (cacheData != null) {
        final Map<String, dynamic> cacheMap = json.decode(cacheData);
        _audioCache = Map<String, String>.from(cacheMap);
      }

      // Clean up old cache files
      _cleanupCache();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing audio cache: $e');
      // If there's an error, we'll just start with an empty cache
      _audioCache = {};
      _isInitialized = true;
    }
  }

  // Get file from cache or download it
  Future<String> getAudioFile(String url) async {
    await initialize();

    // Create a hash of the URL to use as a filename
    final String fileKey = _createHashFromUrl(url);

    // Check if we have this file cached
    if (_audioCache.containsKey(fileKey)) {
      final String filePath = _audioCache[fileKey]!;
      final File file = File(filePath);

      // Make sure the file still exists
      if (await file.exists()) {
        // Update last accessed time for this file
        await _updateAccessTime(fileKey);
        return filePath;
      } else {
        // File doesn't exist anymore, remove from cache
        _audioCache.remove(fileKey);
        await _saveCache();
      }
    }

    // File not in cache, download it
    return await _downloadFile(url, fileKey);
  }

  // Download a file and add it to the cache
  Future<String> _downloadFile(String url, String fileKey) async {
    try {
      // Get the cache directory
      final Directory cacheDir = await _getCacheDirectory();
      final String filePath = '${cacheDir.path}/$fileKey.mp3';

      // Download the file
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save file to cache directory
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Add to cache index
        _audioCache[fileKey] = filePath;

        // Save cache index
        await _saveCache();

        // Check if we need to clean up cache
        _checkCacheSize();

        return filePath;
      } else {
        throw Exception(
            'Failed to download audio file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading audio file: $e');
      // Return the original URL if download fails
      return url;
    }
  }

  // Create a hash from a URL to use as a filename
  String _createHashFromUrl(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  // Get the cache directory
  Future<Directory> _getCacheDirectory() async {
    final Directory appCacheDir = await getTemporaryDirectory();
    final Directory cacheDir =
        Directory('${appCacheDir.path}/quran_audio_cache');

    // Make sure the directory exists
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  // Save the cache index to shared preferences
  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('quran_audio_cache', json.encode(_audioCache));
    } catch (e) {
      print('Error saving audio cache: $e');
    }
  }

  // Update the last accessed time for a cached file
  Future<void> _updateAccessTime(String fileKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessTimes = prefs.getString('quran_audio_access_times');

      Map<String, dynamic> times = {};
      if (accessTimes != null) {
        times = json.decode(accessTimes);
      }

      times[fileKey] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('quran_audio_access_times', json.encode(times));
    } catch (e) {
      print('Error updating access time: $e');
    }
  }

  // Check if the cache size exceeds the limit and clean up if needed
  Future<void> _checkCacheSize() async {
    try {
      int totalSize = 0;
      final Directory cacheDir = await _getCacheDirectory();

      // Calculate total size of cache
      await for (FileSystemEntity entity
          in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      // If cache size exceeds limit, clean up
      if (totalSize > maxCacheSize) {
        await _cleanupCache();
      }
    } catch (e) {
      print('Error checking cache size: $e');
    }
  }

  // Clean up old or excess cache files
  Future<void> _cleanupCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessTimes = prefs.getString('quran_audio_access_times');

      if (accessTimes == null) return;

      Map<String, dynamic> times = json.decode(accessTimes);
      List<MapEntry<String, dynamic>> sortedEntries = times.entries.toList()
        ..sort((a, b) => (a.value as int).compareTo(b.value as int));

      // Get current time
      final int now = DateTime.now().millisecondsSinceEpoch;

      // First remove files older than max age
      for (int i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        final int fileTime = entry.value;

        if (now - fileTime > maxCacheAge.inMilliseconds) {
          final String fileKey = entry.key;
          if (_audioCache.containsKey(fileKey)) {
            final String filePath = _audioCache[fileKey]!;
            final File file = File(filePath);

            if (await file.exists()) {
              await file.delete();
            }

            _audioCache.remove(fileKey);
            times.remove(fileKey);
          }
        }
      }

      // Update cache after cleanup
      await prefs.setString('quran_audio_access_times', json.encode(times));
      await _saveCache();

      // Check if we need to remove more files to get under size limit
      int totalSize = 0;
      final Directory cacheDir = await _getCacheDirectory();

      // Calculate total size of cache
      await for (FileSystemEntity entity
          in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      // If still over limit, start removing least recently used files
      if (totalSize > maxCacheSize) {
        // Get updated list of files sorted by access time
        sortedEntries = times.entries.toList()
          ..sort((a, b) => (a.value as int).compareTo(b.value as int));

        for (int i = 0;
            i < sortedEntries.length && totalSize > maxCacheSize * 0.8;
            i++) {
          final entry = sortedEntries[i];
          final String fileKey = entry.key;

          if (_audioCache.containsKey(fileKey)) {
            final String filePath = _audioCache[fileKey]!;
            final File file = File(filePath);

            if (await file.exists()) {
              final int fileSize = await file.length();
              await file.delete();
              totalSize -= fileSize;
            }

            _audioCache.remove(fileKey);
            times.remove(fileKey);
          }
        }

        // Update cache after further cleanup
        await prefs.setString('quran_audio_access_times', json.encode(times));
        await _saveCache();
      }
    } catch (e) {
      print('Error cleaning up cache: $e');
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      final Directory cacheDir = await _getCacheDirectory();

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      _audioCache = {};

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('quran_audio_cache');
      await prefs.remove('quran_audio_access_times');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}

class QuranReadingCache {
  // Singleton pattern
  static final QuranReadingCache _instance = QuranReadingCache._internal();
  factory QuranReadingCache() => _instance;
  QuranReadingCache._internal();

  // Reading state cache keys
  static const String _lastReadSurahKey = 'last_read_surah';
  static const String _lastReadAyahKey = 'last_read_ayah';
  static const String _lastReadPositionKey = 'last_read_position';
  static const String _qariSelectionKey = 'qari_selection';
  static const String _readingHistoryKey = 'reading_history';

  // Cache most recently read surahs (up to 5)
  Future<void> saveReadingHistory(
      int surahNumber, String surahName, String arabicName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> history = [];

      // Get existing history
      final historyData = prefs.getString(_readingHistoryKey);
      if (historyData != null) {
        List<dynamic> decoded = json.decode(historyData);
        history =
            decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      // Check if the surah already exists in history
      final existingIndex =
          history.indexWhere((item) => item['number'] == surahNumber);
      if (existingIndex != -1) {
        // Move it to the front (most recent)
        final existing = history.removeAt(existingIndex);
        existing['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        history.insert(0, existing);
      } else {
        // Add new entry
        history.insert(0, {
          'number': surahNumber,
          'name': surahName,
          'arabicName': arabicName,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        });
      }

      // Keep only the most recent 5 entries
      if (history.length > 5) {
        history = history.sublist(0, 5);
      }

      // Save updated history
      await prefs.setString(_readingHistoryKey, json.encode(history));
    } catch (e) {
      print('Error saving reading history: $e');
    }
  }

  // Get reading history
  Future<List<Map<String, dynamic>>> getReadingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyData = prefs.getString(_readingHistoryKey);

      if (historyData != null) {
        List<dynamic> decoded = json.decode(historyData);
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error getting reading history: $e');
    }

    return [];
  }

  // Save current reading position
  Future<void> saveReadingPosition(
      int surahNumber, int ayahNumber, double scrollPosition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastReadSurahKey, surahNumber);
      await prefs.setInt(_lastReadAyahKey, ayahNumber);
      await prefs.setDouble(_lastReadPositionKey, scrollPosition);
    } catch (e) {
      print('Error saving reading position: $e');
    }
  }

  // Get last reading position
  Future<Map<String, dynamic>> getReadingPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surahNumber = prefs.getInt(_lastReadSurahKey);
      final ayahNumber = prefs.getInt(_lastReadAyahKey);
      final scrollPosition = prefs.getDouble(_lastReadPositionKey);

      if (surahNumber != null && ayahNumber != null) {
        return {
          'surahNumber': surahNumber,
          'ayahNumber': ayahNumber,
          'scrollPosition': scrollPosition ?? 0.0
        };
      }
    } catch (e) {
      print('Error getting reading position: $e');
    }

    return {};
  }

  // Save qari selection
  Future<void> saveQariSelection(int qariIndex, String qariId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_qariSelectionKey, qariIndex);
      await prefs.setString('${_qariSelectionKey}_id', qariId);
    } catch (e) {
      print('Error saving qari selection: $e');
    }
  }

  // Get qari selection
  Future<Map<String, dynamic>> getQariSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qariIndex = prefs.getInt(_qariSelectionKey);
      final qariId = prefs.getString('${_qariSelectionKey}_id');

      if (qariIndex != null && qariId != null) {
        return {'index': qariIndex, 'id': qariId};
      }
    } catch (e) {
      print('Error getting qari selection: $e');
    }

    return {};
  }

  // Cache surah data for offline access
  Future<void> cacheSurahData(
      int surahNumber, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('surah_cache_$surahNumber', json.encode(data));
      await prefs.setString('surah_cache_${surahNumber}_time',
          DateTime.now().millisecondsSinceEpoch.toString());
    } catch (e) {
      print('Error caching surah data: $e');
    }
  }

  // Get cached surah data
  Future<Map<String, dynamic>?> getCachedSurahData(int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('surah_cache_$surahNumber');

      if (cachedData != null) {
        final cacheTime = prefs.getString('surah_cache_${surahNumber}_time');
        if (cacheTime != null) {
          final cachedTimeMs = int.tryParse(cacheTime) ?? 0;
          final currentTime = DateTime.now().millisecondsSinceEpoch;
          final cacheDuration =
              Duration(days: 30).inMilliseconds; // Cache valid for 30 days

          // Check if cache is still valid
          if (currentTime - cachedTimeMs < cacheDuration) {
            return json.decode(cachedData);
          }
        }
      }
    } catch (e) {
      print('Error getting cached surah data: $e');
    }

    return null;
  }

  // Save last session data
  Future<void> saveSessionData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_reading_session', json.encode(data));
    } catch (e) {
      print('Error saving session data: $e');
    }
  }

  // Get last session data
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('last_reading_session');

      if (sessionData != null) {
        return json.decode(sessionData);
      }
    } catch (e) {
      print('Error getting session data: $e');
    }

    return null;
  }
}
