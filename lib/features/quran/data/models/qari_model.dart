import '../../domain/entities/qari_entity.dart';

/// Data model for Qari — maps between local data and entity.
class QariModel {
  final String id;
  final String nama;
  final String imageAsset;

  const QariModel({
    required this.id,
    required this.nama,
    required this.imageAsset,
  });

  factory QariModel.fromJson(Map<String, dynamic> json) {
    return QariModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      imageAsset: json['imageAsset'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'imageAsset': imageAsset,
    };
  }

  QariEntity toEntity() {
    return QariEntity(id: id, nama: nama, imageAsset: imageAsset);
  }

  factory QariModel.fromEntity(QariEntity entity) {
    return QariModel(
      id: entity.id,
      nama: entity.nama,
      imageAsset: entity.imageAsset,
    );
  }

  /// Static list of available qaris (hardcoded as in the original app).
  static List<QariModel> availableQaris = [
    QariModel(
        id: '01',
        nama: 'Abdullah Al Juhhany',
        imageAsset: 'assets/icon/syeikh_1.png'),
    QariModel(
        id: '02',
        nama: 'Abdullah Muhsin Al Qasim',
        imageAsset: 'assets/icon/syeikh_2.png'),
    QariModel(
        id: '03',
        nama: 'Abdurrahman as Sudais',
        imageAsset: 'assets/icon/syeikh_3.png'),
    QariModel(
        id: '04',
        nama: 'Ibrahim-Al-Dossari',
        imageAsset: 'assets/icon/syeikh_4.png'),
    QariModel(
        id: '05',
        nama: "Misyari Rasyid Al-'Afasi",
        imageAsset: 'assets/icon/syeikh_5.png'),
  ];
}
