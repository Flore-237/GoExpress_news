# GoExpress Mobile

Application mobile de réservation de billets de bus développée avec Flutter et Firebase.

## Fonctionnalités

- Réservation de billets de bus en ligne
- Sélection d'agences de voyage
- Recherche de voyages par destination et date
- Paiement mobile intégré (Mobile Money, Orange Money)
- Interface utilisateur moderne et intuitive
- Génération de tickets PDF
- Notifications en temps réel
- Historique des réservations

## Configuration requise

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: >=3.0.0 <4.0.0
- Android Studio / VS Code
- Firebase CLI

## Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/votre-username/GoExpress_Mobile.git
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Configurez Firebase :
   - Créez un projet dans la [Console Firebase](https://console.firebase.google.com/)
   - Téléchargez le fichier `google-services.json`
   - Placez-le dans `android/app/`

4. Lancez l'application :
```bash
flutter run
```

## Structure du projet

```
lib/
├── core/
│   ├── services/      # Services (auth, database, etc.)
│   └── widgets/       # Widgets réutilisables
├── features/
│   ├── auth/         # Authentification
│   ├── home/         # Écran d'accueil
│   ├── booking/      # Réservation
│   └── profile/      # Profil utilisateur
└── shared/
    ├── models/       # Modèles de données
    └── providers/    # Providers Riverpod
```

## Technologies utilisées

- Flutter & Dart
- Firebase (Auth, Firestore, Functions)
- Riverpod pour la gestion d'état
- PDF pour la génération de tickets
- Stripe pour les paiements

## Contribution

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Contact

Votre Nom - [@votre-twitter](https://twitter.com/votre-twitter)

Lien du projet: [https://github.com/votre-username/GoExpress_Mobile](https://github.com/votre-username/GoExpress_Mobile)
