import 'package:alquran_ku/core/usecase/usecase.dart';
import '../repositories/quran_repository.dart';

class SaveBookmarkAyah extends UseCase<void, BookmarkParams> {
  final QuranRepository repository;

  SaveBookmarkAyah(this.repository);

  @override
  Future<void> call(BookmarkParams params) {
    return repository.toggleBookmark(
      surah: params.surah,
      ayah: params.ayah,
    );
  }
}

class BookmarkParams {
  final int surah;
  final int ayah;

  const BookmarkParams({required this.surah, required this.ayah});
}
