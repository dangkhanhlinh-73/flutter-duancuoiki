import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/movie.dart';

class MovieService {
  Future<List<Movie>> _fetchList(String endpoint) async {
    final url =
        '${ApiConstants.baseUrl}$endpoint&api_key=${ApiConstants.apiKey}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((json) => Movie.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load movies');
  }

  Future<List<Movie>> fetchTrendingMovies({int page = 1}) =>
      _fetchList('/trending/movie/week?page=$page');

  Future<List<Movie>> fetchPopularMovies({int page = 1}) =>
      _fetchList('/movie/popular?page=$page');

  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) =>
      _fetchList('/movie/upcoming?page=$page');

  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) =>
      _fetchList('/movie/now_playing?page=$page');

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final encoded = Uri.encodeQueryComponent(query.trim());
    return _fetchList('/search/movie?query=$encoded&page=$page');
  }

  Future<String?> getTrailerKey(int movieId) async {
    final url =
        '${ApiConstants.baseUrl}/movie/$movieId/videos?api_key=${ApiConstants.apiKey}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      final trailer = results.firstWhere(
        (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
        orElse: () => null,
      );
      return trailer?['key'] as String?;
    }
    return null;
  }
}
