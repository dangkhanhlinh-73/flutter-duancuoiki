class ApiConstants {
  ApiConstants._();

  static const String apiKey = 'b29d375efb5430e03905ab28300b8b62';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  static const String posterBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';

  static String posterUrl(String path) =>
      path.isEmpty ? '' : '$posterBaseUrl$path';
  static String backdropUrl(String path) =>
      path.isEmpty ? '' : '$backdropBaseUrl$path';

  static String backdropOrPoster(String backdropPath, String posterPath) {
    return backdropPath.isNotEmpty
        ? backdropUrl(backdropPath)
        : posterUrl(posterPath);
  }
}
