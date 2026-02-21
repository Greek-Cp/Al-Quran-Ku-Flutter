import 'package:alquran_ku/core/usecase/usecase.dart';
import '../entities/surah_detail_entity.dart';
import '../repositories/quran_repository.dart';

class GetSurahDetail extends UseCase<SurahDetailEntity, int> {
  final QuranRepository repository;

  GetSurahDetail(this.repository);

  @override
  Future<SurahDetailEntity> call(int surahNumber) {
    return repository.getSurahDetail(surahNumber);
  }
}
