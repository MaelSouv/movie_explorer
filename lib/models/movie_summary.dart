class MovieSummary {
  const MovieSummary({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.posterUrl,
  });

  final String imdbId;
  final String title;
  final String year;
  final String posterUrl;

  bool get hasPoster => posterUrl.isNotEmpty && posterUrl != 'N/A';

  factory MovieSummary.fromJson(Map<String, dynamic> json) {
    return MovieSummary(
      imdbId: json['imdbID'] as String? ?? '',
      title: json['Title'] as String? ?? 'Titre inconnu',
      year: json['Year'] as String? ?? 'Inconnue',
      posterUrl: json['Poster'] as String? ?? '',
    );
  }

  factory MovieSummary.fromStorage(Map<String, dynamic> json) {
    return MovieSummary(
      imdbId: json['imdbId'] as String? ?? '',
      title: json['title'] as String? ?? 'Titre inconnu',
      year: json['year'] as String? ?? 'Inconnue',
      posterUrl: json['posterUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imdbId': imdbId,
      'title': title,
      'year': year,
      'posterUrl': posterUrl,
    };
  }
}
