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
      if (!mounted) return;
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
      if (!mounted) return;

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _movies = <MovieSummary>[];
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          _buildSearchBar(theme),
          Expanded(
            child: _buildContent(favoritesProvider, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: _controller,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search for a movie...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      _search('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FavoritesProvider favoritesProvider, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        Icons.error_outline_rounded,
        'An error occurred',
        _errorMessage!,
        theme,
      );
    }

    if (_movies.isEmpty) {
      if (_lastQuery.isEmpty) {
        return _buildMessageState(
          Icons.movie_filter_rounded,
          'Discover movies',
          'Enter a movie title to start your search.',
          theme,
        );
      } else {
        return _buildMessageState(
          Icons.search_off_rounded,
          'No results',
          'We found no movies matching "$_lastQuery".',
          theme,
        );
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return MovieListTile(
          movie: movie,
          isFavorite: favoritesProvider.isFavorite(movie.imdbId),
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(
                  movie: movie,
                  apiService: widget.apiService,
                ),
              ),
            );
          },
          onFavoriteToggle: () => favoritesProvider.toggleFavorite(movie),
        );
      },
    );
  }

  Widget _buildMessageState(IconData icon, String title, String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
