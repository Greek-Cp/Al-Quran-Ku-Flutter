import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/surah_detail_entity.dart';

/// Data model for a single Ayah — works for both Al-Fatihah and regular surahs.
class AyahModel {
  final int? nomorAyat;
  final String? teksArab;
  final String? teksLatin;
  final String? teksIndonesia;
  final Map<String, dynamic>? audio;

  AyahModel({
    this.nomorAyat,
    this.teksArab,
    this.teksLatin,
    this.teksIndonesia,
    this.audio,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      nomorAyat: json['nomorAyat'],
      teksArab: json['teksArab'],
      teksLatin: json['teksLatin'],
      teksIndonesia: json['teksIndonesia'],
      audio: json['audio'] != null
          ? Map<String, dynamic>.from(json['audio'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomorAyat': nomorAyat,
      'teksArab': teksArab,
      'teksLatin': teksLatin,
      'teksIndonesia': teksIndonesia,
      'audio': audio,
    };
  }

  AyahEntity toEntity() {
    final Map<String, String> audioMap = {};
    if (audio != null) {
      audio!.forEach((key, value) {
        if (value != null) {
          audioMap[key] = value.toString();
        }
      });
    }
    return AyahEntity(
      nomorAyat: nomorAyat ?? 0,
      teksArab: teksArab ?? '',
      teksLatin: teksLatin ?? '',
      teksIndonesia: teksIndonesia ?? '',
      audioMap: audioMap,
    );
  }
}

/// Navigation reference model for next/previous surah.
class SurahNavModel {
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? jumlahAyat;

  SurahNavModel({this.nomor, this.nama, this.namaLatin, this.jumlahAyat});

  factory SurahNavModel.fromJson(Map<String, dynamic> json) {
    return SurahNavModel(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
    };
  }

  SurahNavEntity toEntity() {
    return SurahNavEntity(
      nomor: nomor ?? 0,
      nama: nama ?? '',
      namaLatin: namaLatin ?? '',
      jumlahAyat: jumlahAyat ?? 0,
    );
  }
}

/// Data model for surah detail — handles both Al-Fatihah and regular surahs.
///
/// The old code had separate `DetailSurat` and `DetailSuratAlFatihah` classes.
/// This unified model handles both by treating `suratSebelumnya` as nullable
/// (Al-Fatihah has `false` for it instead of an object).
class SurahDetailModel {
  final int? code;
  final String? message;
  final SurahDetailDataModel? data;

  SurahDetailModel({this.code, this.message, this.data});

  factory SurahDetailModel.fromJson(Map<String, dynamic> json) {
    return SurahDetailModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? SurahDetailDataModel.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class SurahDetailDataModel {
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? jumlahAyat;
  final String? tempatTurun;
  final String? arti;
  final String? deskripsi;
  final List<AyahModel>? ayat;
  final SurahNavModel? suratSelanjutnya;
  final SurahNavModel? suratSebelumnya;

  SurahDetailDataModel({
    this.nomor,
    this.nama,
    this.namaLatin,
    this.jumlahAyat,
    this.tempatTurun,
    this.arti,
    this.deskripsi,
    this.ayat,
    this.suratSelanjutnya,
    this.suratSebelumnya,
  });

  factory SurahDetailDataModel.fromJson(Map<String, dynamic> json) {
    List<AyahModel>? ayatList;
    if (json['ayat'] != null) {
      ayatList =
          (json['ayat'] as List).map((v) => AyahModel.fromJson(v)).toList();
    }

    // Handle Al-Fatihah case: suratSebelumnya is `false` instead of an object
    SurahNavModel? navSebelumnya;
    if (json['suratSebelumnya'] != null &&
        json['suratSebelumnya'] is Map<String, dynamic>) {
      navSebelumnya = SurahNavModel.fromJson(json['suratSebelumnya']);
    }

    SurahNavModel? navSelanjutnya;
    if (json['suratSelanjutnya'] != null &&
        json['suratSelanjutnya'] is Map<String, dynamic>) {
      navSelanjutnya = SurahNavModel.fromJson(json['suratSelanjutnya']);
    }

    return SurahDetailDataModel(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
      ayat: ayatList,
      suratSelanjutnya: navSelanjutnya,
      suratSebelumnya: navSebelumnya,
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
      'ayat': ayat?.map((v) => v.toJson()).toList(),
      'suratSelanjutnya': suratSelanjutnya?.toJson(),
      'suratSebelumnya': suratSebelumnya?.toJson(),
    };
  }

  SurahDetailEntity toEntity() {
    // Filter out bismillah (nomorAyat == 0) if present
    final filteredAyat = (ayat ?? [])
        .where((a) => a.nomorAyat != null && a.nomorAyat! > 0)
        .map((a) => a.toEntity())
        .toList();

    return SurahDetailEntity(
      nomor: nomor ?? 0,
      namaArab: nama ?? '',
      namaLatin: namaLatin ?? '',
      jumlahAyat: jumlahAyat ?? 0,
      tempatTurun: tempatTurun ?? '',
      arti: arti ?? '',
      deskripsi: deskripsi ?? '',
      ayat: filteredAyat,
      suratSelanjutnya: suratSelanjutnya?.toEntity(),
      suratSebelumnya: suratSebelumnya?.toEntity(),
    );
  }
}
