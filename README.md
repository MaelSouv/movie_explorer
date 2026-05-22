# Movie Explorer

Application Flutter utilisant l'API OMDb pour :

- rechercher des films
- afficher leurs details
- gerer une liste de favoris partagee entre les ecrans

## Fonctionnalites

- recherche avec champ texte et bouton `Rechercher`
- affichage des resultats : titre, annee, affiche
- ecran de detail : titre, description, acteurs, note IMDb
- favoris partages entre `Recherche`, `Detail` et `Favoris`
- persistance locale des favoris avec `shared_preferences`
- debounce natif sur la recherche
- prise en charge du mode sombre via `ThemeMode.system`

## Configuration

1. Copier `.env.example` vers `.env`
2. Remplacer la valeur par votre cle API OMDb :

```env
OMDB_API_KEY=VOTRE_CLE_API
```

3. Installer les dependances :

```bash
flutter pub get
```

4. Lancer l'application :

```bash
flutter run
```

## Architecture

- `lib/services`: appels HTTP vers OMDb
- `lib/models`: modeles de donnees
- `lib/providers`: gestion d'etat des favoris
- `lib/screens`: ecrans de l'application
- `lib/widgets`: composants UI reutilisables
