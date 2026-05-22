import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_detail.dart';
import '../models/movie_summary.dart';
import '../providers/favorites_provider.dart';
import '../services/omdb_api_service.dart';
import '../widgets/movie_list_tile.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.apiService,
  });

  final MovieSummary movie;
  final OmdbApiService apiService;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.apiService.fetchMovieDetail(widget.movie.imdbId);
  }

  void _reload() {
    setState(() {
      _detailFuture = widget.apiService.fetchMovieDetail(widget.movie.imdbId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.movie.imdbId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail du film'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.movie);
            },
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            color: Colors.amber,
            tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
        ],
      ),
      body: FutureBuilder<MovieDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(
              child: Text('Aucun detail disponible pour ce film.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: PosterThumbnail(
                    imageUrl: detail.posterUrl,
                    width: 180,
                    height: 270,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  detail.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Annee : ${detail.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  label: 'Description',
                  value: detail.plot,
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  label: 'Acteurs',
                  value: detail.actors,
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  label: 'Note IMDB',
                  value: detail.imdbRating,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(value),
      ],
    );
  }
}
