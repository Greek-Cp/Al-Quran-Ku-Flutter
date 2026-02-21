import 'package:alquran_ku/core/usecase/usecase.dart';
import '../repositories/quran_repository.dart';

class SaveReadingPosition extends UseCase<void, ReadingPositionParams> {
  final QuranRepository repository;

  SaveReadingPosition(this.repository);

  @override
  Future<void> call(ReadingPositionParams params) {
    return repository.saveReadingPosition(
      surahNumber: params.surahNumber,
      ayahNumber: params.ayahNumber,
      scrollPosition: params.scrollPosition,
    );
  }
}

class ReadingPositionParams {
  final int surahNumber;
  final int ayahNumber;
  final double scrollPosition;

  const ReadingPositionParams({
    required this.surahNumber,
    required this.ayahNumber,
    required this.scrollPosition,
  });
}
