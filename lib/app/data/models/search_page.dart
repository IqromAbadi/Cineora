import 'movie_summary.dart';

class SearchPage {
  const SearchPage({required this.items, required this.totalResults});

  factory SearchPage.fromJson(Map<String, dynamic> json) {
    final raw = json['Search'];
    final items = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => MovieSummary.fromJson(Map<String, dynamic>.from(e)))
            .where((m) => m.imdbId.isNotEmpty)
            .toList(growable: false)
        : const <MovieSummary>[];
    return SearchPage(
      items: items,
      totalResults: int.tryParse('${json['totalResults']}') ?? items.length,
    );
  }

  static const pageSize = 10;

  final List<MovieSummary> items;
  final int totalResults;
}
