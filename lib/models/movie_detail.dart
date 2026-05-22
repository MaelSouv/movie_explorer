class MovieDetail {
  const MovieDetail({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.posterUrl,
    required this.plot,
    required this.actors,
    required this.imdbRating,
    required this.genre,
    required this.director,
    required this.runtime,
    required this.released,
  });

  final String imdbId;
  final String title;
  final String year;
  final String posterUrl;
  final String plot;
  final String actors;
  final String imdbRating;
  final String genre;
  final String director;
  final String runtime;
  final String released;

  bool get hasPoster => posterUrl.isNotEmpty && posterUrl != 'N/A';

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      imdbId: json['imdbID'] as String? ?? '',
      title: json['Title'] as String? ?? 'Unknown title',
      year: json['Year'] as String? ?? 'Unknown',
      posterUrl: json['Poster'] as String? ?? '',
      plot: json['Plot'] as String? ?? 'Description unavailable.',
      actors: json['Actors'] as String? ?? 'Actors unavailable.',
      imdbRating: json['imdbRating'] as String? ?? 'N/A',
      genre: json['Genre'] as String? ?? 'Unknown genre',
      director: json['Director'] as String? ?? 'Unknown director',
      runtime: json['Runtime'] as String? ?? 'Unknown duration',
      released: json['Released'] as String? ?? 'Unknown date',
    );
  }
}
