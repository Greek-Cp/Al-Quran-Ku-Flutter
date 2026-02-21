/// Single source of truth for all API endpoint URLs.
class ApiEndpoints {
  ApiEndpoints._();

  // eQuran API
  static const String baseEquran = 'https://equran.id/api/v2/';
  static const String surahList = '${baseEquran}surat';
  static const String surahDetail = '${baseEquran}surat/';
  static const String tafsir = '${baseEquran}tafsir/';

  // Doa API
  static const String baseDoa = 'https://doa-doa-api-ahmadramadhan.fly.dev/';
  static const String doaList = '${baseDoa}api';

  /// Build surah detail URL for a given surah number.
  static String surahDetailUrl(int surahNumber) => '$surahDetail$surahNumber';

  /// Build tafsir URL for a given surah number.
  static String tafsirUrl(int surahNumber) => '$tafsir$surahNumber';
}
