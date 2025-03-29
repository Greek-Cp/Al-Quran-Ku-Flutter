import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:alquran_ku/core/controller/controller_halaman_utama.dart';
import 'package:alquran_ku/core/page/page_halaman_baca.dart';
import 'package:alquran_ku/core/widget/label/text_description.dart';
import 'package:alquran_ku/model/data_model.dart';
import 'package:alquran_ku/res/dimension/size.dart';
import 'package:alquran_ku/services/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// FILE: api.dart (for reference)
class API {
  static const String BASE_POINT_SURAT = "https://equran.id/api/v2/surat";
  static const String BASE_POINT_DETAIL_SURAT =
      "https://equran.id/api/v2/surat/";
  static const String BASE_POINT_DOA =
      "https://doa-doa-api-ahmadramadhan.fly.dev/api";
  static const String BASE_POINT_TAFSIR = "https://equran.id/api/v2/tafsir/";
}

// FILE: controller_halaman_utama.dart

class PageHalamanUtama extends StatefulWidget {
  static String? routeName = "/PageHalamanUtama";

  @override
  State<PageHalamanUtama> createState() => _PageHalamanUtamaState();
}

class _PageHalamanUtamaState extends State<PageHalamanUtama>
    with SingleTickerProviderStateMixin {
  int selectedCategory = 0;
  final controller = Get.put(QuranController());

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Colors - Using same colors as Page Halaman Baca for consistency
  final Color bgGradient1 = Color(0xFF0A1931);
  final Color bgGradient2 = Color(0xFF150E56);
  final Color primaryColor = Color(0xFF1089FF);
  final Color accentColor = Color(0xFF4E9AFF);
  final Color highlightColor = Color(0xFF00D2FC);

  @override
  void initState() {
    super.initState();

    // Animation for background
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
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
                    // Animated circles for subtle background effects
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
                              colors: [primaryColor, Colors.transparent],
                              stops: [0.3, 1.0],
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
                              colors: [accentColor, Colors.transparent],
                              stops: [0.2, 1.0],
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

          // Main Content
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // App Bar with Header
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: ClipRRect(
                  child: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bgGradient1.withOpacity(0.7),
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

              // Search Bar
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              // Last Read
              SliverToBoxAdapter(
                child: _buildLastRead(),
              ),

              // Category Selector
              SliverToBoxAdapter(
                child: _buildCategorySelector(),
              ),

              // Surah List Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Daftar Surah",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Obx(() => Text(
                            "${controller.filteredSurahList.length} Surah",
                            style: TextStyle(
                              fontSize: 14,
                              color: accentColor,
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // Surah List
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
                      return _buildSurahCard(surah);
                    },
                    childCount: controller.filteredSurahList.length,
                  ),
                );
              }),

              // Bottom Space
              SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
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
                      child: Center(
                        child: CircularProgressIndicator(
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  // Header with kaligrafi
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Assalamu'alaikum",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Al-Quran",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Baca Al-Quran Dengan Mudah",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: SvgPicture.asset(
              "assets/icon/ic_kaligrafi.svg",
              width: 100,
              height: 100,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Search bar with glassmorphism
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari Surah...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
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

  // Last read section
  Widget _buildLastRead() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Terakhir Dibaca",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => controller.nomorSurah.value.isNotEmpty
              ? _buildLastReadCard()
              : _buildNoLastReadCard()),
        ],
      ),
    );
  }

  // Last read card with glassmorphism
  Widget _buildLastReadCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              onTap: () {
                Get.toNamed(PageHalamanBaca.routeName!);
              },
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    // Number Icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          controller.nomorSurah.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.namaSuratLatin.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            controller.arti.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            controller.descBawah.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arabic Name
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        controller.namaArab.value,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  // No last read card
  Widget _buildNoLastReadCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  "Belum ada surah yang dibaca",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Category selector
  Widget _buildCategorySelector() {
    List<String> categories = ['Semua', 'Mekah', 'Madinah'];
    List<IconData> icons = [Icons.apps, Icons.mosque, Icons.location_city];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.category, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Kategori",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Obx(() => Row(
                        children: List.generate(
                          categories.length,
                          (index) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.filterByCategory(categories[index]);
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: controller.selectedCategory.value ==
                                          categories[index]
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icons[index],
                                      color:
                                          controller.selectedCategory.value ==
                                                  categories[index]
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
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

  // Surah card
  Widget _buildSurahCard(Data surah) {
    final bool isMakkiyyah = surah.tempatTurun == 'Mekah';

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              onTap: () {
                controller.setSelectionSurat(surah.nomor!);

                controller.setLastRead(surah);
                Get.toNamed(PageHalamanBaca.routeName!);
              },
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isMakkiyyah
                              ? [Color(0xFF1E88E5), Color(0xFF42A5F5)]
                              : [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isMakkiyyah
                                ? Color(0xFF1E88E5).withOpacity(0.3)
                                : Color(0xFF7B1FA2).withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          surah.nomor.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.namaLatin.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isMakkiyyah
                                      ? Color(0xFF1E88E5).withOpacity(0.2)
                                      : Color(0xFF9C27B0).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isMakkiyyah
                                          ? Icons.mosque
                                          : Icons.location_city,
                                      size: 12,
                                      color: isMakkiyyah
                                          ? Color(0xFF42A5F5)
                                          : Color(0xFFBA68C8),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      surah.tempatTurun.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMakkiyyah
                                            ? Color(0xFF42A5F5)
                                            : Color(0xFFBA68C8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.format_list_numbered,
                                      size: 12,
                                      color: accentColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "${surah.jumlahAyat} Ayat",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: accentColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arabic name
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        surah.nama.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
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

  // Empty view
  Widget _buildEmptyView() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              "Tidak ada surah yang ditemukan",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error view
  Widget _buildErrorView() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.15),
            Colors.red.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[300],
                size: 50,
              ),
              SizedBox(height: 15),
              Text(
                "Terjadi Kesalahan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.fetchAllSurah(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "Coba Lagi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sliver delegate for search bar
class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverSearchBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: child,
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
