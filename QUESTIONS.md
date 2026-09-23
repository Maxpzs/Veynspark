# Questions ouvertes

## Tâche 2 — Bibliothèque de défis

- **Rappel d'objectif des défis de la bibliothèque.** Le modèle `Challenge` exige
  un `goalReminder` pour tout défi à objectif. Dans la bibliothèque, un défi n'est
  rattaché à aucun objectif précis : j'ai mis un rappel générique par domaine
  (« → ton objectif sport »). Faut-il plutôt rendre ce champ facultatif et le
  laisser calculer par le moteur (« → marathon, 1/3 cette semaine ») ?
- **Place dans une progression.** Le brief demande que chaque défi à objectif
  porte « sa place dans une progression ». Le modèle n'a pas ce champ ; pour
  l'instant la progression se lit via le niveau (1 à 3, quatre défis à objectif
  par domaine). Faut-il ajouter un champ dédié (identifiant de progression + rang) ?
- **Répartition objectif / opportunité.** J'ai pris 4 défis à objectif et 6
  d'opportunité par domaine (24 / 36), calqué sur le ratio du bento (≈ 2 sur 5).
  À confirmer.

## Tâche 4 — Logique de la semaine

- **Formule du quota hebdomadaire.** Le brief ne donne pas de formule. J'ai pris
  une règle simple, isolée dans `lib/engine/weekly_quota_rule.dart` : niveau de
  départ + 1 (niveau 1 → 2 défis, 2 → 3, 3 → 4), un de plus dans les 4 dernières
  semaines avant l'échéance, borné entre 2 et 5, et 0 une fois l'échéance passée.
  Faut-il une montée progressive semaine après semaine, ou un quota qui dépend du
  type d'objectif (courir ≠ lire) ?
- **Heure de clôture du dimanche.** « Le dimanche soir » n'a pas d'heure : j'ai
  fixé 18 h (`weekClosingHour`). À confirmer.
- **Réussites rattachées à un objectif.** `ChallengeLog` ne dit pas à quel
  objectif une réussite contribue ; le bilan lit donc `WeekQuota.done` tel
  qu'enregistré. Faut-il ajouter un `goalId` au journal pour recalculer le
  compteur à partir des réussites ?
- **Déplacement vers un jour déjà passé.** Autorisé, puisque le brief ne pose
  aucun verrou dans la semaine. À confirmer.
