class Juz {
  int? code;
  String? message;
  List<Data>? data;

  Juz({this.code, this.message, this.data});

  Juz.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
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

  Data(
      {this.nomor,
      this.nama,
      this.namaLatin,
      this.jumlahAyat,
      this.tempatTurun,
      this.arti,
      this.deskripsi,
      this.audioFull});

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
