import 'package:alquran_ku/core/usecase/usecase.dart';
import '../entities/surah_entity.dart';
import '../repositories/quran_repository.dart';

class GetSurahList extends UseCase<List<SurahEntity>, NoParams> {
  final QuranRepository repository;

  GetSurahList(this.repository);

  @override
  Future<List<SurahEntity>> call(NoParams params) {
    return repository.getSurahList();
  }
}
