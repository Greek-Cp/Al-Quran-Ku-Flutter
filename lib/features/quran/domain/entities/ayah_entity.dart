/// Domain entity for a single ayah (verse).
class AyahEntity {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;

  /// Map of qari ID → audio URL, e.g. {'01': 'https://...', '02': '...'}
  final Map<String, String> audioMap;

  const AyahEntity({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audioMap,
  });

  /// Get audio URL for a specific qari by their ID.
  String? getAudioUrl(String qariId) => audioMap[qariId];
}
