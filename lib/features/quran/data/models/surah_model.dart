import '../../domain/entities/surah_entity.dart';

/// Data model for Surah list — maps from API JSON to entity.
class SurahModel {
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? jumlahAyat;
  final String? tempatTurun;
  final String? arti;
  final String? deskripsi;

  SurahModel({
    this.nomor,
    this.nama,
    this.namaLatin,
    this.jumlahAyat,
    this.tempatTurun,
    this.arti,
    this.deskripsi,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
      'tempatTurun': tempatTurun,
      'arti': arti,
      'deskripsi': deskripsi,
    };
  }

  SurahEntity toEntity() {
    return SurahEntity(
      nomor: nomor ?? 0,
      namaArab: nama ?? '',
      namaLatin: namaLatin ?? '',
      arti: arti ?? '',
      jumlahAyat: jumlahAyat ?? 0,
      tempatTurun: tempatTurun ?? '',
      deskripsi: deskripsi,
    );
  }
}

/// Wrapper for the API response containing a list of surahs.
class SurahListResponse {
  final int? code;
  final String? message;
  final List<SurahModel>? data;

  SurahListResponse({this.code, this.message, this.data});

  factory SurahListResponse.fromJson(Map<String, dynamic> json) {
    List<SurahModel>? surahList;
    if (json['data'] != null) {
      surahList =
          (json['data'] as List).map((v) => SurahModel.fromJson(v)).toList();
    }
    return SurahListResponse(
      code: json['code'],
      message: json['message'],
      data: surahList,
    );
  }
}
