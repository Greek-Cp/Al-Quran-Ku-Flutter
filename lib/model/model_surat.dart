class DetailSurat {
  int? code;
  String? message;
  Data? data;

  DetailSurat({this.code, this.message, this.data});

  DetailSurat.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? nomor;
  String? nama;
  String? namaLatin;
  int? jumlahAyat;
  String? tempatTurun;
  String? arti;
  String? deskripsi;
  AudioFull? audioFull;
  List<Ayat>? ayat;
  SuratSelanjutnya? suratSelanjutnya;
  SuratSelanjutnya? suratSebelumnya;

  Data(
      {this.nomor,
      this.nama,
      this.namaLatin,
      this.jumlahAyat,
      this.tempatTurun,
      this.arti,
      this.deskripsi,
      this.audioFull,
      this.ayat,
      this.suratSelanjutnya,
      this.suratSebelumnya});

  Data.fromJson(Map<String, dynamic> json) {
    nomor = json['nomor'];
    nama = json['nama'];
    namaLatin = json['namaLatin'];
    jumlahAyat = json['jumlahAyat'];
    tempatTurun = json['tempatTurun'];
    arti = json['arti'];
    deskripsi = json['deskripsi'];
    audioFull = json['audioFull'] != null
        ? new AudioFull.fromJson(json['audioFull'])
        : null;
    if (json['ayat'] != null) {
      ayat = <Ayat>[];
      json['ayat'].forEach((v) {
        ayat!.add(new Ayat.fromJson(v));
      });
    }
    suratSelanjutnya = json['suratSelanjutnya'] != null
        ? new SuratSelanjutnya.fromJson(json['suratSelanjutnya'])
        : null;
    suratSebelumnya = json['suratSebelumnya'] != null
        ? new SuratSelanjutnya.fromJson(json['suratSebelumnya'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomor'] = this.nomor;
    data['nama'] = this.nama;
    data['namaLatin'] = this.namaLatin;
    data['jumlahAyat'] = this.jumlahAyat;
    data['tempatTurun'] = this.tempatTurun;
    data['arti'] = this.arti;
    data['deskripsi'] = this.deskripsi;
    if (this.audioFull != null) {
      data['audioFull'] = this.audioFull!.toJson();
    }
    if (this.ayat != null) {
      data['ayat'] = this.ayat!.map((v) => v.toJson()).toList();
    }
    if (this.suratSelanjutnya != null) {
      data['suratSelanjutnya'] = this.suratSelanjutnya!.toJson();
    }
    if (this.suratSebelumnya != null) {
      data['suratSebelumnya'] = this.suratSebelumnya!.toJson();
    }
    return data;
  }
}

class AudioFull {
  String? s01;
  String? s02;
  String? s03;
  String? s04;
  String? s05;

  AudioFull({this.s01, this.s02, this.s03, this.s04, this.s05});

  AudioFull.fromJson(Map<String, dynamic> json) {
    s01 = json['01'];
    s02 = json['02'];
    s03 = json['03'];
    s04 = json['04'];
    s05 = json['05'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['01'] = this.s01;
    data['02'] = this.s02;
    data['03'] = this.s03;
    data['04'] = this.s04;
    data['05'] = this.s05;
    return data;
  }
}

class Ayat {
  int? nomorAyat;
  String? teksArab;
  String? teksLatin;
  String? teksIndonesia;
  AudioFull? audio;

  Ayat(
      {this.nomorAyat,
      this.teksArab,
      this.teksLatin,
      this.teksIndonesia,
      this.audio});

  Ayat.fromJson(Map<String, dynamic> json) {
    nomorAyat = json['nomorAyat'];
    teksArab = json['teksArab'];
    teksLatin = json['teksLatin'];
    teksIndonesia = json['teksIndonesia'];
    audio =
        json['audio'] != null ? new AudioFull.fromJson(json['audio']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomorAyat'] = this.nomorAyat;
    data['teksArab'] = this.teksArab;
    data['teksLatin'] = this.teksLatin;
    data['teksIndonesia'] = this.teksIndonesia;
    if (this.audio != null) {
      data['audio'] = this.audio!.toJson();
    }
    return data;
  }
}

class SuratSelanjutnya {
  int? nomor;
  String? nama;
  String? namaLatin;
  int? jumlahAyat;

  SuratSelanjutnya({this.nomor, this.nama, this.namaLatin, this.jumlahAyat});

  SuratSelanjutnya.fromJson(Map<String, dynamic> json) {
    nomor = json['nomor'];
    nama = json['nama'];
    namaLatin = json['namaLatin'];
    jumlahAyat = json['jumlahAyat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomor'] = this.nomor;
    data['nama'] = this.nama;
    data['namaLatin'] = this.namaLatin;
    data['jumlahAyat'] = this.jumlahAyat;
    return data;
  }
}
