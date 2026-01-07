import '../constants/api_constants.dart';
import '../constants/genres.dart';

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final String overview;
  final double rating; // Đây là vote_average từ API
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.overview,
    required this.rating,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Không có tiêu đề',
      posterPath: (json['poster_path'] ?? '') as String,
      backdropPath: (json['backdrop_path'] ?? '') as String,
      releaseDate: (json['release_date'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds:
          (json['genre_ids'] as List?)?.map((e) => e as int).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate,
      'overview': overview,
      'rating': rating,
      'genreIds': genreIds,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      posterPath: map['posterPath'] ?? '',
      backdropPath: map['backdropPath'] ?? '',
      releaseDate: map['releaseDate'] ?? '',
      overview: map['overview'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      genreIds: (map['genreIds'] as List?)?.map((e) => e as int).toList() ?? [],
    );
  }

  String get posterUrl => ApiConstants.posterUrl(posterPath);
  String get backdropUrl => ApiConstants.backdropUrl(backdropPath);
  String get genresString => Genres.getGenreNamesAsString(genreIds);
  String get formattedRating => rating.toStringAsFixed(1);

  // THÊM GETTER ĐỂ KHỚP VỚI CODE CŨ (nếu MovieDetailPage dùng voteAverage)
  double get voteAverage => rating;
}
