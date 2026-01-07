import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../constants/genres.dart';
import '../services/favorite_service.dart';
import '../services/movie_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late FavoriteService _favService;
  bool _isFavorite = false;
  String? _trailerKey;
  bool _loadingTrailer = true;

  //  BIẾN MỚI CHO DỊCH TỰ ĐỘNG
  String _vietnameseOverview = 'Đang tải...';
  bool _isTranslating = true;

  final _onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.vietnamese,
  );

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _favService = FavoriteService(user);

    // Đồng bộ trạng thái yêu thích từ Firestore
    _favService.getFavorites().listen((movies) {
      if (mounted) {
        setState(() {
          _isFavorite = movies.any((m) => m.id == widget.movie.id);
        });
      }
    });

    _loadTrailer();
    _translateOverview(); // GỌI DỊCH TỰ ĐỘNG
  }

  Future<void> _loadTrailer() async {
    final key = await MovieService().getTrailerKey(widget.movie.id);
    if (mounted) {
      setState(() {
        _trailerKey = key;
        _loadingTrailer = false;
      });
    }
  }

  // HÀM DỊCH TỰ ĐỘNG
  Future<void> _translateOverview() async {
    final String manualViet = getVietnameseOverview();
    if (manualViet.isNotEmpty) {
      //  bản dịch thủ công → dùng luôn (ưu tiên chất lượng cao)
      setState(() {
        _vietnameseOverview = manualViet;
        _isTranslating = false;
      });
      return;
    }

    if (widget.movie.overview.isEmpty) {
      setState(() {
        _vietnameseOverview = 'Không có tóm tắt.';
        _isTranslating = false;
      });
      return;
    }

    setState(() {
      _vietnameseOverview = 'Đang dịch...';
    });

    try {
      final String translated = await _onDeviceTranslator.translateText(
        widget.movie.overview,
      );
      if (mounted) {
        setState(() {
          _vietnameseOverview = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vietnameseOverview = 'Không thể dịch (không có mạng).';
          _isTranslating = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final bool wasFavorite = _isFavorite;

    setState(() {
      _isFavorite = !wasFavorite;
    });

    try {
      if (!wasFavorite) {
        await _favService.addFavorite(widget.movie);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm vào Yêu thích ❤️')),
          );
        }
      } else {
        await _favService.removeFavorite(widget.movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa khỏi Yêu thích')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = wasFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi mạng, không thể cập nhật yêu thích!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchTrailer() async {
    if (_trailerKey == null) return;
    final url = Uri.parse('https://www.youtube.com/watch?v=$_trailerKey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String getVietnameseOverview() {
    final title = widget.movie.title.toLowerCase();

    if (title.contains('zootopia 2')) {
      return 'Tại thành phố Zootopia, cô thỏ Judy Hopps và cáo Nick Wilde nay là đối tác cảnh sát phải truy lùng một con rắn bí ẩn gây hỗn loạn, buộc họ phải cải trang và khám phá những khu vực mới của thành phố.';
    }
    return '';
  }

  @override
  void dispose() {
    _onDeviceTranslator.close(); // Giải phóng translator
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String manualViet = getVietnameseOverview();
    final String englishOverview = widget.movie.overview.isNotEmpty
        ? widget.movie.overview
        : 'Không có mô tả.';

    final backdropUrl = widget.movie.backdropUrl.isNotEmpty
        ? widget.movie.backdropUrl
        : widget.movie.posterUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(backdropUrl, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.movie.posterUrl,
                        width: 160,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.movie.releaseDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 36),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.movie.rating.toStringAsFixed(1)} / 10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 28,
                          ),
                          label: Text(
                            _isFavorite
                                ? 'Xóa khỏi Yêu thích'
                                : 'Thêm vào Yêu thích',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_loadingTrailer)
                        const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(color: Colors.red),
                        )
                      else if (_trailerKey != null)
                        ElevatedButton(
                          onPressed: _launchTrailer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    'Thể loại',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: Genres.getGenreNames(widget.movie.genreIds).map((
                      name,
                    ) {
                      return Chip(
                        label: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  // === TÓM TẮT TIẾNG VIỆT - ƯU TIÊN THỦ CÔNG, SAU ĐÓ DỊCH TỰ ĐỘNG ===
                  const Text(
                    'Tóm tắt (Tiếng Việt)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isTranslating
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Đang dịch tự động...',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          manualViet.isNotEmpty
                              ? manualViet
                              : _vietnameseOverview,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                  const SizedBox(height: 32),

                  const Text(
                    'Original Overview (English)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    englishOverview,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
