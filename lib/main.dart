import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
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

  runApp(MyApp(favoritesProvider: favoritesProvider));
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    FavoritesProvider? favoritesProvider,
    OmdbApiService? apiService,
  })  : _favoritesProvider = favoritesProvider ?? FavoritesProvider(),
        _apiService = apiService ?? OmdbApiService(client: http.Client());

  final FavoritesProvider _favoritesProvider;
  final OmdbApiService _apiService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FavoritesProvider>.value(
      value: _favoritesProvider,
      child: MaterialApp(
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
        themeMode: ThemeMode.system,
        home: HomeScreen(apiService: _apiService),
      ),
    );
  }
}
