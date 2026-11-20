enum OmdbFailure {
  missingApiKey,
  invalidApiKey,
  requestLimit,
  network,
  timeout,
  notFound,
  tooManyResults,
  server,
  cancelled,
}

class OmdbException implements Exception {
  const OmdbException(this.failure, [this.detail]);

  /// Maps OMDb's `Error` field to a typed failure.
  factory OmdbException.fromApiError(String? error) {
    final message = (error ?? '').toLowerCase();
    if (message.contains('not found') || message.contains('incorrect imdb')) {
      return OmdbException(OmdbFailure.notFound, error);
    }
    if (message.contains('too many results')) {
      return OmdbException(OmdbFailure.tooManyResults, error);
    }
    if (message.contains('api key')) {
      return OmdbException(OmdbFailure.invalidApiKey, error);
    }
    if (message.contains('limit')) {
      return OmdbException(OmdbFailure.requestLimit, error);
    }
    return OmdbException(OmdbFailure.server, error);
  }

  final OmdbFailure failure;
  final String? detail;

  bool get isCancelled => failure == OmdbFailure.cancelled;

  String get title => switch (failure) {
        OmdbFailure.missingApiKey => 'OMDb API key missing',
        OmdbFailure.invalidApiKey => 'OMDb rejected the API key',
        OmdbFailure.requestLimit => 'Daily request limit reached',
        OmdbFailure.network => 'You appear to be offline',
        OmdbFailure.timeout => 'OMDb is taking too long',
        OmdbFailure.notFound => 'Nothing found',
        OmdbFailure.tooManyResults => 'Too many matches',
        OmdbFailure.server => 'OMDb returned an error',
        OmdbFailure.cancelled => 'Request cancelled',
      };

  String get message => switch (failure) {
        OmdbFailure.missingApiKey =>
          'Add OMDB_API_KEY to .env, run build_runner, then restart the app.',
        OmdbFailure.invalidApiKey =>
          'Check the OMDB_API_KEY value in .env and rebuild.',
        OmdbFailure.requestLimit =>
          'The OMDb key has used its quota for today. Your favorites still work offline.',
        OmdbFailure.network =>
          'Check your connection and try again. Your favorites still work offline.',
        OmdbFailure.timeout => 'The server did not answer in time. Try again.',
        OmdbFailure.notFound => 'OMDb has no record of this title.',
        OmdbFailure.tooManyResults =>
          'Add a few more letters so OMDb can narrow the list.',
        OmdbFailure.server => detail ?? 'Something went wrong. Try again.',
        OmdbFailure.cancelled => '',
      };

  @override
  String toString() => 'OmdbException($failure, $detail)';
}
