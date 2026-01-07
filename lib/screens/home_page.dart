import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../constants/genres.dart';
import 'movie_detail_page.dart';
import 'search_page.dart';
import 'login_page.dart';
import 'favorites_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data!;
                return Card(
                  color: Colors.grey.shade900,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        user.email?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: const Text(
                      'Tài khoản',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      user.email ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),
          _buildTile(
            Icons.dark_mode,
            'Chế độ tối',
            'Đang bật',
            trailing: const Switch(value: true, onChanged: null),
          ),
          _buildTile(Icons.language, 'Ngôn ngữ', 'Tiếng Việt'),
          _buildTile(Icons.info_outline, 'Phiên bản', 'MovieX 1.2.0 (2026)'),
          const SizedBox(height: 40),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovieService _movieService = MovieService();

  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _upcomingMovies = [];
  List<int> _selectedGenres = [];
  List<Movie> _reviewMovies = [];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Khám phá', 'icon': Icons.explore},
    {'title': 'Đánh giá', 'icon': Icons.rate_review},
    {'title': 'Nền tảng xem', 'icon': Icons.tv},
    {'title': 'Yêu thích', 'icon': Icons.favorite},
  ];

  int _currentIndex = 0;

  bool _isLoadingDiscover = true;

  @override
  void initState() {
    super.initState();
    _fetchDiscoverData();
    _fetchReviewsData();
  }

  Future<void> _fetchDiscoverData() async {
    setState(() => _isLoadingDiscover = true);
    await Future.wait([_fetchTrending(), _fetchNowPlaying(), _fetchUpcoming()]);
    setState(() => _isLoadingDiscover = false);
  }

  Future<void> _fetchReviewsData() async {
    final result = await _movieService.fetchPopularMovies();
    setState(() {
      _reviewMovies = result.take(20).toList();
    });
  }

  Future<void> _fetchTrending() async {
    final result = await _movieService.fetchTrendingMovies();
    setState(() {
      _trendingMovies = result.take(10).toList();
    });
  }

  Future<void> _fetchNowPlaying() async {
    final result = await _movieService.fetchNowPlayingMovies();
    setState(() {
      _nowPlayingMovies = result;
    });
  }

  Future<void> _fetchUpcoming() async {
    final result = await _movieService.fetchUpcomingMovies();
    setState(() {
      _upcomingMovies = result.take(12).toList();
    });
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    if (_selectedGenres.isEmpty) return movies;
    return movies
        .where((m) => m.genreIds.any((id) => _selectedGenres.contains(id)))
        .toList();
  }

  // FILTER thể loại
  Widget _buildGenres() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children: Genres.allGenres.entries.map((entry) {
          final int genreId = entry.key;
          final String genreName = entry.value;
          final bool isSelected = _selectedGenres.contains(genreId);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedGenres.remove(genreId);
                } else {
                  _selectedGenres.add(genreId);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.grey.shade800.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade600,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Text(
                genreName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Movie> movies,
    required Widget Function(List<Movie>) builder,
  }) {
    final filtered = _filterMovies(movies);
    if (filtered.isEmpty && _selectedGenres.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Không tìm thấy phim phù hợp',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        builder(filtered),
      ],
    );
  }

  Widget _buildCarousel(List<Movie> movies) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 260,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.52,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: movies.map((movie) {
        return Builder(
          builder: (context) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    movie.backdropUrl.isNotEmpty
                        ? movie.backdropUrl
                        : movie.posterUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.formattedRating,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            movie.releaseDate.split('-')[0],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
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
      }).toList(),
    );
  }

  Widget _buildDiscoverBody() {
    if (_isLoadingDiscover) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchDiscoverData,
      color: Colors.orange,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildGenres(),
            _buildSection(
              title: 'Trending Today',
              movies: _trendingMovies,
              builder: (movies) => _buildCarousel(movies),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Đang Chiếu',
              movies: _nowPlayingMovies,
              builder: (movies) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, i) {
                  final m = movies[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(movie: m),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              m.posterUrl,
                              width: 90,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ra mắt: ${m.releaseDate}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      m.formattedRating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
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
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Sắp Chiếu',
              movies: _upcomingMovies,
              builder: (movies) => _buildCarousel(movies),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsBody() {
    if (_reviewMovies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviewMovies.length,
      itemBuilder: (context, i) {
        final m = _reviewMovies[i];
        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailPage(movie: m)),
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                m.posterUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              m.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Rating: ${m.formattedRating} ⭐',
              style: const TextStyle(color: Colors.orange),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProvidersBody() {
    final providers = [
      {
        'name': 'Netflix',
        'logo':
            'https://store-images.s-microsoft.com/image/apps.56161.9007199266246365.1d5a6a53-3c49-4f80-95d7-78d76b0e05d0.a3e87fea-e03e-4c0a-8f26-9ecef205fa7b',
      },
      {
        'name': 'Disney+',
        'logo':
            'https://static-assets.bamgrid.com/product/disneyplus/images/share-default.8bf3102623e935e7bc126df36b956b98.jpg',
      },
      {
        'name': 'Apple TV+',
        'logo':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/AppleTVLogo.svg/2048px-AppleTVLogo.svg.png',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: providers.length,
      itemBuilder: (context, i) {
        final p = providers[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                p['logo']!,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.tv, size: 60, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                p['name']!,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDiscoverBody();
      case 1:
        return _buildReviewsBody();
      case 2:
        return _buildProvidersBody();
      case 3:
        return const FavoritesPage();
      default:
        return _buildDiscoverBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _menuItems[_currentIndex]['title'],
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'MovieX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ..._menuItems.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _currentIndex == i;
              return ListTile(
                leading: Icon(
                  item['icon'],
                  color: selected ? Colors.orange : Colors.white70,
                ),
                title: Text(
                  item['title'],
                  style: TextStyle(
                    color: selected ? Colors.orange : Colors.white,
                    fontSize: 17,
                  ),
                ),
                selected: selected,
                selectedTileColor: Colors.orange.withOpacity(0.15),
                onTap: () {
                  setState(() => _currentIndex = i);
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text(
                'Cài đặt',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _getBody(),
    );
  }
}
