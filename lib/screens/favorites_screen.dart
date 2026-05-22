import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../services/omdb_api_service.dart';
import '../widgets/movie_list_tile.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.apiService,
  });

  final OmdbApiService apiService;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final favorites = favoritesProvider.favorites;

        if (favorites.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Aucun favori pour le moment.\nAjoutez des films depuis la recherche.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final movie = favorites[index];

            return MovieListTile(
              movie: movie,
              isFavorite: true,
              onFavoriteToggle: () {
                favoritesProvider.removeFavorite(movie.imdbId);
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MovieDetailScreen(
                      movie: movie,
                      apiService: apiService,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
