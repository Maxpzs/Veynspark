# File de travail

Une tâche à la fois, dans l'ordre. Ne jamais en sauter une, ne jamais en faire deux.

## Règles de travail

1. Repérer la **première tâche non cochée** de la liste ci-dessous.
2. La faire, entièrement, et rien d'autre.
3. Vérifier que `flutter analyze` ne renvoie aucun avertissement.
4. Vérifier que `flutter test` passe.
5. Cocher la case de la tâche dans ce fichier.
6. Faire un commit avec un message qui décrit la tâche.
7. S'arrêter là. La tâche suivante sera lancée séparément.

En cas de blocage, de doute réel ou de décision de conception qui n'est pas
tranchée par `docs/brief.md` : **ne pas inventer**. Écrire la question dans
`QUESTIONS.md` à la racine, avec le nom de la tâche, puis passer à la tâche
suivante.

Ne jamais introduire un élément de la liste « À ne jamais construire » de
`CLAUDE.md`, même si ça semble utile.

Ne jamais toucher à `lib/theme/`, sauf si la tâche le demande explicitement.

## Les tâches

- [x] **1. Modèles de données.** `lib/models/challenge.dart` existe déjà :
  **l'étendre sans casser son usage actuel** dans le bento, ne pas le réécrire de
  zéro. Compléter `Challenge` s'il manque des champs (domaine, niveau, contexte
  requis, mode de validation), puis ajouter `Goal` (titre, échéance, niveau de
  départ, quota hebdomadaire), `WeekQuota`, et `ChallengeLog` (défi, date, état :
  proposé, accepté, réussi, reporté, abandonné, et raison de report éventuelle).
  Classes immuables, `copyWith`, sérialisation JSON, `==` et `hashCode`. Tests
  unitaires de la sérialisation aller-retour pour chaque modèle. Vérifier que
  l'écran du bento compile toujours après la modification.

- [x] **2. Bibliothèque de défis.** Écrire dans `lib/content/` **60 défis** en
  français, répartis sur les domaines du brief : bouger, lire, cuisiner, créer,
  apprendre, voir des gens. Pour chacun, tous les champs du modèle `Challenge`.
  Respecter la répartition entre défis à objectif et défis d'opportunité, et les
  trois contextes (chez soi, dehors, n'importe où). Trois niveaux de difficulté par
  domaine au minimum. Le ton suit `CLAUDE.md` : court, direct, jamais donneur de
  leçons. Un test qui vérifie qu'aucun champ obligatoire n'est vide et qu'il existe
  au moins un défi faisable dans chaque contexte.

- [x] **3. Persistance locale.** Mettre en place `drift` (ou `sqflite` si `drift`
  pose problème, en le notant dans `QUESTIONS.md`). Tables pour les objectifs, les
  quotas hebdomadaires et le journal des défis. Une couche `Repository` qui expose
  des méthodes simples de lecture et d'écriture, sans que le reste de l'app ne
  connaisse la base. Tests sur une base en mémoire.

- [x] **4. Logique de la semaine.** Dans `lib/engine/`, un service qui : calcule le
  quota hebdomadaire d'un objectif à partir de son échéance et de son niveau de
  départ ; sait dire où en est la semaine en cours ; permet de déplacer un défi d'un
  jour à l'autre **à l'intérieur de la semaine uniquement** ; ferme la semaine le
  dimanche soir en produisant un bilan factuel. Aucune notion de série ni de streak.
  Tests couvrant le cas d'une semaine à zéro et celui d'un déplacement hors semaine,
  qui doit être refusé.

- [x] **5. Moteur de proposition, version 1.** Dans `lib/engine/`, la fonction qui
  choisit les 4 à 5 défis du jour, selon les six critères listés dans la section
  « Ce que le moteur prend en compte » de `docs/brief.md`. Règles simples et
  lisibles, pas d'apprentissage automatique. Tests : au moins une tuile faisable
  dehors et une faisable partout, jamais deux fois le même défi dans la semaine, le
  quota restant d'un objectif proche de son échéance fait remonter ses défis.

- [ ] **6. Réduction après report.** Étendre le moteur : au troisième déplacement
  d'un même défi, produire une proposition de version réduite du défi. Proposée une
  seule fois, jamais répétée, et refusable sans conséquence. Tests sur le compteur
  de reports et sur la non-répétition.

- [ ] **7. Service de minuteur.** Dans `lib/validation/`, la **logique seule**, sans
  interface : démarrage, arrêt, reprise, et détection de l'état de verrouillage de
  l'appareil selon la note technique du brief. Le compteur ne progresse que pendant
  que l'appareil est verrouillé. Exposer un flux d'état que l'interface pourra
  écouter plus tard. Tests avec une horloge et un détecteur de verrouillage simulés.

- [ ] **8. Mesure.** Dans `lib/analytics/`, une interface de journalisation des
  événements listés dans la section « La mesure » du brief, avec une implémentation
  locale qui écrit en base. Aucun service tiers, aucune donnée qui sort de
  l'appareil. Tests sur l'enregistrement et la relecture des événements.
