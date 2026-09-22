# Glyna

App mobile Flutter, iOS + Android. Elle propose chaque jour 4 à 5 défis courts à
faire dans la vraie vie, choisis selon les objectifs de la personne, et vérifie
automatiquement qu'ils ont été faits. Le temps d'écran baisse comme conséquence,
jamais comme promesse affichée.

Le brief complet est dans @docs/brief.md — direction artistique, onboarding écran par
écran, spécification du bento, modes de validation. Lis-le avant de proposer une
architecture ou de construire un écran.

Le nom du package Dart est encore `veynspark_v1`, le produit s'appelle Glyna. Ne
renomme pas le package sans qu'on en parle.

## Les six règles

Elles priment sur toute autre considération. En cas de doute sur un choix de
conception, applique-les dans cet ordre.

1. **L'app propose, elle n'exige jamais.** Aucun défi n'est obligatoire, aucune
   journée n'est un échec.
2. **L'unité d'engagement est la semaine, pas le jour.** Un défi se déplace
   librement dans sa semaine, jamais en dehors.
3. **La preuve est technique, jamais photographique.** La photo inspire, elle ne
   valide rien.
4. **Aucun streak, aucun classement, aucune case vide visible chez les autres.**
5. **On vise le retour quotidien, pas le temps passé.** Une session de deux minutes
   est un succès.
6. **Drôle quand ça réussit, sobre quand ça rate.** Jamais l'inverse.

## À ne jamais construire

Ces éléments ont été écartés pour des raisons documentées dans le brief. Ne les
propose pas, même s'ils semblent naturels pour une app de ce type.

- Univers virtuel, avatar, décor à faire grandir
- Streaks, séries, compteurs de jours consécutifs
- Classements entre amis
- Photo obligatoire pour valider quoi que ce soit
- Temps passé dans l'app comme objectif ou métrique de succès
- Défilement infini, badges rouges, notifications de relance

## Stack

- Flutter, SDK Dart `^3.9.0`
- Lints : `flutter_lints`, configuré dans `analysis_options.yaml`
- Mobile uniquement, portrait uniquement. Les dossiers `web/`, `linux/`, `macos/` et
  `windows/` existent mais ne sont pas des cibles — ne les fais pas évoluer.

Les paquets ci-dessous ne sont pas encore installés. Propose-les au moment où le
besoin arrive, un par un, jamais tous d'un coup.

| Besoin | Paquet pressenti |
| --- | --- |
| État global | `flutter_riverpod` |
| Base locale | `drift` ou `sqflite` |
| Activité sportive | `health` (HealthKit et Health Connect) |
| Scan QR | `mobile_scanner` |
| Sons | `audioplayers` |
| Vibrations | `flutter_vibrate` ou canal natif |
| Notifications | `flutter_local_notifications` |

## Commandes

```bash
flutter pub get        # installer les dépendances
flutter run            # lancer sur simulateur ou appareil
flutter analyze        # analyse statique, doit passer avant tout commit
flutter test           # tests
dart format lib test   # formatage
```

## Conventions de code

- Dart strict, pas de `dynamic` non justifié
- `const` partout où c'est possible — un widget non `const` qui pourrait l'être est
  une erreur à corriger
- Un widget public par fichier, nommé comme le fichier en `snake_case`
- Les couleurs, espacements et durées d'animation viennent du thème,
  **jamais de valeur codée en dur** dans un widget
- Les textes affichés à l'utilisateur vivent dans `lib/content/`, jamais en dur dans
  un widget — le ton fait partie du produit et doit être relisible d'un seul endroit
- Pas de logique métier dans un widget : elle va dans `engine/` ou `validation/`

## Organisation visée

```
lib/
  main.dart
  app/            routes et configuration
  screens/        un dossier par écran
  widgets/        widgets réutilisables
  engine/         moteur de proposition des défis
  validation/     minuteur, verrouillage, santé, QR
  content/        textes de l'app et bibliothèque de défis
  theme/          couleurs, typographie, espacements, durées
  models/         modèles de données
  store/          état global
```

## Thème

Sombre par défaut. Le thème clair existe mais n'est pas le mode principal.

| Rôle | Sombre | Clair |
| --- | --- | --- |
| Fond | `#0C0C0E` | `#F3EEE3` |
| Surfaces | `#1C1024` | `#FFFFFF` |
| Marque, actions | `#7C5CFF` | `#6A45F5` |
| Accent rare | `#FF4D9D` | `#C82A6E` |
| Texte | `#EFE3CF` | `#171019` |

Typographie : **Anton** pour les titres (capitales, très gros, interlignage serré),
**Archivo** pour tout le reste.

Le rose ne sert qu'aux moments qui tranchent : une réussite, une bascule. **Jamais
deux éléments roses en même temps à l'écran.**

## Ce qui compte le plus

Le moment où une tuile du bento est nettoyée doit être physiquement satisfaisant :
mouvement, son et vibration ensemble. C'est le cœur du produit, pas une finition.
Le détail exact est dans @docs/brief.md, section « Le plaisir de nettoyer ».

## Avant de commiter

- `flutter analyze` passe sans avertissement
- `dart format` a été appliqué
- Aucune couleur, espacement ou durée codée en dur dans un widget
- Aucun texte utilisateur en dur dans un widget
- Aucun élément de la liste « À ne jamais construire » n'a été introduit
