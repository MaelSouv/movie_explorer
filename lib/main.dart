import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/omdb_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint(
        'Fichier .env introuvable. Utilisation d\'une configuration vide.');
  }

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  final themeProvider = ThemeProvider();

  runApp(MyApp(
    favoritesProvider: favoritesProvider,
    themeProvider: themeProvider,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    FavoritesProvider? favoritesProvider,
    ThemeProvider? themeProvider,
    OmdbApiService? apiService,
  })  : _favoritesProvider = favoritesProvider ?? FavoritesProvider(),
        _themeProvider = themeProvider ?? ThemeProvider(),
        _apiService = apiService ?? OmdbApiService(client: http.Client());

  final FavoritesProvider _favoritesProvider;
  final ThemeProvider _themeProvider;
  final OmdbApiService _apiService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritesProvider>.value(value: _favoritesProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Movie Explorer',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: HomeScreen(apiService: _apiService),
          );
        },
      ),
    );
  }
}
