import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_summary.dart';
import '../providers/favorites_provider.dart';
import '../services/omdb_api_service.dart';
import '../widgets/movie_list_tile.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.apiService,
  });

  final OmdbApiService apiService;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  bool _isLoading = false;
  String? _errorMessage;
  String _lastQuery = '';
  List<MovieSummary> _movies = <MovieSummary>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(_controller.text);
    });
  }

  Future<void> _search(String rawQuery) async {
    final query = rawQuery.trim();

    if (query.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lastQuery = '';
        _errorMessage = null;
        _movies = <MovieSummary>[];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lastQuery = query;
    });

    try {
      final movies = await widget.apiService.searchMovies(query);
      if (!mounted) {
        return;
      }

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _movies = <MovieSummary>[];
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    _debounce?.cancel();
    _search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitSearch(),
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un film',
                    hintText: 'Ex: Batman',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _submitSearch,
                child: const Text('Rechercher'),
              ),
            ],
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        Expanded(child: _buildBody(favoritesProvider)),
      ],
    );
  }

  Widget _buildBody(FavoritesProvider favoritesProvider) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitSearch,
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lastQuery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Saisissez un titre et lancez une recherche.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_movies.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aucun film trouve pour "$_lastQuery".',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];

        return MovieListTile(
          movie: movie,
          isFavorite: favoritesProvider.isFavorite(movie.imdbId),
          onFavoriteToggle: () {
            favoritesProvider.toggleFavorite(movie);
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MovieDetailScreen(
                  movie: movie,
                  apiService: widget.apiService,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
