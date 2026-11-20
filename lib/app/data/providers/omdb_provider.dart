import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import '../models/movie_detail.dart';
import '../models/search_page.dart';
import 'omdb_exception.dart';

class OmdbProvider {
  OmdbProvider({Dio? dio, String? apiKey, String? baseUrl})
      : _apiKey = apiKey ?? Env.omdbApiKey,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Env.omdbBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;
  final String _apiKey;

  Future<SearchPage> search(
    String query, {
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final json = await _get(
      {'s': query, 'page': page},
      cancelToken: cancelToken,
    );
    return SearchPage.fromJson(json);
  }

  Future<MovieDetail> detail(String imdbId, {CancelToken? cancelToken}) async {
    final json = await _get(
      {'i': imdbId, 'plot': 'full'},
      cancelToken: cancelToken,
    );
    return MovieDetail.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(
    Map<String, dynamic> params, {
    CancelToken? cancelToken,
  }) async {
    if (_apiKey.isEmpty) {
      throw const OmdbException(OmdbFailure.missingApiKey);
    }
    try {
      final response = await _dio.get<dynamic>(
        '',
        queryParameters: {...params, 'apikey': _apiKey},
        cancelToken: cancelToken,
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Map<String, dynamic> _unwrap(Object? data) {
    if (data is! Map) {
      throw const OmdbException(OmdbFailure.server, 'Unexpected response.');
    }
    final json = Map<String, dynamic>.from(data);
    if ('${json['Response']}'.toLowerCase() == 'false') {
      throw OmdbException.fromApiError(json['Error']?.toString());
    }
    return json;
  }

  OmdbException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.cancel:
        return const OmdbException(OmdbFailure.cancelled);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const OmdbException(OmdbFailure.timeout);
      case DioExceptionType.connectionError:
        return const OmdbException(OmdbFailure.network);
      case DioExceptionType.badResponse:
        // OMDb answers 401 with a JSON body for bad keys and exhausted quotas.
        final data = e.response?.data;
        if (data is Map && data['Error'] != null) {
          return OmdbException.fromApiError(data['Error'].toString());
        }
        return OmdbException(
          OmdbFailure.server,
          'Server responded with ${e.response?.statusCode}.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const OmdbException(OmdbFailure.network);
    }
  }
}
