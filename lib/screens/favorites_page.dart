import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/movie.dart';
import 'movie_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late FavoriteService _favService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _favService = FavoriteService(user);
    }
  }

  Future<void> _removeFavorite(Movie movie) async {
    await _favService.removeFavorite(movie.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${movie.title}" đã được xóa khỏi danh sách yêu thích',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem yêu thích')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Phim Yêu Thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _favService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
                strokeWidth: 5,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi tải dữ liệu: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 120,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Chưa có phim yêu thích nào',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hãy nhấn vào biểu tượng trái tim ♥ trên trang chi tiết phim để thêm nhé!',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailPage(movie: movie),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          movie.posterUrl,
                          width: 110,
                          height: 160,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 110,
                              height: 160,
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 160,
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.local_movies,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.releaseDate.isEmpty
                                  ? 'Chưa có ngày phát hành'
                                  : movie.releaseDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  movie.formattedRating,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.red,
                          size: 32,
                        ),
                        onPressed: () => _removeFavorite(movie),
                        tooltip: 'Xóa khỏi yêu thích',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
