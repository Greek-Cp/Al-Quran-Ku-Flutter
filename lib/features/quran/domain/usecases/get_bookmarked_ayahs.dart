import 'package:alquran_ku/core/usecase/usecase.dart';
import '../repositories/quran_repository.dart';

class GetBookmarkedAyahs extends UseCase<List<String>, NoParams> {
  final QuranRepository repository;

  GetBookmarkedAyahs(this.repository);

  @override
  Future<List<String>> call(NoParams params) {
    return repository.getBookmarks();
  }
}
