/// Domain entity for a Doa (prayer/supplication).
class DoaEntity {
  final String id;
  final String judulDoa;
  final String ayat;
  final String latin;
  final String arti;

  const DoaEntity({
    required this.id,
    required this.judulDoa,
    required this.ayat,
    required this.latin,
    required this.arti,
  });
}
