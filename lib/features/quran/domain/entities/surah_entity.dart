/// Domain entity representing a Surah in the list view.
class SurahEntity {
  final int nomor;
  final String namaArab;
  final String namaLatin;
  final String arti;
  final int jumlahAyat;
  final String tempatTurun;
  final String? deskripsi;

  const SurahEntity({
    required this.nomor,
    required this.namaArab,
    required this.namaLatin,
    required this.arti,
    required this.jumlahAyat,
    required this.tempatTurun,
    this.deskripsi,
  });
}
