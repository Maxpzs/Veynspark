import '../models/challenge.dart';
import 'reduction_ledger.dart';
import 'reduction_offer.dart';
import 'week_plan.dart';

/// Nombre de déplacements d'un même défi dans la semaine à partir duquel une
/// version réduite est proposée.
const int movesBeforeReduction = 3;

/// Au troisième déplacement d'un même défi, propose une fois, et une seule, sa
/// version réduite.
///
/// La version réduite est un défi de la bibliothèque, du même domaine et de la
/// même nature, d'un niveau plus bas. À niveau égal, le même mode de
/// validation d'abord, puis le plus court. Un défi déjà posé dans la semaine
/// n'est jamais proposé. Sans candidat, pas de proposition, et rien n'est
/// consommé.
class ReductionRule {
  ReductionRule({required List<Challenge> library})
    : _library = List.unmodifiable(library);

  final List<Challenge> _library;

  /// À appeler après chaque déplacement de [challengeId] dans [plan].
  ///
  /// Rend la proposition éventuelle et le registre à conserver : une
  /// proposition faite y est inscrite aussitôt, la réponse n'y change rien.
  ({ReductionOffer? offer, ReductionLedger ledger}) afterMove({
    required String challengeId,
    required WeekPlan plan,
    required ReductionLedger ledger,
  }) {
    final none = (offer: null, ledger: ledger);
    if (plan.movesOf(challengeId) < movesBeforeReduction) return none;
    if (ledger.wasOffered(challengeId)) return none;
    final original = _library.where((c) => c.id == challengeId).firstOrNull;
    if (original == null) return none;
    final reduced = _reducedVersionOf(original, plan);
    if (reduced == null) return none;
    return (
      offer: ReductionOffer(original: original, reduced: reduced),
      ledger: ledger.record(challengeId),
    );
  }

  /// La personne accepte : la version réduite prend la place du défi, le même
  /// jour.
  WeekPlan accept(ReductionOffer offer, WeekPlan plan) =>
      plan.replace(offer.original.id, offer.reduced.id);

  Challenge? _reducedVersionOf(Challenge original, WeekPlan plan) {
    final candidates = [
      for (final c in _library)
        if (c.domain == original.domain &&
            c.kind == original.kind &&
            c.level < original.level &&
            plan.dayOf(c.id) == null)
          c,
    ];
    int rank(Challenge a, Challenge b) {
      final byLevel = b.level.compareTo(a.level);
      if (byLevel != 0) return byLevel;
      final aSame = a.validation == original.validation ? 0 : 1;
      final bSame = b.validation == original.validation ? 0 : 1;
      if (aSame != bSame) return aSame.compareTo(bSame);
      final byDuration = a.estimatedDuration.compareTo(b.estimatedDuration);
      if (byDuration != 0) return byDuration;
      return a.id.compareTo(b.id);
    }

    candidates.sort(rank);
    return candidates.firstOrNull;
  }
}
