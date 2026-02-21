import 'dart:ui';

import 'package:alquran_ku/core/theme/app_colors.dart';
import 'package:alquran_ku/features/quran/domain/entities/ayah_entity.dart';
import 'package:flutter/material.dart';

/// Extracted ayah card widget — displays Arabic text, latin, and translation.
class AyahCard extends StatelessWidget {
  final AyahEntity ayah;
  final int index;
  final bool isPlaying;
  final bool isBookmarked;
  final VoidCallback onPlay;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.index,
    required this.isPlaying,
    required this.isBookmarked,
    required this.onPlay,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF25294A), // Solid dark blue-slate base
        gradient: LinearGradient(
          colors: isPlaying
              ? [
                  const Color(0xFF32A0FF).withAlpha(40),
                  const Color(0xFF1089FF).withAlpha(20),
                ]
              : [
                  const Color(0xFF25294A),
                  const Color(0xFF1D203E),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPlaying
              ? const Color(0xFF32A0FF).withAlpha(150)
              : Colors.white.withAlpha(20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: [
              // Header with controls
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Number badge (circular bright blue)
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF32A0FF), Color(0xFF1089FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1089FF).withAlpha(75),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${ayah.nomorAyat}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Playing indicator
                    if (isPlaying)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.volume_up,
                                color: Colors.white.withOpacity(0.9), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Sedang Diputar',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    IconButton(
                      icon: Icon(Icons.share_outlined,
                          color: Colors.white.withOpacity(0.7), size: 20),
                      onPressed: onShare,
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: isPlaying
                            ? AppColors.highlight
                            : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                      onPressed: onPlay,
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: isBookmarked
                            ? AppColors.highlight
                            : Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      onPressed: onBookmark,
                    ),
                  ],
                ),
              ),

              // Arabic text
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Text(
                  ayah.teksArab,
                  style: const TextStyle(
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  ayah.teksLatin,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF8CC6FF), // Soft blue for latin
                  ),
                ),
              ),

              // Meaning text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  ayah.teksIndonesia,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
