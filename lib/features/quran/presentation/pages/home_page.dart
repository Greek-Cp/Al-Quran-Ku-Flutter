import 'dart:ui';

import 'package:alquran_ku/core/theme/app_colors.dart';
import 'package:alquran_ku/features/quran/domain/entities/surah_entity.dart';
import 'package:alquran_ku/features/quran/presentation/controllers/home_controller.dart';
import 'package:alquran_ku/features/quran/presentation/widgets/last_read_card.dart';
import 'package:alquran_ku/features/quran/presentation/widgets/surah_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// Home page — migrated from page_halaman_utama.dart.
/// Uses HomeController via GetX binding instead of direct state management.
class HomePage extends StatefulWidget {
  static const String routeName = '/HomePage';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final HomeController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _animation,
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
                      top: 100 + 20 * _animation.value.abs(),
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
                      left: -50 + 100 * _animation.value,
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
                      bottom: -30 + 60 * _animation.value.abs(),
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
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: ClipRRect(
                  child: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.bgGradient1.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: _buildHeader(),
                    ),
                    centerTitle: true,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildLastRead()),
              SliverToBoxAdapter(child: _buildCategorySelector()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Surah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Obx(() => Text(
                            '${controller.filteredSurahList.length} Surah',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.accent,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.hasError.value) {
                  return SliverToBoxAdapter(child: _buildErrorView());
                }
                if (controller.filteredSurahList.isEmpty &&
                    !controller.isLoading.value) {
                  return SliverToBoxAdapter(child: _buildEmptyView());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = controller.filteredSurahList[index];
                      return SurahCard(
                        surah: surah,
                        onTap: () => _onSurahTap(surah),
                      );
                    },
                    childCount: controller.filteredSurahList.length,
                  ),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),

          // Loading Indicator
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _onSurahTap(SurahEntity surah) {
    controller.setSelectionSurat(surah.nomor);
    controller.setLastRead(surah);
    Get.toNamed('/ReadSurahPage', arguments: surah.nomor);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Assalamu'alaikum",
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 8),
                const Text('Al-Quran',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Baca Al-Quran Dengan Mudah',
                    style: TextStyle(
                        fontSize: 16, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icon/ic_kaligrafi.svg',
            width: 100,
            height: 100,
            color: Colors.white.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF25294A), // Solid dark base for search bar
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            child: Row(
              children: [
                Icon(Icons.search,
                    color: Colors.white.withOpacity(0.7), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari Surah...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: controller.search,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastRead() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Terakhir Dibaca',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          Obx(() => controller.nomorSurah.value.isNotEmpty
              ? LastReadCard(
                  nomorSurah: controller.nomorSurah.value,
                  namaSuratLatin: controller.namaSuratLatin.value,
                  arti: controller.arti.value,
                  descBawah: controller.descBawah.value,
                  namaArab: controller.namaArab.value,
                  onTap: () => Get.toNamed('/ReadSurahPage',
                      arguments:
                          int.tryParse(controller.nomorSurah.value) ?? 1),
                )
              : _buildNoLastReadCard()),
        ],
      ),
    );
  }

  Widget _buildNoLastReadCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF25294A), // Solid dark base
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book,
                      color: Colors.white, size: 25),
                ),
                const SizedBox(width: 15),
                Text('Belum ada surah yang dibaca',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    List<String> categories = ['Semua', 'Mekah', 'Madinah'];
    List<IconData> icons = [Icons.apps, Icons.mosque, Icons.location_city];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.category, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Kategori',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF25294A), // Solid dark base for category bg
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Obx(() => Row(
                        children: List.generate(
                          categories.length,
                          (index) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.filterByCategory(categories[index]);
                                setState(() => selectedCategory = index);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.selectedCategory.value ==
                                          categories[index]
                                      ? const Color(0xFF1089FF) // Bright blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icons[index],
                                        color:
                                            controller.selectedCategory.value ==
                                                    categories[index]
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.7),
                                        size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      categories[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            controller.selectedCategory.value ==
                                                    categories[index]
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            controller.selectedCategory.value ==
                                                    categories[index]
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off,
              color: Colors.white.withOpacity(0.5), size: 50),
          const SizedBox(height: 16),
          Text('Surah tidak ditemukan',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.error_outline, color: Colors.red[300], size: 50),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.fetchAllSurah,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
