import 'package:alquran_ku/core/usecase/usecase.dart';
import '../entities/qari_entity.dart';
import '../repositories/quran_repository.dart';

class SaveQariSelection extends UseCase<void, QariEntity> {
  final QuranRepository repository;

  SaveQariSelection(this.repository);

  @override
  Future<void> call(QariEntity qari) {
    return repository.saveQariSelection(qari);
  }
}
