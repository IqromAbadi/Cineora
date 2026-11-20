import 'dart:convert';
import 'dart:typed_data';

import 'package:cineora/app/data/providers/omdb_exception.dart';
import 'package:cineora/app/data/providers/omdb_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

OmdbProvider _provider(_StubAdapter adapter, {String apiKey = 'test-key'}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://www.omdbapi.com/'))
    ..httpClientAdapter = adapter;
  return OmdbProvider(dio: dio, apiKey: apiKey);
}

void main() {
  test('detail requests the given IMDb id with the full plot', () async {
    final adapter = _StubAdapter(200, {
      'Title': 'Interstellar',
      'imdbID': 'tt0816692',
      'Response': 'True',
    });

    final detail = await _provider(adapter).detail('tt0816692');

    final params = adapter.lastRequest!.queryParameters;
    expect(params['i'], 'tt0816692');
    expect(params['plot'], 'full');
    expect(params['apikey'], 'test-key');
    expect(detail.imdbId, 'tt0816692');
  });

  test('search sends query and page', () async {
    final adapter = _StubAdapter(200, {
      'Search': [],
      'totalResults': '0',
      'Response': 'True',
    });

    await _provider(adapter).search('batman', page: 3);

    final params = adapter.lastRequest!.queryParameters;
    expect(params['s'], 'batman');
    expect(params['page'], 3);
  });

  test('"Movie not found!" maps to notFound', () async {
    final adapter = _StubAdapter(200, {
      'Response': 'False',
      'Error': 'Movie not found!',
    });

    await expectLater(
      _provider(adapter).search('zzzzqq'),
      throwsA(isA<OmdbException>()
          .having((e) => e.failure, 'failure', OmdbFailure.notFound)),
    );
  });

  test('401 with invalid key body maps to invalidApiKey', () async {
    final adapter = _StubAdapter(401, {
      'Response': 'False',
      'Error': 'Invalid API key!',
    });

    await expectLater(
      _provider(adapter).search('batman'),
      throwsA(isA<OmdbException>()
          .having((e) => e.failure, 'failure', OmdbFailure.invalidApiKey)),
    );
  });

  test('an empty key fails fast without a network call', () async {
    final adapter = _StubAdapter(200, {'Response': 'True'});

    await expectLater(
      _provider(adapter, apiKey: '').search('batman'),
      throwsA(isA<OmdbException>()
          .having((e) => e.failure, 'failure', OmdbFailure.missingApiKey)),
    );
    expect(adapter.lastRequest, isNull);
  });
}
