import 'package:alquran_ku/core/usecase/usecase.dart';
import '../entities/qari_entity.dart';
import '../repositories/quran_repository.dart';

class GetQariSelection extends UseCase<QariEntity?, NoParams> {
  final QuranRepository repository;

  GetQariSelection(this.repository);

  @override
  Future<QariEntity?> call(NoParams params) {
    return repository.getQariSelection();
  }
}
