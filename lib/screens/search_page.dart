import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'movie_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _service = MovieService();
  List<Movie> _results = [];
  bool _loading = false;
  bool _searched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final list = await _service.searchMovies(query);
    setState(() {
      _results = list;
      _loading = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm phim...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 600),
              () => _search(value),
            );
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _results = [];
                  _searched = false;
                });
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : !_searched
          ? const Center(
              child: Text(
                'Nhập tên phim để tìm kiếm',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : _results.isEmpty
          ? const Center(
              child: Text(
                'Không tìm thấy kết quả',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final movie = _results[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailPage(movie: movie),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            movie.posterUrl,
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                movie.releaseDate,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.yellow),
                                  Text(
                                    movie.formattedRating,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
