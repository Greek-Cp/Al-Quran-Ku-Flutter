import 'package:alquran_ku/features/quran/domain/usecases/get_audio_source_for_ayah.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_bookmarked_ayahs.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_qari_selection.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_surah_detail.dart';
import 'package:alquran_ku/features/quran/domain/usecases/save_bookmark_ayah.dart';
import 'package:alquran_ku/features/quran/domain/usecases/save_qari_selection.dart';
import 'package:alquran_ku/features/quran/presentation/controllers/read_surah_controller.dart';
import 'package:get/get.dart';

/// Binding for the Read Surah page.
class ReadSurahBinding extends Bindings {
  @override
  void dependencies() {
    // Use cases (repository should already be registered from HomeBinding)
    Get.lazyPut(() => GetSurahDetail(Get.find()));
    Get.lazyPut(() => GetQariSelection(Get.find()));
    Get.lazyPut(() => SaveQariSelection(Get.find()));
    Get.lazyPut(() => GetAudioSourceForAyah(Get.find()));
    Get.lazyPut(() => SaveBookmarkAyah(Get.find()));
    Get.lazyPut(() => GetBookmarkedAyahs(Get.find()));

    // Controller
    Get.lazyPut(() => ReadSurahController(
          getSurahDetailUseCase: Get.find(),
          getQariSelectionUseCase: Get.find(),
          saveQariSelectionUseCase: Get.find(),
          getAudioSourceUseCase: Get.find(),
          saveBookmarkUseCase: Get.find(),
          getBookmarkedAyahsUseCase: Get.find(),
          repository: Get.find(),
        ));
  }
}
