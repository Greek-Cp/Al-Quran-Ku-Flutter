import 'dart:ui';

import 'package:alquran_ku/core/theme/app_colors.dart';
import 'package:alquran_ku/features/quran/presentation/controllers/read_surah_controller.dart';
import 'package:alquran_ku/features/quran/presentation/widgets/ayah_card.dart';
import 'package:alquran_ku/features/quran/presentation/widgets/qari_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Read Surah page — migrated from page_halaman_baca.dart (2235 lines).
///
/// Uses ReadSurahController via GetX binding. All business logic (audio, cache,
/// bookmarks, qari) is in the controller; this page is UI-only.
class ReadSurahPage extends StatefulWidget {
  static const String routeName = '/ReadSurahPage';

  const ReadSurahPage({super.key});

  @override
  State<ReadSurahPage> createState() => _ReadSurahPageState();
}

class _ReadSurahPageState extends State<ReadSurahPage>
    with TickerProviderStateMixin {
  late final ReadSurahController controller;
  late AnimationController _backgroundAnimController;
  late AnimationController _floatingPlayerAnimController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatingPlayerAnimation;
  late ScrollController scrollController;

  late final int surahNumber;

  @override
  void initState() {
    super.initState();
    surahNumber = Get.arguments as int;
    controller = Get.find<ReadSurahController>();
    scrollController = ScrollController();

    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _backgroundAnimation =
        Tween<double>(begin: 0, end: 1).animate(_backgroundAnimController);

    _floatingPlayerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _floatingPlayerAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _floatingPlayerAnimController, curve: Curves.easeOut));

    // Listen to player visibility
    ever(controller.isPlayerVisible, (visible) {
      if (visible) {
        _floatingPlayerAnimController.forward();
      } else {
        _floatingPlayerAnimController.reverse();
      }
    });

    controller.fetchSurahDetail(surahNumber);

    // Save/restore scroll position
    _restoreScrollPosition();
    scrollController.addListener(_onScroll);
  }

  void _restoreScrollPosition() async {
    final pos = await controller.getScrollPosition(surahNumber);
    if (pos != null && pos > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(pos);
        }
      });
    }
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      controller.saveScrollPosition(surahNumber, scrollController.offset);
    }
  }

  @override
  void dispose() {
    controller.hidePlayer();
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.bgGradient1, AppColors.bgGradient2],
                  ),
                ),
                child: Stack(
                  children: [
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
                              colors: [AppColors.primary, Colors.transparent],
                              stops: const [0.3, 1.0],
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
                              colors: [AppColors.accent, Colors.transparent],
                              stops: const [0.2, 1.0],
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
                              colors: [AppColors.highlight, Colors.transparent],
                              stops: const [0.3, 1.0],
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

          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) return _buildLoadingState();
                    if (controller.errorMessage.value != null) {
                      return _buildErrorState(controller.errorMessage.value!);
                    }
                    return CustomScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => QariSelector(
                                    qaris: controller.availableQaris,
                                    selectedIndex:
                                        controller.selectedQariIndex.value,
                                    onSelect: controller.selectQari,
                                  )),
                              const SizedBox(height: 20),
                              _buildBismillah(),
                              const SizedBox(height: 20),
                              _buildSurahInfoBanner(),
                              const SizedBox(height: 20),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildAyahList(),
                              ),
                              Obx(() => SizedBox(
                                  height: controller.isPlayerVisible.value
                                      ? 80
                                      : 20)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
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
                final animVal = _floatingPlayerAnimation.value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 80 * (1 - animVal)),
                  child: Opacity(
                    opacity: animVal,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(
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

  Widget _buildAppBar() {
    return Obx(() {
      final detail = controller.surahDetail.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    detail?.namaLatin ?? 'Memuat...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail.namaArab,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 48), // Balance back button
          ],
        ),
      );
    });
  }

  Widget _buildBismillah() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF25294A), // Solid dark base
        gradient: LinearGradient(
          colors: [
            const Color(0xFF32A0FF).withAlpha(40),
            const Color(0xFF1089FF).withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(25), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْم',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ScheherazadeNew',
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang',
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

  Widget _buildSurahInfoBanner() {
    return Obx(() {
      final detail = controller.surahDetail.value;
      if (detail == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF32A0FF),
              Color(0xFF1089FF)
            ], // Bright blue gradient from screenshot
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1089FF).withAlpha(75),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: controller.playAllAyahs,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(() => Row(
                          children: [
                            Icon(
                              controller.isAudioPlaying.value
                                  ? Icons.pause
                                  : Icons.play_circle_fill,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.isAudioPlaying.value
                                  ? 'Jeda'
                                  : 'Putar Semua',
                              style: const TextStyle(
                                color: const Color(0xFF1089FF),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Tafsir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoBadge(Icons.location_on_outlined, detail.tempatTurun),
                _buildInfoDivider(),
                _buildInfoBadge(Icons.format_list_numbered_outlined,
                    '${detail.jumlahAyat} Ayat'),
                _buildInfoDivider(),
                _buildInfoBadge(Icons.bookmark_outline, 'Tandai'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            )),
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

  Widget _buildAyahList() {
    return Obx(() {
      return Column(
        children: List.generate(controller.ayatList.length, (index) {
          final ayah = controller.ayatList[index];
          return Obx(() => AyahCard(
                ayah: ayah,
                index: index,
                isPlaying: controller.currentPlayingAyat.value == index &&
                    controller.isPlayerVisible.value,
                isBookmarked:
                    controller.isBookmarked(surahNumber, ayah.nomorAyat),
                onPlay: () {
                  if (controller.currentPlayingAyat.value == index &&
                      controller.isPlayerVisible.value) {
                    controller.togglePlayPause();
                  } else {
                    controller.playAyat(index);
                  }
                },
                onBookmark: () =>
                    controller.toggleBookmark(surahNumber, ayah.nomorAyat),
                onShare: () => _shareAyat(ayah.nomorAyat, ayah.teksArab,
                    ayah.teksLatin, ayah.teksIndonesia),
              ));
        }),
      );
    });
  }

  void _shareAyat(int ayatNum, String arab, String latin, String arti) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berbagi ayat: $ayatNum'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFloatingPlayer() {
    return Obx(() => Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${controller.currentPlayingAyat.value + 1}',
                  style: const TextStyle(
                    color: Color(0xFF1089FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Memutar Ayat ${controller.currentPlayingAyat.value + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qari: ${controller.availableQaris[controller.selectedQariIndex.value].nama.split(' ')[0]}',
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
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: controller.playPreviousAyat,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  controller.isAudioPlaying.value
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: const Color(0xFF1089FF),
                  size: 24,
                ),
                onPressed: controller.togglePlayPause,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: controller.playNextAyat,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: controller.hidePlayer,
            ),
          ],
        ));
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Memuat Surah...',
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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 50),
            const SizedBox(height: 16),
            Text('Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.red[300],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => controller.fetchSurahDetail(surahNumber),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
