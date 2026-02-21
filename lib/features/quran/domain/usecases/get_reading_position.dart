import 'package:alquran_ku/core/usecase/usecase.dart';
import '../repositories/quran_repository.dart';

class GetReadingPosition extends UseCase<Map<String, dynamic>, NoParams> {
  final QuranRepository repository;

  GetReadingPosition(this.repository);

  @override
  Future<Map<String, dynamic>> call(NoParams params) {
    return repository.getReadingPosition();
  }
}
