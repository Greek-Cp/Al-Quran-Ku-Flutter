import 'dart:convert';

import 'package:alquran_ku/core/constants/api_endpoints.dart';
import 'package:alquran_ku/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

import '../models/doa_model.dart';
import '../models/surah_detail_model.dart';
import '../models/surah_model.dart';

/// Remote data source — handles all HTTP API calls.
abstract class QuranRemoteDataSource {
  Future<List<SurahModel>> getSurahList();
  Future<SurahDetailModel> getSurahDetail(int surahNumber);
  Future<List<DoaModel>> getDoaList();
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final http.Client client;

  QuranRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SurahModel>> getSurahList() async {
    final response = await client.get(Uri.parse(ApiEndpoints.surahList));
    if (response.statusCode == 200) {
      final parsed = SurahListResponse.fromJson(json.decode(response.body));
      return parsed.data ?? [];
    } else {
      throw ServerException(
        message: 'Failed to load surah list',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<SurahDetailModel> getSurahDetail(int surahNumber) async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.surahDetailUrl(surahNumber)),
    );
    if (response.statusCode == 200) {
      return SurahDetailModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException(
        message: 'Failed to load surah detail',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<DoaModel>> getDoaList() async {
    final response = await client.get(Uri.parse(ApiEndpoints.doaList));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => DoaModel.fromJson(e)).toList();
    } else {
      throw ServerException(
        message: 'Failed to load doa list',
        statusCode: response.statusCode,
      );
    }
  }
}
