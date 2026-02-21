import 'package:alquran_ku/core/usecase/usecase.dart';
import '../repositories/quran_repository.dart';

class GetAudioSourceForAyah extends UseCase<String, AudioSourceParams> {
  final QuranRepository repository;

  GetAudioSourceForAyah(this.repository);

  @override
  Future<String> call(AudioSourceParams params) {
    return repository.resolveAyahAudioSource(
      url: params.url,
      offlineAllowed: params.offlineAllowed,
    );
  }
}

class AudioSourceParams {
  final String url;
  final bool offlineAllowed;

  const AudioSourceParams({
    required this.url,
    this.offlineAllowed = true,
  });
}
