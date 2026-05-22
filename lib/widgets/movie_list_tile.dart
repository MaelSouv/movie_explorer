import 'package:flutter/material.dart';

import '../models/movie_summary.dart';

class MovieListTile extends StatelessWidget {
  const MovieListTile({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final MovieSummary movie;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'movie-poster-${movie.imdbId}',
                        child: PosterThumbnail(
                          imageUrl: movie.posterUrl,
                          width: 70,
                          height: 100,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                movie.year,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onFavoriteToggle,
                        icon: Icon(
                          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 32,
                        ),
                        color: isFavorite ? Colors.amber : theme.colorScheme.outline.withOpacity(0.6),
                        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PosterThumbnail extends StatelessWidget {
  const PosterThumbnail({
    super.key,
    required this.imageUrl,
    this.width = 56,
    this.height = 84,
  });

  final String imageUrl;
  final double width;
  final double height;

  bool get _hasImage => imageUrl.isNotEmpty && imageUrl != 'N/A';

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    if (!_hasImage) {
      return _PosterPlaceholder(width: width, height: height, borderRadius: borderRadius);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _PosterPlaceholder(width: width, height: height, borderRadius: borderRadius);
          },
          errorBuilder: (_, __, ___) {
            return _PosterPlaceholder(width: width, height: height, borderRadius: borderRadius);
          },
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_filter_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: width * 0.4,
      ),
    );
  }
}
