# VALIDIKA Mobile

Application mobile Flutter pour VALIDIKA (verification publique des pharmaciens en RDC). Phase 1 (MVP public) : accueil, recherche de pharmaciens, fiche pharmacien avec preuve cryptographique, verification par QR (saisie manuelle ou scan camera), connexion, inscription, verification email, mon compte.

## Installation

```bash
cd mobile
flutter pub get
```

## Lancer l'application

Par defaut l'app pointe vers `http://127.0.0.1:8002/api/v1` (serveur Laravel local, `php artisan serve` avec le port configure dans `backend/.env`). Redefinir l'URL au lancement avec `--dart-define` :

```bash
# Emulateur Android (127.0.0.1 de la machine hote = 10.0.2.2 dans l'emulateur)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8002/api/v1

# Appareil physique / build de production
flutter run --dart-define=API_BASE_URL=https://api.validika.cd/api/v1

# Desktop Linux (meme reseau que le serveur local)
flutter run -d linux
```

Pour tester rapidement sans device/emulateur (Android/iOS non disponibles dans certains environnements), un build web fonctionne aussi :

```bash
flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8002/api/v1
cd build/web && python3 -m http.server 5173
```

Le backend restreint les origines CORS (`backend/config/cors.php`) : servez le build web sur un port deja autorise (5173-5175) ou ajoutez le votre a `FRONTEND_URLS` en local.

## Tests

```bash
flutter analyze
flutter test
```

`flutter test` ne couvre que la logique pure (extraction des messages d'erreur API). Dans cet environnement de developpement, tout widget test qui monte `EasyLocalization` (meme minimal, sans Riverpod ni reseau) reste bloque indefiniment au premier `pump()` — probleme d'integration entre `easy_localization` et le runner `flutter_tester` sur cette version de Flutter, independant du code de l'application. Le parcours complet (accueil, recherche, fiche pharmacien avec preuve crypto, verification QR manuelle, navigation) a ete verifie manuellement via un build web reel contre le backend Laravel, voir capture dans la session de developpement.

## Notes

- Le token d'authentification est stocke via `flutter_secure_storage` (Keychain/Keystore), jamais en clair.
- Les erreurs API sont toujours affichees telles que renvoyees par le backend (jamais de "Request failed with status code X"), voir `lib/core/api/api_exception.dart`.
- Le scan de QR code (`mobile_scanner`) fonctionne sur Android/iOS/web ; non teste sur desktop Linux dans cet environnement (pas de webcam/emulateur disponible). A valider sur un appareil reel avant mise en production.
- Traductions (`assets/translations/`) : francais et anglais relus avec attention ; lingala et swahili en confiance moyenne ; kikongo et tshiluba sont des premieres versions a faire relire par un locuteur natif avant publication.
- Portee de cette session (Phase 1 uniquement) : le depot de candidature affiche un ecran "bientot disponible" (`/candidacy`) — la soumission complete avec upload de documents est prevue en Phase 2, avec le suivi des candidatures deja affiche dans "Mon compte" (l'endpoint `GET /auth/candidacies` existe cote backend).
