import 'package:flutter/material.dart';

/// Extracted last-read card widget for home page.
class LastReadCard extends StatelessWidget {
  final String nomorSurah;
  final String namaSuratLatin;
  final String arti;
  final String descBawah;
  final String namaArab;
  final VoidCallback onTap;

  const LastReadCard({
    super.key,
    required this.nomorSurah,
    required this.namaSuratLatin,
    required this.arti,
    required this.descBawah,
    required this.namaArab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
            children: [
              // Number Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF32A0FF), Color(0xFF1089FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    nomorSurah,
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
                      namaSuratLatin,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      arti,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descBawah,
                      style: const TextStyle(
                        fontSize: 12,
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
                  namaArab,
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
    );
  }
}
