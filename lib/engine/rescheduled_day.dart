import '../models/challenge.dart';
import 'daily_proposal.dart';
import 'proposal_engine.dart';

/// Nombre maximal de tuiles dans une grille.
const int maxTiles = 5;

/// Nombre maximal de défis reportés sur un même jour. Au-delà, le jour n'est
/// plus proposé au report : la grille garde de la place pour le moteur.
const int maxRescheduledPerDay = 3;

/// La grille d'un jour qui a des défis reportés : ils passent avant les
/// propositions du moteur, à leur place (objectif en haut, opportunité en
/// dessous), et la grille ne dépasse jamais [maxTiles].
///
/// Le moteur ne repropose jamais un défi déjà vu dans la semaine : aucun
/// doublon possible entre [rescheduled] et [proposal].
DailyProposal withRescheduled(
  DailyProposal proposal,
  List<Challenge> rescheduled,
) {
  if (rescheduled.isEmpty) return proposal;
  final keptGoals = [
    for (final c in rescheduled)
      if (c.kind == ChallengeKind.goal) c,
  ];
  final keptOpportunities = [
    for (final c in rescheduled)
      if (c.kind == ChallengeKind.opportunity) c,
  ];
  final goals = [
    ...keptGoals,
    ...proposal.goals,
  ].take(_atLeast(maxGoalTiles, keptGoals.length)).toList();
  final opportunities = [
    ...keptOpportunities,
    ...proposal.opportunities,
  ].take(_atLeast(maxTiles - goals.length, keptOpportunities.length)).toList();
  return DailyProposal(goals: goals, opportunities: opportunities);
}

int _atLeast(int value, int floor) => value < floor ? floor : value;
