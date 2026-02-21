import '../../domain/entities/doa_entity.dart';

/// Data model for Doa (prayer/supplication) from the Doa API.
class DoaModel {
  final String? id;
  final String? doa;
  final String? ayat;
  final String? latin;
  final String? artinya;

  DoaModel({this.id, this.doa, this.ayat, this.latin, this.artinya});

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      id: json['id']?.toString(),
      doa: json['doa'],
      ayat: json['ayat'],
      latin: json['latin'],
      artinya: json['artinya'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doa': doa,
      'ayat': ayat,
      'latin': latin,
      'artinya': artinya,
    };
  }

  DoaEntity toEntity() {
    return DoaEntity(
      id: id ?? '',
      judulDoa: doa ?? '',
      ayat: ayat ?? '',
      latin: latin ?? '',
      arti: artinya ?? '',
    );
  }
}
