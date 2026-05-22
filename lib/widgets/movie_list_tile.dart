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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: PosterThumbnail(imageUrl: movie.posterUrl),
        title: Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Annee : ${movie.year}'),
        trailing: IconButton(
          onPressed: onFavoriteToggle,
          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          color: Colors.amber,
          tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
        ),
        onTap: onTap,
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
    final borderRadius = BorderRadius.circular(8);

    if (!_hasImage) {
      return _PosterPlaceholder(width: width, height: height);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _PosterPlaceholder(width: width, height: height);
        },
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined),
    );
  }
}
