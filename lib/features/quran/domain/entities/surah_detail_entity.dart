import 'ayah_entity.dart';

/// Domain entity for surah detail with its ayah list and navigation info.
class SurahDetailEntity {
  final int nomor;
  final String namaArab;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final List<AyahEntity> ayat;
  final SurahNavEntity? suratSelanjutnya;
  final SurahNavEntity? suratSebelumnya;

  const SurahDetailEntity({
    required this.nomor,
    required this.namaArab,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.ayat,
    this.suratSelanjutnya,
    this.suratSebelumnya,
  });
}

/// Lightweight entity for next/previous surah navigation.
class SurahNavEntity {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  const SurahNavEntity({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });
}
