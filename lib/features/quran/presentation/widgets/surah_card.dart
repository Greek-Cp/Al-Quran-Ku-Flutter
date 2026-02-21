import 'package:alquran_ku/features/quran/domain/entities/surah_entity.dart';
import 'package:flutter/material.dart';

/// Extracted surah card widget — used in the surah list on the home page.
class SurahCard extends StatelessWidget {
  final SurahEntity surah;
  final VoidCallback onTap;

  const SurahCard({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isMakkiyyah = surah.tempatTurun == 'Mekah';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withAlpha(25),
          highlightColor: Colors.white.withAlpha(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(20)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF25294A), // Distinct card color
                  const Color(0xFF1D203E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Number Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isMakkiyyah
                          ? const [Color(0xFF32A0FF), Color(0xFF1089FF)]
                          : const [Color(0xFF9B4CFF), Color(0xFF7B1FA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      surah.nomor.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.namaLatin,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${surah.tempatTurun} • ${surah.jumlahAyat} Ayat',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.arti,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF8CC6FF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic Badge (acting as icon)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  child: Text(
                    surah.namaArab,
                    style: const TextStyle(
                      fontFamily: 'ScheherazadeNew', // Use specific Arabic font
                      fontSize: 22,
                      color: Colors.white,
                      height: 1.2,
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
}
