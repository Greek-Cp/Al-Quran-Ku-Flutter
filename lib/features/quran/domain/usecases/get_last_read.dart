import 'package:alquran_ku/core/usecase/usecase.dart';
import '../entities/last_read_entity.dart';
import '../repositories/quran_repository.dart';

class GetLastRead extends UseCase<LastReadEntity?, NoParams> {
  final QuranRepository repository;

  GetLastRead(this.repository);

  @override
  Future<LastReadEntity?> call(NoParams params) {
    return repository.getLastRead();
  }
}
