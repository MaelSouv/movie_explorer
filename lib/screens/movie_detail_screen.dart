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
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder<MovieDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('No details available.'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(detail, isFavorite, favoritesProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(detail, theme),
                      const SizedBox(height: 16),
                      _buildGenreChips(detail.genre, theme),
                      const SizedBox(height: 24),
                      _buildInfoRow(detail, theme),
                      const SizedBox(height: 32),
                      _buildSection('Synopsis', detail.plot, theme),
                      const SizedBox(height: 24),
                      _buildSection('Director', detail.director, theme),
                      const SizedBox(height: 16),
                      _buildSection('Actors', detail.actors, theme),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<MovieDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => favoritesProvider.toggleFavorite(widget.movie),
            label: Text(isFavorite ? 'In favorites' : 'Add to favorites'),
            icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
            backgroundColor: isFavorite ? Colors.amber : theme.colorScheme.primary,
            foregroundColor: isFavorite ? Colors.black87 : theme.colorScheme.onPrimary,
          );
        },
      ),
    );
  }

  Widget _buildAppBar(MovieDetail detail, bool isFavorite, FavoritesProvider favoritesProvider) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'movie-poster-${detail.imdbId}',
              child: Image.network(
                detail.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.movie_rounded, size: 100),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MovieDetail detail, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail.year,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreChips(String genres, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.split(',').map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
          ),
          child: Text(
            genre.trim(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(MovieDetail detail, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoChip(Icons.star_rounded, detail.imdbRating, 'IMDB Rating', theme),
        _buildInfoChip(Icons.timer_outlined, detail.runtime, 'Duration', theme),
        _buildInfoChip(Icons.calendar_today_rounded, detail.released, 'Released', theme),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
