import 'package:alquran_ku/core/page/page_halaman_utama.dart';
import 'package:alquran_ku/core/widget/button/button_back.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:alquran_ku/model/data_model.dart';

import 'package:alquran_ku/res/dimension/size.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../res/colors/list_color.dart';
import '../controller/controller_halaman_utama.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';


class PageHalamanBaca extends StatefulWidget {
  static String? routeName = "/PageHalamanBaca";

  @override
  State<PageHalamanBaca> createState() => _PageHalamanBacaState();
}

class _PageHalamanBacaState extends State<PageHalamanBaca>
    with TickerProviderStateMixin {
  int selectedIndex = 1;
  List<ModelQori> listQori = [
    ModelQori("Abdullah Al Juhhany", "assets/icon/syeikh_1.png", "01"),
    ModelQori("Abdullah Muhsin Al Qasim", "assets/icon/syeikh_2.png", "02"),
    ModelQori("Abdurrahman as Sudais", "assets/icon/syeikh_3.png", "03"),
    ModelQori("Ibrahim-Al-Dossari", "assets/icon/syeikh_4.png", "04"),
    ModelQori("Misyari Rasyid Al-'Afasi", "assets/icon/syeikh_5.png", "05")
  ];

  String qoriSelected = "01";
  final controller = Get.put(QuranController());
  late AudioPlayer audioPlayer;
  Source? audioUrl;

  // For floating player and navigation
  bool isAudioPlaying = false;
  int currentPlayingAyat = -1;
  ScrollController scrollController = ScrollController();
  bool isPlayerVisible = false;
  List<String> audioUrlList = [];

  // Animation Controllers
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  late AnimationController _floatingPlayerAnimController;
  late Animation<double> _floatingPlayerAnimation;

  // Custom Colors
  final Color bgGradient1 = Color(0xFF0A1931);
  final Color bgGradient2 = Color(0xFF150E56);
  final Color primaryColor = Color(0xFF1089FF);
  final Color accentColor = Color(0xFF4E9AFF);
  final Color highlightColor = Color(0xFF00D2FC);

  // Cache variables
  bool isOffline = false;
  Map<String, String> _audioCache = {};
  bool _isInitialized = false;

  // Cache untuk data surah agar tidak perlu fetch ulang
  dynamic _cachedSurahData;
  bool _isSurahLoading = true;
  String? _surahError;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    // Background animation
    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _backgroundAnimation =
        Tween<double>(begin: 0, end: 1).animate(_backgroundAnimController);

    // Floating player animation
    _floatingPlayerAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _floatingPlayerAnimation = CurvedAnimation(
      parent: _floatingPlayerAnimController,
      curve: Curves.easeOutBack,
    );

    // Set up audio player listeners
    audioPlayer.onPlayerComplete.listen((event) {
      _playNextAyat();
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isAudioPlaying = state == PlayerState.playing;
      });
    });

    // Initialize
    _checkConnectivity();
    _initializeCache();
    _loadQariSelection();
    _fetchSurahData();

    // Listen for scroll events
    scrollController.addListener(_onScroll);
  }

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivityResult == ConnectivityResult.none;
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOffline = result == ConnectivityResult.none;
      });
    });
  }

  void _loadQariSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final qariIndex = prefs.getInt('qari_selection_index');
    final qariId = prefs.getString('qari_selection_id');

    if (qariIndex != null && qariId != null) {
      setState(() {
        selectedIndex = qariIndex;
        qoriSelected = qariId;
      });
    }
  }

  void _saveQariSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('qari_selection_index', selectedIndex);
    await prefs.setString('qari_selection_id', qoriSelected);
  }

  void _onScroll() {
    // Simpan posisi scroll terakhir
    if (scrollController.hasClients) {
      final prefs = SharedPreferences.getInstance();
      prefs.then((p) {
        p.setDouble('last_scroll_position_${controller.getPilihSurat}',
            scrollController.offset);
      });
    }
  }

  Future<void> _loadLastScrollPosition() async {
    if (!scrollController.hasClients) return;

    final prefs = await SharedPreferences.getInstance();
    final lastPosition =
        prefs.getDouble('last_scroll_position_${controller.getPilihSurat}');

    if (lastPosition != null) {
      // Delay sedikit untuk memastikan UI sudah dibangun
      Future.delayed(Duration(milliseconds: 200), () {
        if (scrollController.hasClients) {
          scrollController.jumpTo(lastPosition.clamp(
              0.0, scrollController.position.maxScrollExtent));
        }
      });
    }
  }

  // Fetch data surah sekali saja dan simpan di variabel state
  void _fetchSurahData() async {
    setState(() {
      _isSurahLoading = true;
      _surahError = null;
    });

    try {
      // Cek cache dulu
      final prefs = await SharedPreferences.getInstance();
      final cachedData =
          prefs.getString('surah_cache_${controller.getPilihSurat}');
      final cacheTimeStr =
          prefs.getString('surah_cache_time_${controller.getPilihSurat}');

      // Cek apakah cache masih valid (kurang dari 24 jam)
      bool isCacheValid = false;
      if (cachedData != null && cacheTimeStr != null) {
        final cacheTime = int.tryParse(cacheTimeStr) ?? 0;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        isCacheValid =
            (currentTime - cacheTime) < Duration(hours: 24).inMilliseconds;
      }

      // Jika offline, paksa gunakan cache apapun
      if (isOffline && cachedData != null) {
        isCacheValid = true;
      }

      if (isCacheValid && cachedData != null) {
        // Gunakan cache
        final decodedData = json.decode(cachedData);

        if (controller.getPilihSurat == 1) {
          _cachedSurahData = DetailSuratAlFatihah.fromJson(decodedData);
        } else {
          _cachedSurahData = DetailSurat.fromJson(decodedData);
        }

        setState(() {
          _isSurahLoading = false;
        });

        // Persiapkan audio URLs
        _prepareAudioUrls();

        // Load posisi scroll terakhir
        _loadLastScrollPosition();

        // Jika online, refresh cache di background
        if (!isOffline) {
          _refreshCacheInBackground();
        }
      } else {
        // Tidak ada cache valid, ambil dari network
        if (isOffline) {
          throw Exception('Tidak ada data cache untuk mode offline');
        }

        if (controller.getPilihSurat == 1) {
          final data =
              await QuranController.fetchDataDetailSuratAlFatihah(noSurat: "1");
          _cachedSurahData = data;

          // Simpan ke cache
          await prefs.setString('surah_cache_1', json.encode(data.toJson()));
          await prefs.setString('surah_cache_time_1',
              DateTime.now().millisecondsSinceEpoch.toString());
        } else {
          final data = await QuranController.fetchDataDetailSurat(
              noSurat: controller.getPilihSurat.toString());
          _cachedSurahData = data;

          // Simpan ke cache
          await prefs.setString('surah_cache_${controller.getPilihSurat}',
              json.encode(data.toJson()));
          await prefs.setString('surah_cache_time_${controller.getPilihSurat}',
              DateTime.now().millisecondsSinceEpoch.toString());
        }

        setState(() {
          _isSurahLoading = false;
        });

        // Persiapkan audio URLs
        _prepareAudioUrls();

        // Load posisi scroll terakhir
        _loadLastScrollPosition();
      }
    } catch (e) {
      setState(() {
        _isSurahLoading = false;
        _surahError = e.toString();
      });
    }
  }

  // Refresh cache di background tanpa mengganggu UI
  void _refreshCacheInBackground() async {
    try {
      if (controller.getPilihSurat == 1) {
        final data =
            await QuranController.fetchDataDetailSuratAlFatihah(noSurat: "1");

        // Simpan ke cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('surah_cache_1', json.encode(data.toJson()));
        await prefs.setString('surah_cache_time_1',
            DateTime.now().millisecondsSinceEpoch.toString());
      } else {
        final data = await QuranController.fetchDataDetailSurat(
            noSurat: controller.getPilihSurat.toString());

        // Simpan ke cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('surah_cache_${controller.getPilihSurat}',
            json.encode(data.toJson()));
        await prefs.setString('surah_cache_time_${controller.getPilihSurat}',
            DateTime.now().millisecondsSinceEpoch.toString());
      }
    } catch (e) {
      print('Error refreshing cache: $e');
      // Ignore error, just keep using old data
    }
  }

  // Persiapkan audio URLs berdasarkan data surah dan qari yang dipilih
  void _prepareAudioUrls() {
    if (_cachedSurahData == null) return;

    audioUrlList = [];

    if (_cachedSurahData is DetailSuratAlFatihah) {
      DetailSuratAlFatihah surah = _cachedSurahData;
      List<AyatAlFatihah>? listAyat = surah.data!.ayat;

      if (listAyat != null && listAyat.length > 0) {
        // Skip bismillah jika ada
        if (listAyat[0].nomorAyat == 0) {
          listAyat = listAyat.sublist(1);
        }

        for (int i = 0; i < listAyat.length; i++) {
          String url = "";
          switch (qoriSelected) {
            case "01":
              url = listAyat[i].audio!.s01.toString();
              break;
            case "02":
              url = listAyat[i].audio!.s02.toString();
              break;
            case "03":
              url = listAyat[i].audio!.s03.toString();
              break;
            case "04":
              url = listAyat[i].audio!.s04.toString();
              break;
            case "05":
              url = listAyat[i].audio!.s05.toString();
              break;
          }
          audioUrlList.add(url);
        }
      }
    } else if (_cachedSurahData is DetailSurat) {
      DetailSurat surah = _cachedSurahData;
      List<Ayat>? listAyat = surah.data!.ayat;

      if (listAyat != null && listAyat.length > 0) {
        // Skip bismillah jika ada
        if (listAyat[0].nomorAyat == 0) {
          listAyat = listAyat.sublist(1);
        }

        for (int i = 0; i < listAyat.length; i++) {
          String url = "";
          switch (qoriSelected) {
            case "01":
              url = listAyat[i].audio!.s01.toString();
              break;
            case "02":
              url = listAyat[i].audio!.s02.toString();
              break;
            case "03":
              url = listAyat[i].audio!.s03.toString();
              break;
            case "04":
              url = listAyat[i].audio!.s04.toString();
              break;
            case "05":
              url = listAyat[i].audio!.s05.toString();
              break;
          }
          audioUrlList.add(url);
        }
      }
    }

    // Precache beberapa audio pertama
    if (!isOffline && audioUrlList.length > 0) {
      _preCacheAudioFiles();
    }
  }

  void _preCacheAudioFiles() {
    // Batasi jumlah file yang di-precache untuk menghemat bandwidth
    final numFiles = audioUrlList.length > 3 ? 3 : audioUrlList.length;

    for (int i = 0; i < numFiles; i++) {
      _getCachedAudioFile(audioUrlList[i]);
    }
  }

  // Definisi untuk metode _buildAppBar()
  Widget _buildAppBar() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgGradient1.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      audioPlayer.stop();
                    },
                  ),
                ),

                // Title
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.namaSuratLatin.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.arti.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Arabic Name
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    controller.namaArab.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ScheherazadeNew',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Definisi untuk metode _buildSurahContent()
  Widget _buildSurahContent() {
    // Tampilkan loading state jika _isSurahLoading = true
    if (_isSurahLoading) {
      return _buildLoadingState();
    }

    // Tampilkan error state jika _surahError tidak null
    if (_surahError != null) {
      return _buildErrorState(_surahError!);
    }

    // Tampilkan konten jika data sudah ada
    if (_cachedSurahData != null) {
      if (_cachedSurahData is DetailSuratAlFatihah) {
        DetailSuratAlFatihah detailSurat = _cachedSurahData;
        List<AyatAlFatihah>? listAyat = detailSurat.data!.ayat;

        if (listAyat != null &&
            listAyat.length > 0 &&
            listAyat[0].nomorAyat == 0) {
          listAyat = listAyat.sublist(1);
        }

        return Column(
          children: [
            // Offline indicator if needed
            if (isOffline)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Mode Offline: Menampilkan surah dari cache. Audio mungkin tidak tersedia.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Surah info banner
            _buildSurahInfoBanner(
              detailSurat.data!.jumlahAyat.toString(),
              detailSurat.data!.tempatTurun!,
              detailSurat.data!.deskripsi ?? "",
            ),
            SizedBox(height: 20),

            // Ayat list
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listAyat!.length,
              itemBuilder: (context, index) {
                String urlSuaraBacaan = "";
                switch (qoriSelected) {
                  case "01":
                    urlSuaraBacaan = listAyat![index].audio!.s01.toString();
                    break;
                  case "02":
                    urlSuaraBacaan = listAyat![index].audio!.s02.toString();
                    break;
                  case "03":
                    urlSuaraBacaan = listAyat![index].audio!.s03.toString();
                    break;
                  case "04":
                    urlSuaraBacaan = listAyat![index].audio!.s04.toString();
                    break;
                  case "05":
                    urlSuaraBacaan = listAyat![index].audio!.s05.toString();
                    break;
                }

                return _buildAyatCard(
                  index,
                  listAyat![index].teksArab,
                  listAyat![index].teksLatin,
                  listAyat![index].teksIndonesia,
                  urlSuaraBacaan,
                );
              },
            ),
          ],
        );
      } else if (_cachedSurahData is DetailSurat) {
        DetailSurat detailSurat = _cachedSurahData;
        List<Ayat>? listAyat = detailSurat.data!.ayat;

        if (listAyat != null &&
            listAyat.length > 0 &&
            listAyat[0].nomorAyat == 0) {
          listAyat = listAyat.sublist(1);
        }

        return Column(
          children: [
            // Offline indicator if needed
            if (isOffline)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Mode Offline: Menampilkan surah dari cache. Audio mungkin tidak tersedia.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Surah info banner
            _buildSurahInfoBanner(
              detailSurat.data!.jumlahAyat.toString(),
              detailSurat.data!.tempatTurun!,
              detailSurat.data!.deskripsi ?? "",
            ),
            SizedBox(height: 20),

            // Ayat list
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listAyat!.length,
              itemBuilder: (context, index) {
                String urlSuaraBacaan = "";
                switch (qoriSelected) {
                  case "01":
                    urlSuaraBacaan = listAyat![index].audio!.s01.toString();
                    break;
                  case "02":
                    urlSuaraBacaan = listAyat![index].audio!.s02.toString();
                    break;
                  case "03":
                    urlSuaraBacaan = listAyat![index].audio!.s03.toString();
                    break;
                  case "04":
                    urlSuaraBacaan = listAyat![index].audio!.s04.toString();
                    break;
                  case "05":
                    urlSuaraBacaan = listAyat![index].audio!.s05.toString();
                    break;
                }

                return _buildAyatCard(
                  index,
                  listAyat![index].teksArab,
                  listAyat![index].teksLatin,
                  listAyat[index].teksIndonesia,
                  urlSuaraBacaan,
                );
              },
            ),
          ],
        );
      }

      // Tidak ada data yang valid
      return _buildErrorState(
          "Terjadi kesalahan memuat surah, silakan coba lagi");
    }

    // Default loading state jika tidak ada kondisi yang terpenuhi
    return _buildLoadingState();
  }

// Perbaikan untuk metode _initializeCache() agar tidak mengembalikan void
  Future<bool> _initializeCache() async {
    if (_isInitialized) return true;

    try {
      // Load cache index from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString('quran_audio_cache');

      if (cacheData != null) {
        try {
          final Map<String, dynamic> cacheMap = json.decode(cacheData);
          _audioCache = Map<String, String>.from(cacheMap);
        } catch (e) {
          print('Error parsing cache data: $e');
          _audioCache = {};
        }
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing audio cache: $e');
      _audioCache = {};
      _isInitialized = true;
      return false;
    }
  }

  // Get file from cache or download it
  Future<String> _getCachedAudioFile(String url) async {
    await _initializeCache();

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
        try {
          times = json.decode(accessTimes);
        } catch (e) {
          times = {};
        }
      }

      times[fileKey] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('quran_audio_access_times', json.encode(times));
    } catch (e) {
      print('Error updating access time: $e');
    }
  }

  void _showPlayer(int ayatNumber) {
    setState(() {
      isPlayerVisible = true;
      currentPlayingAyat = ayatNumber;
      isAudioPlaying = true;
    });
    _floatingPlayerAnimController.forward();
  }

  void _hidePlayer() {
    _floatingPlayerAnimController.reverse().then((_) {
      setState(() {
        isPlayerVisible = false;
        isAudioPlaying = false;
        currentPlayingAyat = -1;
      });
    });
  }

  void _playAyat(int ayatNumber, String audioUrl) async {
    // Stop current playback if any
    if (isAudioPlaying) {
      await audioPlayer.stop();
    }

    // Update the UI
    _showPlayer(ayatNumber);

    try {
      // Try to get cached file or download if not cached
      String audioFilePath = await _getCachedAudioFile(audioUrl);

      // Play the audio from cache or URL
      if (audioFilePath != audioUrl && audioFilePath.isNotEmpty) {
        // Cached file path
        this.audioUrl = DeviceFileSource(audioFilePath);
      } else {
        // Original URL
        this.audioUrl = UrlSource(audioUrl);
      }

      await audioPlayer.play(this.audioUrl!);
    } catch (e) {
      print('Error playing audio: $e');

      // Fallback to direct URL
      this.audioUrl = UrlSource(audioUrl);
      audioPlayer.play(this.audioUrl!);
    }

    // Scroll to the ayat if not visible
    if (scrollController.hasClients) {
      // Approximate calculation for scroll position
      double estimatedPosition = 200.0 + ayatNumber * 350.0;
      if (estimatedPosition > scrollController.position.pixels &&
          estimatedPosition <
              scrollController.position.pixels +
                  MediaQuery.of(context).size.height -
                  200) {
        // Ayat is already visible, no need to scroll
      } else {
        scrollController.animateTo(
          estimatedPosition - 100,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _playNextAyat() {
    if (currentPlayingAyat < audioUrlList.length - 1) {
      int nextAyat = currentPlayingAyat + 1;
      _playAyat(nextAyat, audioUrlList[nextAyat]);
    } else {
      // End of surah reached
      audioPlayer.stop();
      _hidePlayer();
    }
  }

  void _playPreviousAyat() {
    if (currentPlayingAyat > 0) {
      int prevAyat = currentPlayingAyat - 1;
      _playAyat(prevAyat, audioUrlList[prevAyat]);
    }
  }

  void _togglePlayPause() {
    if (isAudioPlaying) {
      audioPlayer.pause();
      setState(() {
        isAudioPlaying = false;
      });
    } else if (audioUrl != null) {
      audioPlayer.resume();
      setState(() {
        isAudioPlaying = true;
      });
    }
  }

  void _playAllAyahs() {
    if (audioUrlList.isNotEmpty) {
      _playAyat(0, audioUrlList[0]);
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _backgroundAnimController.dispose();
    _floatingPlayerAnimController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bgGradient1,
                      bgGradient2,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated circles with safe opacity values
                    Positioned(
                      top: 100 +
                          20 * _backgroundAnimation.value.abs().clamp(0.0, 1.0),
                      right: 20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [primaryColor, Colors.transparent],
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: -50 +
                          100 * _backgroundAnimation.value.clamp(0.0, 1.0),
                      child: Opacity(
                        opacity: 0.08,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [accentColor, Colors.transparent],
                              stops: [0.2, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30 +
                          60 * _backgroundAnimation.value.abs().clamp(0.0, 1.0),
                      right: 50,
                      child: Opacity(
                        opacity: 0.07,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [highlightColor, Colors.transparent],
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main Content with Persistent AppBar
          SafeArea(
            child: Column(
              children: [
                // Persistent App Bar
                _buildAppBar(),

                // Scrollable Content
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQariSelector(),
                            SizedBox(height: 20),
                            _buildBismillah(),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: _buildSurahContent(),
                            ),
                            // Extra space at bottom for floating player
                            SizedBox(height: isPlayerVisible ? 80 : 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Audio Player
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatingPlayerAnimation,
              builder: (context, child) {
                final animationValue =
                    _floatingPlayerAnimation.value.clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(0, 80 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 70,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: _buildFloatingPlayer(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatCard(
    int index,
    String? ayat,
    String? latin,
    String? arti,
    String urlSuaraBacaan,
  ) {
    bool isCurrentlyPlaying = currentPlayingAyat == index && isPlayerVisible;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentlyPlaying
              ? [primaryColor.withOpacity(0.15), accentColor.withOpacity(0.15)]
              : [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.05)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentlyPlaying
              ? primaryColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: [
              // Ayat header with controls
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isCurrentlyPlaying
                      ? primaryColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Ayat number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCurrentlyPlaying
                              ? [accentColor, highlightColor]
                              : [primaryColor, accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrentlyPlaying
                                ? accentColor.withOpacity(0.3)
                                : primaryColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    Spacer(),

                    // Control buttons
                    if (isCurrentlyPlaying)
                      AnimatedBuilder(
                          animation: _backgroundAnimation,
                          builder: (context, child) {
                            double value = _backgroundAnimation.value % 1.0;
                            // Gunakan clamp untuk memastikan opacity selalu antara 0.0 dan 1.0
                            double opacity =
                                (0.7 + 0.3 * value).clamp(0.0, 1.0);
                            return Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(
                                    (0.1 + 0.1 * value).clamp(0.0, 1.0)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.volume_up,
                                    color: Colors.white.withOpacity(opacity),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Sedang Diputar",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(opacity),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        // Implementasi berbagi ayat
                        _shareAyat(index, ayat, latin, arti);
                      },
                    ),

                    IconButton(
                      icon: Icon(
                        isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                        color: isCurrentlyPlaying
                            ? highlightColor
                            : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                      onPressed: () {
                        if (isCurrentlyPlaying) {
                          _togglePlayPause();
                        } else {
                          _playAyat(index, urlSuaraBacaan);
                        }
                      },
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.bookmark_outline,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        // Implementasi bookmark
                        _bookmarkAyat(index);
                      },
                    ),
                  ],
                ),
              ),

              // Arabic text
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Text(
                  ayat!,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.8,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'ScheherazadeNew',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withOpacity(0.1),
              ),

              // Latin text
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  latin!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),

              // Meaning text
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  arti!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Implementasi untuk berbagi ayat
  void _shareAyat(int index, String? ayat, String? latin, String? arti) {
    if (ayat == null || latin == null || arti == null) return;

    final String formattedAyat =
        "${controller.namaSuratLatin.value} ayat ${index + 1}\n\n$ayat\n\n$latin\n\n$arti";

    // Implementasi berbagi konten, bisa menggunakan plugin share_plus
    // Untuk contoh sederhana, tampilkan saja pesan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berbagi ayat: ${index + 1}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

// Implementasi untuk bookmark ayat
  void _bookmarkAyat(int index) {
    // Simpan bookmark ke SharedPreferences
    final prefs = SharedPreferences.getInstance();
    prefs.then((p) {
      // Ambil list bookmark yang sudah ada
      List<String> bookmarks = p.getStringList('bookmarked_ayats') ?? [];

      // Format bookmark: surat_nomor:ayat_nomor
      String bookmark = "${controller.getPilihSurat}:${index + 1}";

      if (bookmarks.contains(bookmark)) {
        // Hapus bookmark jika sudah ada
        bookmarks.remove(bookmark);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Tambahkan bookmark baru
        bookmarks.add(bookmark);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ayat ditandai'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Simpan kembali list bookmark
      p.setStringList('bookmarked_ayats', bookmarks);
    });
  }

  Widget _buildFloatingPlayer() {
    return Row(
      children: [
        // Ayat number with pulse animation
        AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              // Gunakan clamp untuk memastikan skala masuk akal
              double scale = (1.0 + 0.1 * (_backgroundAnimation.value % 1.0))
                  .clamp(1.0, 1.1);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: highlightColor.withOpacity(
                            (0.3 * (_backgroundAnimation.value % 1.0))
                                .clamp(0.0, 0.3)),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${currentPlayingAyat + 1}",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }),

        SizedBox(width: 16),

        // Playback info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Memutar Ayat ${currentPlayingAyat + 1}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                "Qari: ${listQori[selectedIndex].nameQori}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Control buttons
        IconButton(
          icon: Icon(
            Icons.skip_previous,
            color: Colors.white,
          ),
          onPressed: _playPreviousAyat,
        ),

        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              isAudioPlaying ? Icons.pause : Icons.play_arrow,
              color: primaryColor,
              size: 24,
            ),
            onPressed: _togglePlayPause,
          ),
        ),

        IconButton(
          icon: Icon(
            Icons.skip_next,
            color: Colors.white,
          ),
          onPressed: _playNextAyat,
        ),

        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            audioPlayer.stop();
            _hidePlayer();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Memuat Surah...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 50,
          ),
          SizedBox(height: 16),
          Text(
            "Terjadi Kesalahan",
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Coba muat ulang data
              _fetchSurahData();
            },
            child: Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              children: [
                // Animated bismillah container
                AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      // Gunakan clamp untuk memastikan nilai padding masuk akal
                      double padding =
                          (10 + 5 * (_backgroundAnimation.value % 0.5))
                              .clamp(10.0, 15.0);
                      double opacity =
                          (0.1 + 0.05 * (_backgroundAnimation.value % 0.5))
                              .clamp(0.1, 0.15);
                      return Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْم",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ScheherazadeNew',
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildSurahInfoBanner(
      String jumlahAyat, String tempatTurun, String deskripsi) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.7), accentColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with play all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Play All yang tidak menyebabkan refresh halaman
              GestureDetector(
                onTap: () {
                  // Periksa apakah ada audio yang bisa diputar
                  if (audioUrlList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tidak ada audio untuk diputar'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // Periksa apakah dalam mode offline dan audio tidak tersedia
                  if (isOffline) {
                    // Cek apakah setidaknya audio pertama sudah di-cache
                    bool isFirstAudioCached = false;
                    if (_audioCache.values.any((path) =>
                        path.contains(_createHashFromUrl(audioUrlList[0])))) {
                      isFirstAudioCached = true;
                    }

                    if (!isFirstAudioCached) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Audio tidak tersedia dalam mode offline'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                  }

                  // Mulai pemutaran
                  _playAllAyahs();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAudioPlaying ? Icons.pause : Icons.play_circle_fill,
                        color: primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isAudioPlaying ? "Jeda" : "Putar Semua",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Tafsir",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoBadge(Icons.location_on_outlined, tempatTurun),
              _buildInfoDivider(),
              _buildInfoBadge(
                  Icons.format_list_numbered_outlined, "$jumlahAyat Ayat"),
              _buildInfoDivider(),
              _buildInfoBadge(Icons.bookmark_outline, "Tandai"),
            ],
          ),

          if (deskripsi.isNotEmpty) ...[
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        insetPadding: EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.85),
                                accentColor.withOpacity(0.85)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Deskripsi Surah",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Text(
                                    deskripsi,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 10),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Tutup",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        deskripsi.length > 100
                            ? deskripsi.substring(0, 100) + "..."
                            : deskripsi,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildQariSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.record_voice_over,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Qari Bacaan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Pilih Qari",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal list of qari
        Container(
          height: 130,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: listQori.length,
            itemBuilder: (context, index) => _buildQariItem(
                index,
                listQori[index].nameQori!,
                listQori[index].gambarQori!,
                listQori[index].idQori!),
          ),
        ),
      ],
    );
  }

// Metode untuk membangun item Qari dalam daftar
  Widget _buildQariItem(
      int index, String namaQori, String gambarQori, String idQori) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        // Penting: Simpan qari terakhir sebelum mengubah state
        final bool wasPlaying = isAudioPlaying;
        final int lastAyat = currentPlayingAyat;

        if (isAudioPlaying) {
          audioPlayer.stop();
        }

        setState(() {
          selectedIndex = index;
          qoriSelected = idQori;

          // Kalau floating player visible, sembunyikan dulu
          if (isPlayerVisible) {
            _hidePlayer();
          }
        });

        // Simpan pilihan qari
        _saveQariSelection();

        // Update daftar audio
        _prepareAudioUrls();

        // Jika sedang memutar, mulai ulang dengan qari baru
        if (wasPlaying && lastAyat >= 0 && lastAyat < audioUrlList.length) {
          Future.delayed(Duration(milliseconds: 300), () {
            _playAyat(lastAyat, audioUrlList[lastAyat]);
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: isSelected ? 110 : 90,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.8),
                    accentColor.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: EdgeInsets.all(12),
              color: isSelected ? null : Colors.transparent,
              child: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Qari image with framed background
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: isSelected
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        child: ClipOval(
                          child: Image.asset(
                            gambarQori,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      namaQori
                          .split(' ')[0], // Just show first name to save space
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
