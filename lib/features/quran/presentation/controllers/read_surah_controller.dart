import 'package:alquran_ku/core/usecase/usecase.dart';
import 'package:alquran_ku/features/quran/data/models/qari_model.dart';
import 'package:alquran_ku/features/quran/domain/entities/ayah_entity.dart';
import 'package:alquran_ku/features/quran/domain/entities/qari_entity.dart';
import 'package:alquran_ku/features/quran/domain/entities/surah_detail_entity.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_audio_source_for_ayah.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_bookmarked_ayahs.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_qari_selection.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_surah_detail.dart';
import 'package:alquran_ku/features/quran/domain/usecases/save_bookmark_ayah.dart';
import 'package:alquran_ku/features/quran/domain/usecases/save_qari_selection.dart';
import 'package:alquran_ku/features/quran/domain/repositories/quran_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

/// Controller for the surah reading page.
///
/// Manages surah detail fetching, audio playback state machine,
/// qari selection, bookmarks, and scroll position — all via use cases.
class ReadSurahController extends GetxController {
  final GetSurahDetail getSurahDetailUseCase;
  final GetQariSelection getQariSelectionUseCase;
  final SaveQariSelection saveQariSelectionUseCase;
  final GetAudioSourceForAyah getAudioSourceUseCase;
  final SaveBookmarkAyah saveBookmarkUseCase;
  final GetBookmarkedAyahs getBookmarkedAyahsUseCase;
  final QuranRepository repository; // for scroll position

  ReadSurahController({
    required this.getSurahDetailUseCase,
    required this.getQariSelectionUseCase,
    required this.saveQariSelectionUseCase,
    required this.getAudioSourceUseCase,
    required this.saveBookmarkUseCase,
    required this.getBookmarkedAyahsUseCase,
    required this.repository,
  });

  // ── State ──
  var isLoading = true.obs;
  var errorMessage = Rxn<String>();
  var surahDetail = Rxn<SurahDetailEntity>();
  var ayatList = <AyahEntity>[].obs;

  // Audio state
  final AudioPlayer audioPlayer = AudioPlayer();
  var isAudioPlaying = false.obs;
  var currentPlayingAyat = (-1).obs;
  var isPlayerVisible = false.obs;
  var audioUrlList = <String>[].obs;

  // Qari
  var selectedQariIndex = 1.obs;
  var selectedQariId = '01'.obs;
  final List<QariEntity> availableQaris =
      QariModel.availableQaris.map((m) => m.toEntity()).toList();

  // Bookmarks
  var bookmarkedAyahs = <String>[].obs;

  // Connectivity
  var isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();

    audioPlayer.onPlayerComplete.listen((_) => playNextAyat());
    audioPlayer.onPlayerStateChanged.listen((state) {
      isAudioPlaying.value = state == PlayerState.playing;
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  // ── Fetch surah detail ──

  Future<void> fetchSurahDetail(int surahNumber) async {
    try {
      isLoading(true);
      errorMessage.value = null;

      // Load qari selection
      await _loadQariSelection();

      // Load bookmarks
      await _loadBookmarks();

      // Fetch surah
      final detail = await getSurahDetailUseCase(surahNumber);
      surahDetail.value = detail;
      ayatList.assignAll(detail.ayat);

      // Prepare audio URLs
      _prepareAudioUrls();

      isLoading(false);
    } catch (e) {
      isLoading(false);
      errorMessage.value = e.toString();
    }
  }

  // ── Qari ──

  Future<void> _loadQariSelection() async {
    try {
      final qari = await getQariSelectionUseCase(const NoParams());
      if (qari != null) {
        selectedQariId.value = qari.id;
        final index = availableQaris.indexWhere((q) => q.id == qari.id);
        if (index >= 0) selectedQariIndex.value = index;
      }
    } catch (_) {}
  }

  void selectQari(int index) {
    if (index < 0 || index >= availableQaris.length) return;
    selectedQariIndex.value = index;
    selectedQariId.value = availableQaris[index].id;
    saveQariSelectionUseCase(availableQaris[index]);
    _prepareAudioUrls();
  }

  // ── Audio ──

  void _prepareAudioUrls() {
    audioUrlList.clear();
    for (final ayah in ayatList) {
      final url = ayah.getAudioUrl(selectedQariId.value) ?? '';
      audioUrlList.add(url);
    }

    // Pre-cache first few
    _preCacheAudio();
  }

  void _preCacheAudio() async {
    final numFiles = audioUrlList.length > 3 ? 3 : audioUrlList.length;
    for (int i = 0; i < numFiles; i++) {
      if (audioUrlList[i].isNotEmpty) {
        getAudioSourceUseCase(AudioSourceParams(url: audioUrlList[i]));
      }
    }
  }

  Future<void> playAyat(int index) async {
    if (index < 0 || index >= audioUrlList.length) return;

    try {
      currentPlayingAyat.value = index;
      isPlayerVisible.value = true;

      final audioSource = await getAudioSourceUseCase(
        AudioSourceParams(url: audioUrlList[index]),
      );

      // Determine if local file or URL
      if (audioSource.startsWith('/') || audioSource.startsWith('file://')) {
        await audioPlayer.play(DeviceFileSource(audioSource));
      } else {
        await audioPlayer.play(UrlSource(audioSource));
      }
    } catch (e) {
      // Try streaming directly
      try {
        await audioPlayer.play(UrlSource(audioUrlList[index]));
      } catch (_) {}
    }
  }

  void playNextAyat() {
    if (currentPlayingAyat.value < audioUrlList.length - 1) {
      playAyat(currentPlayingAyat.value + 1);
    } else {
      // End of surah
      isPlayerVisible.value = false;
      currentPlayingAyat.value = -1;
    }
  }

  void playPreviousAyat() {
    if (currentPlayingAyat.value > 0) {
      playAyat(currentPlayingAyat.value - 1);
    }
  }

  void togglePlayPause() async {
    if (isAudioPlaying.value) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
  }

  void playAllAyahs() {
    if (audioUrlList.isNotEmpty) {
      playAyat(0);
    }
  }

  void hidePlayer() {
    audioPlayer.stop();
    isPlayerVisible.value = false;
    currentPlayingAyat.value = -1;
    isAudioPlaying.value = false;
  }

  // ── Bookmarks ──

  Future<void> _loadBookmarks() async {
    try {
      final bm = await getBookmarkedAyahsUseCase(const NoParams());
      bookmarkedAyahs.assignAll(bm);
    } catch (_) {}
  }

  Future<void> toggleBookmark(int surahNumber, int ayahNumber) async {
    await saveBookmarkUseCase(
      BookmarkParams(surah: surahNumber, ayah: ayahNumber),
    );
    await _loadBookmarks();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return bookmarkedAyahs.contains('$surahNumber:$ayahNumber');
  }

  // ── Scroll position ──

  Future<void> saveScrollPosition(int surahNumber, double position) async {
    await repository.saveScrollPosition(surahNumber, position);
  }

  Future<double?> getScrollPosition(int surahNumber) async {
    return repository.getScrollPosition(surahNumber);
  }
}
