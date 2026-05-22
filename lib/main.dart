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
        'The .env file was not found. Using an empty configuration.');
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
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF673AB7),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontWeight: FontWeight.bold),
                titleLarge: TextStyle(fontWeight: FontWeight.w600),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF673AB7),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontWeight: FontWeight.bold),
                titleLarge: TextStyle(fontWeight: FontWeight.w600),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: HomeScreen(apiService: _apiService),
          );
        },
      ),
    );
  }
}
