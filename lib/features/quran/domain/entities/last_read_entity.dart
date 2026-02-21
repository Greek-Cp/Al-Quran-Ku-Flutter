/// Domain entity for tracking last-read surah position.
class LastReadEntity {
  final int surahNumber;
  final String surahName;
  final String arabicName;
  final String arti;
  final String descBawah;
  final int? ayahNumber;
  final double? scrollPosition;
  final int? timestamp;

  const LastReadEntity({
    required this.surahNumber,
    required this.surahName,
    required this.arabicName,
    required this.arti,
    required this.descBawah,
    this.ayahNumber,
    this.scrollPosition,
    this.timestamp,
  });
}
