class Genres {
  Genres._();

  static const Map<int, String> allGenres = {
    28: 'Hành Động',
    12: 'Phiêu Lưu',
    16: 'Hoạt Hình',
    35: 'Hài',
    80: 'Tội Phạm',

    18: 'Chính Kịch',
    10751: 'Gia Đình',
    14: 'Kỳ Ảo',

    27: 'Kinh Dị',

    9648: 'Bí Ẩn',
    10749: 'Lãng Mạn',
    878: 'KH Viễn Tưởng',
    53: 'Gay Cấn',
    10752: 'Chiến Tranh',
  };

  static List<String> getGenreNames(List<int> genreIds) {
    return genreIds
        .where((id) => allGenres.containsKey(id))
        .map((id) => allGenres[id]!)
        .toList();
  }

  static String getGenreNamesAsString(List<int> genreIds) {
    final names = getGenreNames(genreIds);
    return names.isEmpty ? 'Không rõ' : names.join(', ');
  }
}
