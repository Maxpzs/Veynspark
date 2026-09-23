# Glyna — brief de développement

Brief destiné à la construction de l'application : ce qu'elle fait, à quoi elle
ressemble, et comment chaque écran fonctionne.

## Le produit

**Glyna propose chaque jour quelques défis courts à réaliser dans la vraie vie,
choisis en fonction des objectifs de la personne, et vérifie qu'ils ont été faits.**
Le temps d'écran baisse comme conséquence, jamais comme promesse affichée.

Slogan : **« Plus tard, c'est maintenant. »**

### La boucle

Objectif long déclaré à l'inscription → quota hebdomadaire (« 3 sorties cette
semaine ») → bento du jour (4 à 5 défis) → on en choisit un → l'app vérifie →
réussite avec retour immédiat → retour au bento.

### Les six règles qui gouvernent toutes les décisions

1. **L'app propose, elle n'exige jamais.** Aucun défi n'est obligatoire, aucune
   journée n'est un échec.
2. **L'unité d'engagement est la semaine, pas le jour.** On peut déplacer librement
   un défi dans sa semaine, pas en sortir.
3. **La preuve est technique, jamais photographique.** La photo sert à inspirer les
   autres, elle ne valide rien.
4. **Aucun streak, aucun classement, aucune case vide visible chez les autres.**
5. **On vise le retour quotidien, pas le temps passé.** Une session dure deux minutes
   et c'est parfait.
6. **Drôle quand ça réussit, sobre quand ça rate.** Jamais l'inverse.

### Les deux natures de défis

| | **Défi à objectif** | **Défi d'opportunité** |
| --- | --- | --- |
| Exemple | Courir 5 km (objectif : marathon le 20 mars) | Tester une recette au curry |
| Rattaché à | Un objectif long avec une échéance | Rien |
| Rythme | Quota hebdomadaire à tenir | Rotation libre |
| Si on le saute | Le quota de la semaine s'en ressent | Aucune conséquence |
| Dans le bento | 1 à 2 par jour, mis en avant | 2 à 3 par jour, en retrait |

### Plateformes

iOS et Android. Mobile uniquement, portrait uniquement. Pas de version web.

## Direction artistique

**Sombre par défaut.** Glyna est une app qu'on ouvre le soir et le matin tôt ; le
thème clair existe mais n'est pas le mode principal.

### Couleurs

| Rôle | Sombre (par défaut) | Clair |
| --- | --- | --- |
| Fond | `#0C0C0E` | `#F3EEE3` |
| Surfaces, cartes | `#1C1024` | `#FFFFFF` |
| Marque, actions | `#7C5CFF` | `#6A45F5` |
| Accent rare | `#FF4D9D` | `#C82A6E` |
| Texte principal | `#EFE3CF` | `#171019` |

**Le rose ne sert qu'aux moments qui tranchent** : une réussite, une bascule, un
accent unique sur un écran. Jamais deux éléments roses en même temps à l'écran.

### Typographie

- **Anton** pour les titres, en capitales, très gros, interlignage serré
- **Archivo** pour tout le reste
- Le contraste entre les deux est l'essentiel de l'identité : des titres énormes, un
  texte discret

### Symbole

Pas encore trouvé. Doit rester lisible à 16 px.

### Principes d'interface

- **Une action principale par écran.** Jamais deux boutons de même poids.
- **Beaucoup de vide.** Les marges généreuses font partie de la marque : une app qui
  respire, face à des réseaux qui saturent.
- **Aucun défilement infini.** Toute liste a une fin visible.
- **Animations courtes**, 200 à 400 ms, jamais bloquantes. Une seule animation
  célébratoire par réussite.
- **Aucun badge rouge**, aucun compteur de notifications non lues.
- **Gros éléments tactiles.** On utilise Glyna debout, en manteau, entre deux choses.

### Ton d'écriture

Court, direct, un peu insolent, jamais donneur de leçons. Exemples de registre :

- « Instagram t'attend. Il attendra. »
- « J'ai rendu 14 h ce mois-ci. »
- « Plus tard, c'est maintenant. »

**Règle absolue : l'humour va aux réussites, jamais aux échecs.** Un écran de semaine
ratée est sobre, factuel, sans commentaire. Une app qui plaisante quand on échoue se
fait désinstaller.

## L'onboarding

**L'onboarding n'est pas une inscription, c'est le pitch du produit, joué au lieu
d'être lu.** La personne qui arrive est curieuse, pas convaincue. Chaque écran doit
lui apprendre une règle du jeu **et** lui soutirer une information, sans qu'elle ait
l'impression de remplir quoi que ce soit.

**Quatre règles :**

- **Un écran = une idée apprise + une info récoltée.** Jamais une question qui ne sert
  qu'à la base de données.
- **Des questions inattendues plutôt que des formulaires.** On ne demande jamais
  « quels sont tes centres d'intérêt » : on le déduit d'un jeu.
- **Aucune création de compte avant la fin.** On demande l'e-mail quand la personne a
  déjà quelque chose à perdre.
- **Du pouce, pas du clavier.** On tape, on balaye, on fait glisser. La saisie libre
  est toujours optionnelle.

Durée visée : **90 secondes**, 5 à 10 secondes par écran.

### Écran par écran

**1 — L'accroche.** Noir, le slogan en Anton énorme : « PLUS TARD, C'EST
MAINTENANT. » Un bouton : *Commencer*. Rien d'autre.

**2 — Le pari.** « Cette semaine, tu vas passer combien d'heures sur ton téléphone ? »
Un gros curseur, la personne parie. Puis la réponse tombe : la moyenne française est
d'environ **4 heures par jour, soit 28 heures par semaine**. Une phrase, pas deux :
« On ne va pas te faire la morale. On va juste t'en rendre une partie. »
*Apprend : le problème. Récolte : la lucidité de la personne sur son propre usage.*

**3 — « Tu préfères ? »** Six duels en rafale, une carte contre une autre, on balaye :
courir sous la pluie ou faire la vaisselle ; un livre ou un podcast ; cuisiner pour
six ou manger seul en paix ; une expo ou une sieste ; apprendre un accord ou battre
son record. Deux secondes chacun, rythme rapide, ton décalé.
*Apprend : l'app a du caractère. Récolte : les domaines d'intérêt, sans jamais les
avoir demandés.*

**4 — Le portrait.** L'app renvoie ce qu'elle a compris : « Toi c'est plutôt : dehors,
les mains dans la farine, et un livre commencé qui traîne. » Puis : « Glyna, c'est ça,
tous les jours. Deux ou trois propositions. Tu prends ce qui t'arrange, tu ignores le
reste. »
*Apprend : le bento et le fait que rien n'est obligatoire.*

**5 — Les 4 000 semaines.** Une grille de 4 000 points — une vie. Les points déjà
passés s'éteignent un par un sous les yeux de la personne, puis un seul point reste
allumé en rose. « Celle-ci. Tu en fais quoi ? »
*Apprend : la semaine est l'unité de Glyna, pas la journée.*

**6 — L'aveu.** « Nomme un truc que tu repousses depuis trop longtemps. » Des cartes
déjà pré-remplies à partir des duels, plus un champ libre discret. **C'est l'écran le
plus important de l'app** : sans objectif nommé, le moteur n'a rien à proposer.
*Récolte : l'objectif long.*

**7 — La date.** « Tu te donnes jusqu'à quand ? » Trois raccourcis et un sélecteur.
Dès la date posée, **une frise apparaît sous les doigts** et se remplit de semaines.
*Apprend : la profondeur du suivi, montrée au lieu d'être annoncée. Récolte :
l'échéance.*

**8 — « Sois honnête, personne ne regarde. »** Un curseur par objectif : « tu cours
combien, là, tout de suite, sans t'arrêter ? » Le curseur réagit avec humour à chaque
valeur. Aucun jugement, jamais le mot « débutant ».
*Récolte : le niveau de départ.*

**9 — La preuve.** « Une photo de toi en train de courir prouve que tu as pris une
photo. » Puis : « Ici, c'est ta montre, ton GPS et ton minuteur qui parlent. Pas de
mise en scène. »
*Apprend : la vérification automatique, qui est le vrai différenciateur.*

**10 — La révélation.** Le plan se construit à l'écran : « Marathon le 20 mars.
24 semaines. Cette semaine : 3 sorties. » Frise complète, courbe prévue, quota posé.
**C'est le paiement de tout ce qui précède**, l'animation la plus soignée du produit,
et le seul écran où le rose prend toute la place.

**11 — Le premier bento.** Immédiatement, avant tout compte. Quatre tuiles, dont **une
faisable dans la minute**. « On commence par laquelle ? »

**12 — Le compte.** Seulement maintenant : « Pour ne pas perdre tout ça. » Apple,
Google, e-mail.

### Ce que l'onboarding récolte

| Donnée | Écran | À quoi ça sert |
| --- | --- | --- |
| Domaines d'intérêt | 3 (les duels) | Filtre la bibliothèque de défis |
| Objectif long | 6 | Crée les défis à objectif et leur progression |
| Échéance | 7 | Calcule le quota hebdomadaire |
| Niveau de départ | 8 | Calibre la difficulté du premier défi |

**Rien d'autre.** Pas de disponibilités, pas de durée de créneaux, pas d'heure de
rappel : ces questions font fuir un curieux et ne servent qu'à partir du deuxième
jour.

### Ce qui vient après, et pas avant

Ces réglages deviennent la **première quête** proposée dans le bento, présentée comme
un défi à part entière, avec sa récompense :

- **« Apprends-moi ta semaine »** — la grille 7 jours × 4 moments, pour savoir quand
  proposer quoi
- **« Choisis ton heure »** — le moment du rappel quotidien
- **« Branche ta montre »** — l'autorisation Santé, demandée le jour du premier défi
  sportif, pas avant

### Reprise et modification

- L'onboarding est **interruptible** : on reprend où on s'est arrêté.
- Tout est **modifiable plus tard** : ajouter un objectif, changer une échéance,
  refaire les duels.
- **Un objectif peut être abandonné sans cérémonie**, sans écran de confirmation
  culpabilisant.

## L'écran principal : le bento

**C'est l'écran d'accueil, 90 % de l'usage, et le cœur du plaisir.** Une grille de 4 à
5 tuiles, chacune un défi proposé pour aujourd'hui, dans des contextes différents pour
qu'il y en ait toujours une faisable.

**L'objectif ressenti est de nettoyer la grille.** Tout le soin de conception passe
dans ce geste : une tuile qui disparaît doit être physiquement satisfaisante, au même
niveau qu'une bulle de papier à bulles ou qu'un anneau d'activité qui se referme. Si
ce moment est raté, le produit entier est raté.

### Le plaisir de nettoyer — son, vibration, mouvement

**C'est la partie la plus importante du brief, à traiter avec le même sérieux qu'une
fonctionnalité.**

**Le mouvement.** Une tuile validée ne se contente pas d'afficher une coche : **elle
quitte la grille**. Elle s'enfonce légèrement, disparaît, et les tuiles restantes se
recomposent avec un ressort souple — environ 350 ms, amorti, léger dépassement. La
grille qui se referme est le mouvement signature du produit.

**Le son.** Court, organique, grave : un bois qui claque, pas un bruit de dessin
animé. Jamais plus de 400 ms.

- Chaque tuile nettoyée joue **la même note, un demi-ton plus haut que la
  précédente**. Nettoyer la grille compose donc une gamme ascendante, légèrement
  différente chaque jour selon le nombre de tuiles.
- La **dernière tuile** résout l'accord : un son plus plein, plus long, qui retombe.
  C'est la seule récompense sonore généreuse de l'app.
- **Aucun son pour un échec, un report ou une journée vide.** Le silence n'est jamais
  une punition, c'est juste du silence.

**La vibration.** Systématiquement couplée au son, jamais seule.

| Moment | iOS | Android |
| --- | --- | --- |
| Tap sur une tuile | Impact léger (`HapticFeedback.lightImpact`) | `EFFECT_TICK` |
| Défi accepté | Impact moyen | `EFFECT_CLICK` |
| Tuile nettoyée | Impact lourd | `EFFECT_HEAVY_CLICK` |
| Grille entièrement nettoyée | Retour de succès + impact lourd | Composition de deux impulsions |
| Glisser-déposer | Léger à la prise, moyen à la pose | `EFFECT_TICK` puis `EFFECT_CLICK` |

**Réglages.** Son actif par défaut, **respect strict du mode silencieux du système**.
Un interrupteur pour le son, un pour les vibrations. Aucun son ne se déclenche pendant
un défi à minuteur en cours.

**Le test de recette :** quelqu'un doit avoir envie de nettoyer une tuile juste pour le
bruit que ça fait. Sinon, refaire le design sonore.

### La tuile

Chaque tuile porte : un **titre court** (« Courir 5 km »), une **durée estimée**, une
**icône de contexte** (chez soi, dehors, n'importe où), et pour les défis à objectif un
**rappel de l'objectif** (« → marathon, 3/3 cette semaine »).

**La taille d'une tuile est proportionnelle à la durée du défi.** Un défi d'une
heure occupe un grand rectangle, un défi de dix minutes une petite case. On lit
l'engagement que demande sa journée d'un seul coup d'œil, sans lire un chiffre.

**La disposition change chaque jour.** Les formes et les positions ne sont jamais
identiques deux jours de suite — c'est ce qui donne au bento son caractère de boîte
composée plutôt que de liste. La grille se recompose autour des tailles du jour.

Une contrainte, cependant : **au moins une tuile à objectif reste dans la rangée du
haut**, quelle que soit la disposition. La variété doit surprendre, pas faire
chercher.

- **Tuiles à objectif** : bord violet, toujours au moins une visible en haut.
  1 à 2 par jour.
- **Tuiles d'opportunité** : sans bord. 2 à 3 par jour.
- La distinction entre les deux passe donc par **le bord**, pas par la taille — la
  taille appartient à la durée.
- Une tuile déjà réussie aujourd'hui reste visible, cochée, jusqu'au lendemain.

### Les gestes

| Geste | Résultat |
| --- | --- |
| Tap | Ouvre le détail du défi |
| Tap sur *Faire maintenant* | Lance le défi |
| Balayage vers la gauche | Remplace la tuile par une autre proposition |
| Appui long | Ouvre le calendrier de la semaine pour la déplacer |

### Ce que le moteur prend en compte

1. Les **échéances** des objectifs et le quota restant sur la semaine
2. Le **moment de la journée** et les créneaux libres déclarés
3. Le **niveau** actuel, recalculé après chaque réussite ou report
4. L'**historique récent** : ne jamais proposer deux fois le même défi dans la semaine
5. Les **raisons de report** accumulées
6. La **variété des contextes** : au moins une tuile faisable dehors, une faisable
   partout

### Le cas « rien ne me va »

Un bouton discret en bas : *Rien ne me va aujourd'hui*. Il **rafraîchit toute la
grille une fois par jour**, et pose une question en un tap : pas le bon moment, pas
envie, trop dur, autre chose. Cette réponse alimente le moteur.

Si la grille est rafraîchie et que rien ne convient encore, l'app **ne force rien** :
un écran calme, « Ça arrive. À demain. », et c'est tout. Pas de pénalité, pas de
relance.

## Faire un défi, et le valider

**Chaque type de défi a son mode de validation. La photo ne valide jamais rien.**

| Type de défi | Validation | Note technique |
| --- | --- | --- |
| Lecture, travail, déconnexion | Minuteur dans l'app + **appareil verrouillé** pendant la durée | iOS : `UIApplication.isProtectedDataAvailable` et ses notifications. Android : diffusions d'état d'écran et de verrouillage. Aucune autorisation spéciale requise |
| Course, marche, vélo | Lecture de l'activité dans **HealthKit** et **Health Connect** | Ne jamais passer par l'API Strava. Strava écrit déjà dans Apple Santé. Rejeter les saisies manuelles en contrôlant la source de la mesure |
| Activité à plusieurs | **QR régénéré toutes les 10 s**, scan mutuel, validation serveur dans une fenêtre courte | Un QR statique se photographie et ne prouve rien |
| Cuisine, création, divers | Déclaratif, assumé comme tel | Ne rien promettre qu'on ne vérifie |

### Le défi en cours : un écran par mode de validation

**Il n'y a pas un écran de défi en cours, il y en a un par mode de validation.** Ils
partagent la même enveloppe — le titre du défi, l'abandon en un tap, l'écran de
réussite — mais ce qu'il y a au milieu n'a rien à voir.

| Mode | Ce que voit la personne pendant le défi |
| --- | --- |
| **Minuteur** (lecture, travail, déconnexion) | Plein écran noir, le temps qui passe, rien d'autre, aucune navigation. Consigne : « Pose ton téléphone. Il se verrouille, le compteur tourne. » |
| **Sport** (course, marche, vélo) | **Rien.** Le téléphone reste dans la poche, c'est tout l'intérêt. L'app affiche un état d'attente discret — « On t'attend au retour » — et lit l'activité dans Santé ensuite. Aucun suivi GPS dans Glyna. |
| **Co-présence** (défi à plusieurs) | L'écran de scan : le QR de la personne, régénéré toutes les 10 s, et la caméra pour scanner celui d'en face. |
| **Déclaratif** (cuisine, création) | Le contenu du défi lui-même — la recette, les étapes, la consigne — et un bouton « c'est fait » à la fin. |

Pour le minuteur : si la personne déverrouille avant la fin, le compteur s'arrête.
Message sobre, sans reproche : « Compteur arrêté à 12 minutes. On reprend ? »

Pour le sport : le défi reste ouvert tant que l'activité n'a pas été détectée. Aucune
relance, aucune limite de temps dans la journée. Glyna vérifie au retour, c'est tout.

### La réussite

**Le seul endroit où l'app se lâche.** Animation courte mais généreuse, le rose prend
l'écran, une phrase écrite avec du caractère. Puis, en une ligne : ce que ça fait
avancer (« 2/3 cette semaine »).

Ensuite seulement, et de façon **facultative** : « Une photo ? Ça peut donner envie à
quelqu'un. » Jamais bloquant, jamais redemandé si on refuse.

### L'abandon

On peut arrêter un défi en cours à tout moment, en un tap, **sans écran de
confirmation et sans commentaire de l'app**.

## La semaine, la progression, le social

### La vue semaine

Sept colonnes, les défis posés dessus. En haut, les quotas en cours : « Courir 2/3 ·
Lire 4/5 ».

- **Glisser-déposer** un défi d'un jour à l'autre, autant de fois qu'on veut, **à
  l'intérieur de la semaine uniquement**
- Aucun verrou, aucun message de reproche à aucun moment
- Au 3e déplacement d'un même défi, **une proposition unique** : « Celui-là résiste. On
  le réduit à 3 km ? » Proposée une seule fois, jamais répétée

### Le bilan du dimanche

Écran de fin de semaine, factuel : ce qui a été fait, les quotas atteints ou non,
l'avancement vers chaque objectif. **Une semaine à zéro s'affiche sans humour, sans
excuse et sans encouragement forcé** — juste les chiffres et la semaine suivante qui
s'ouvre.

### La progression

Par objectif : la frise depuis le début, la courbe réelle contre la courbe prévue, le
temps restant avant l'échéance. C'est la récompense de long terme, celle qu'on vient
regarder quand on doute.

### Le social

À construire **après** que le reste fonctionne, mais à prévoir dans le modèle de
données dès le départ.

- **Amis** par lien ou contact. Aucune découverte publique d'inconnus.
- **Feed** des réussites des amis : photo facultative, une carte par réussite, **fin
  visible, pas de défilement infini**.
- **Bouton « relever le défi »** sur chaque publication : le défi correspondant
  s'ajoute au bento du lendemain.
- **Encouragements** en un tap. Pas de commentaires en phase 1.
- **Jamais** : classement, score comparatif, cases vides des autres, échecs d'autrui.
- **Messagerie** simple, une conversation par ami.
- **Signalement, blocage, modération** : obligatoires dès qu'il y a du contenu publié.

**La métrique à instrumenter dès le premier jour du feed : le taux de reprise** —
combien de personnes lancent un défi après avoir vu une publication. C'est la mesure
qui décide si la couche sociale a une raison d'exister.

## Le socle technique

### La bibliothèque de défis

Le contenu est le produit. Prévoir environ **200 défis écrits à la main** pour
démarrer, et un back-office pour les ajouter ou les corriger **sans redéployer
l'app**.

Chaque défi porte au minimum : titre, domaine, type (objectif ou opportunité), niveau,
durée estimée, contexte requis (chez soi, dehors, n'importe où), mode de validation,
et pour les défis à objectif sa place dans une progression.

### La mesure, dès la première version

Ce ne sont pas des fonctionnalités de confort : ce sont les chiffres qui décident de
la suite du projet.

- Rétention à J1, J7 et **J30**
- Ratio actifs quotidiens sur actifs mensuels
- Taux d'acceptation et de report par défi
- Taux de reprise depuis le feed, dès qu'il existe
- Taux de complétion de l'onboarding, écran par écran

### Obligations non négociables

- Export de ses données et **suppression complète du compte**
- Consentement explicite pour la géolocalisation et les données d'activité physique,
  séparément
- Vérification d'âge, selon la qualification juridique de l'app
- Modération et signalement dès qu'il y a du contenu publié

### À ne pas construire

- Univers virtuel, avatar, décor à faire grandir
- Streaks, séries, compteurs de jours consécutifs
- Classements entre amis
- Photo obligatoire pour valider quoi que ce soit
- Temps passé dans l'app comme objectif ou comme métrique de succès
- Défilement infini, badges rouges, notifications de relance

> Ces six lignes ne sont pas des oublis : chacune a été écartée pour une raison
> documentée dans le document de conception.
