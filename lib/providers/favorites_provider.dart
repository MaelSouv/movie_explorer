import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_summary.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'favorite_movies';

  final List<MovieSummary> _favorites = <MovieSummary>[];
  SharedPreferences? _preferences;

  UnmodifiableListView<MovieSummary> get favorites =>
      UnmodifiableListView<MovieSummary>(_favorites);

  bool isFavorite(String imdbId) {
    return _favorites.any((movie) => movie.imdbId == imdbId);
  }

  Future<void> loadFavorites() async {
    _preferences ??= await SharedPreferences.getInstance();
    final storedMovies = _preferences?.getStringList(_storageKey) ?? <String>[];

    _favorites
      ..clear()
      ..addAll(
        storedMovies.map(
          (movieJson) => MovieSummary.fromStorage(
            jsonDecode(movieJson) as Map<String, dynamic>,
          ),
        ),
      );

    notifyListeners();
  }

  Future<void> toggleFavorite(MovieSummary movie) async {
    if (isFavorite(movie.imdbId)) {
      await removeFavorite(movie.imdbId);
      return;
    }

    await addFavorite(movie);
  }

  Future<void> addFavorite(MovieSummary movie) async {
    if (isFavorite(movie.imdbId)) {
      return;
    }

    _favorites.insert(0, movie);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(String imdbId) async {
    _favorites.removeWhere((movie) => movie.imdbId == imdbId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    _preferences ??= await SharedPreferences.getInstance();
    final encodedMovies =
        _favorites.map((movie) => jsonEncode(movie.toJson())).toList();

    await _preferences!.setStringList(_storageKey, encodedMovies);
  }
}
