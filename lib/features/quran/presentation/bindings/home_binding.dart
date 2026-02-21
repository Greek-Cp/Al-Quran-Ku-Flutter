import 'package:alquran_ku/core/network/network_info.dart';
import 'package:alquran_ku/features/quran/data/datasources/quran_audio_cache_data_source.dart';
import 'package:alquran_ku/features/quran/data/datasources/quran_local_data_source.dart';
import 'package:alquran_ku/features/quran/data/datasources/quran_remote_data_source.dart';
import 'package:alquran_ku/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:alquran_ku/features/quran/domain/repositories/quran_repository.dart';
import 'package:alquran_ku/features/quran/domain/usecases/filter_surah_by_revelation_place.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_last_read.dart';
import 'package:alquran_ku/features/quran/domain/usecases/get_surah_list.dart';
import 'package:alquran_ku/features/quran/domain/usecases/save_last_read.dart';
import 'package:alquran_ku/features/quran/domain/usecases/search_surah.dart';
import 'package:alquran_ku/features/quran/presentation/controllers/home_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Binding for the Home page — wires up the entire dependency chain.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // ── Infrastructure ──
    Get.lazyPut<http.Client>(() => http.Client());
    Get.lazyPut<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: Connectivity()),
    );

    // ── Data sources ──
    Get.lazyPut<QuranRemoteDataSource>(
      () => QuranRemoteDataSourceImpl(client: Get.find()),
    );

    // SharedPreferences is pre-registered in main.dart
    Get.lazyPut<QuranLocalDataSource>(
      () => QuranLocalDataSourceImpl(prefs: Get.find()),
    );

    Get.lazyPut<QuranAudioCacheDataSource>(
      () => QuranAudioCacheDataSourceImpl(
        prefs: Get.find(),
        client: Get.find(),
      ),
    );

    // ── Repository ──
    Get.lazyPut<QuranRepository>(
      () => QuranRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
        audioCacheDataSource: Get.find(),
        networkInfo: Get.find(),
      ),
    );

    // ── Use cases ──
    Get.lazyPut(() => GetSurahList(Get.find()));
    Get.lazyPut(() => GetLastRead(Get.find()));
    Get.lazyPut(() => SaveLastRead(Get.find()));
    Get.lazyPut(() => SearchSurah());
    Get.lazyPut(() => FilterSurahByRevelationPlace());

    // ── Controller ──
    Get.lazyPut(() => HomeController(
          getSurahListUseCase: Get.find(),
          getLastReadUseCase: Get.find(),
          saveLastReadUseCase: Get.find(),
          searchSurahUseCase: Get.find(),
          filterSurahUseCase: Get.find(),
        ));
  }
}
