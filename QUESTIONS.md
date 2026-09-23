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

## Tâche 5 — Moteur de proposition, version 1

- **Lien objectif → défis.** `Goal` ne porte pas de domaine : le moteur ne sait
  pas quels défis font avancer quel objectif. J'ai ajouté côté moteur un
  `GoalTrack` (objectif + domaine + semaine en cours) que l'appelant construit,
  sans toucher au modèle. Faut-il plutôt ajouter un `domain` (ou une
  progression) à `Goal` ?
- **Quota contre « jamais deux fois dans la semaine ».** Chaque domaine n'a que
  4 défis à objectif, alors qu'un quota peut monter à 5. Une fois les 4 proposés
  dans la semaine, l'objectif n'a plus de tuile : le moteur ne reprend jamais un
  défi, et complète avec des opportunités. « Courir 5 km » trois fois dans la
  semaine est pourtant naturel. La règle vise-t-elle aussi les défis à objectif,
  ou seulement les opportunités ? Sinon, il faut plus de défis à objectif par
  domaine.
- **« Proposé » dans la semaine.** Tout défi présent dans le journal de la
  semaine, quel que soit son état, est exclu. Le bento du jour doit donc être
  persisté une fois tiré, et « Rien ne me va » tirera naturellement une autre
  grille. À confirmer.
- **Règles chiffrées, toutes arbitraires.** Niveau : +1 toutes les 3 réussites
  dans le domaine, −1 par report « trop dur », borné 1–3. Défi « court » : 15 min
  ou moins, privilégié la nuit (22 h–5 h), hors des créneaux libres déclarés, ou
  après 2 reports « pas le bon moment » sur 14 jours. « Pas envie » pénalise le
  défi concerné pendant 14 jours. Deux tuiles à objectif seulement si deux
  objectifs sont en retard sur leur quota. Moments de la journée : matin 5–12 h,
  après-midi 12–18 h, soir 18–22 h, nuit 22–5 h.
- **Tuile dehors la nuit.** La règle « au moins une tuile faisable dehors » est
  appliquée à toute heure, y compris à 23 h, et aucune opportunité dehors ne dure
  moins de 15 min. Faut-il l'assouplir la nuit ?

## Tâche 6 — Réduction après report

- **Ce qu'est une « version réduite ».** Le brief donne « On le réduit à 3 km ? »,
  mais la bibliothèque n'a pas de variante de chaque défi. J'ai pris un autre
  défi de la bibliothèque : même domaine, même nature, niveau inférieur le plus
  proche, puis même mode de validation, puis le plus court (« Courir 5 km » →
  « Courir 2 km »). Aucun défi de niveau 1 n'a donc de version réduite. Faut-il
  plutôt une variante réduite écrite à la main par défi (champ dédié) ?
- **« Jamais répétée » : dans la semaine ou pour toujours ?** J'ai pris « pour
  toujours » : le registre (`ReductionLedger`) garde les défis déjà concernés
  d'une semaine à l'autre. Il n'est pas encore persisté ; il est sérialisable
  en JSON en attendant de savoir s'il va en base.
- **Réduction en chaîne.** Si la version réduite acceptée est à son tour
  déplacée trois fois, c'est un autre défi : une nouvelle proposition peut
  tomber. À confirmer.
- **Exclusion.** La version réduite n'est jamais un défi déjà posé dans le
  `WeekPlan` de la semaine. Le journal n'est pas consulté : un défi réussi
  cette semaine mais absent du plan pourrait être proposé.

## Tâche 7 — Service de minuteur

- **iOS sans code de verrouillage.** `isProtectedDataAvailable` ne passe à faux
  que si l'appareil a un code. Sans code, le compteur ne démarre jamais. Et avec
  un code, iOS ne coupe l'accès aux données qu'environ 10 s après le
  verrouillage : ces secondes ne sont pas comptées. Faut-il un repli (par
  exemple l'app en arrière-plan + écran éteint), au risque d'une preuve moins
  solide, ou un message qui explique pourquoi le compteur ne tourne pas ?
- **Écran éteint sans verrou, sur Android.** J'ai compté l'écran éteint comme
  « verrouillé », même si l'écran de verrouillage n'est pas encore affiché
  (délai de verrouillage). Le compteur s'arrête au retour de la personne
  (`ACTION_USER_PRESENT`, ou écran rallumé sans verrou). À confirmer.
- **Fin atteinte pendant le verrouillage.** L'app étant suspendue pendant le
  verrouillage, la réussite est constatée au déverrouillage, pas à la minute
  exacte. Faut-il prévenir la personne à la fin (notification locale, vibration),
  ou la laisser découvrir en déverrouillant ?
- **Reprise.** Après un arrêt, un nouveau verrouillage ne relance pas le
  compteur tout seul : la personne doit toucher « On reprend ? ». Le temps déjà
  tenu est gardé. Faut-il plutôt reprendre automatiquement au verrouillage ?
- **Persistance.** L'état du minuteur n'est pas sauvegardé : si le système tue
  l'app pendant le verrouillage, le défi est perdu. À traiter quand l'écran de
  défi en cours sera construit ?
