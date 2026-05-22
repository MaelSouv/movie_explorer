class MovieDetail {
  const MovieDetail({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.posterUrl,
    required this.plot,
    required this.actors,
    required this.imdbRating,
  });

  final String imdbId;
  final String title;
  final String year;
  final String posterUrl;
  final String plot;
  final String actors;
  final String imdbRating;

  bool get hasPoster => posterUrl.isNotEmpty && posterUrl != 'N/A';

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      imdbId: json['imdbID'] as String? ?? '',
      title: json['Title'] as String? ?? 'Titre inconnu',
      year: json['Year'] as String? ?? 'Inconnue',
      posterUrl: json['Poster'] as String? ?? '',
      plot: json['Plot'] as String? ?? 'Description indisponible.',
      actors: json['Actors'] as String? ?? 'Acteurs indisponibles.',
      imdbRating: json['imdbRating'] as String? ?? 'N/A',
    );
  }
}
