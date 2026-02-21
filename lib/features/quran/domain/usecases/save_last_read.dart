import 'package:alquran_ku/core/usecase/usecase.dart';
import '../entities/last_read_entity.dart';
import '../repositories/quran_repository.dart';

class SaveLastRead extends UseCase<void, LastReadEntity> {
  final QuranRepository repository;

  SaveLastRead(this.repository);

  @override
  Future<void> call(LastReadEntity data) {
    return repository.saveLastRead(data);
  }
}
