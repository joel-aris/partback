# VALIDIKA Mobile

Application mobile Flutter pour VALIDIKA (verification publique des pharmaciens en RDC). Phase 1 (MVP public) : accueil, recherche de pharmaciens, fiche pharmacien avec preuve cryptographique, verification par QR (saisie manuelle ou scan camera), connexion, inscription, verification email, mon compte, depot de candidature (avec scan OCR pour pre-remplir nom/prenom).

## Installation

```bash
cd mobile
flutter pub get
```

## Lancer l'application

Par defaut l'app pointe vers l'API de production sur le VPS (`http://72.62.1.143/api/v1`, voir `lib/core/api/api_client.dart`). Redefinir l'URL au lancement avec `--dart-define`, notamment pour developper contre un backend local :

```bash
# Backend Laravel local (php artisan serve, port configure dans backend/.env)
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8002/api/v1

# Emulateur Android contre un backend local (127.0.0.1 de la machine hote = 10.0.2.2 dans l'emulateur)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8002/api/v1

# Desktop Linux (meme reseau que le serveur local)
flutter run -d linux --dart-define=API_BASE_URL=http://127.0.0.1:8002/api/v1
```

L'API de production tourne encore en HTTP simple (pas de nom de domaine/certificat TLS pour l'instant) : `android/app/src/main/res/xml/network_security_config.xml` autorise explicitement le trafic en clair vers `72.62.1.143` uniquement, sinon Android bloque tout appel reseau sur les builds release/profile. A retirer une fois l'API servie en HTTPS.

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
- Le depot de candidature (`/candidacy`) est fonctionnel : formulaire complet, upload CV/lettre de motivation, et scan OCR optionnel pour pre-remplir nom/prenom depuis une photo de carte professionnelle/diplome/piece d'identite. Le suivi des candidatures est affiche dans "Mon compte" via `GET /auth/candidacies`.
- Le scan OCR (`/ocr/extract`) exige un token d'authentification cote backend, alors que le depot de candidature est concu comme un flux public (sans connexion). Un candidat non connecte qui utilise le bouton "Scanner un document" recevra donc une erreur d'autorisation au lieu d'un pre-remplissage — a trancher avec l'equipe backend (rendre `/ocr/extract` accessible sans connexion pour ce flux, ou exiger une connexion prealable avant de proposer le scan).
