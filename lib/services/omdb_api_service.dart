import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie_detail.dart';
import '../models/movie_summary.dart';

class OmdbApiException implements Exception {
  const OmdbApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OmdbApiService {
  OmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _apiKey {
    final key = dotenv.env['OMDB_API_KEY']?.trim() ?? '';

    if (key.isEmpty || key == 'YOUR_API_KEY_HERE') {
      throw const OmdbApiException(
        'Missing OMDb API key. Add `OMDB_API_KEY` to your `.env` file.',
      );
    }

    return key;
  }

  Future<List<MovieSummary>> searchMovies(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final data = await _getData({'apikey': _apiKey, 's': trimmedQuery});

    if (data['Response'] == 'False') {
      if (data['Error'] == 'Movie not found!') {
        return [];
      }

      throw OmdbApiException(
        data['Error'] as String? ?? 'Unknown error during search.',
      );
    }

    final items = (data['Search'] as List<dynamic>? ?? <dynamic>[]);
    return items
        .map((item) => MovieSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MovieDetail> fetchMovieDetail(String imdbId) async {
    final data = await _getData({'apikey': _apiKey, 'i': imdbId});

    if (data['Response'] == 'False') {
      throw OmdbApiException(
        data['Error'] as String? ??
            'Unable to load movie details.',
      );
    }

    return MovieDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> _getData(
      Map<String, String> queryParameters) async {
    final uri = Uri.https('www.omdbapi.com', '/', queryParameters);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw OmdbApiException(
        'HTTP error ${response.statusCode}. Unable to contact OMDb.',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const OmdbApiException('Invalid response received from OMDb.');
    }
  }
}
