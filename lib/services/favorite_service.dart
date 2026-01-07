import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User user;

  FavoriteService(this.user);

  CollectionReference get _ref =>
      _db.collection('users').doc(user.uid).collection('favorites');

  Future<void> addFavorite(Movie movie) async {
    await _ref.doc(movie.id.toString()).set(movie.toMap());
  }

  Future<void> removeFavorite(int movieId) async {
    await _ref.doc(movieId.toString()).delete();
  }

  Stream<List<Movie>> getFavorites() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Movie.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
