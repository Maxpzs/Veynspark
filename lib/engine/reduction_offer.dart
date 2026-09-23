import '../models/challenge.dart';

/// Une proposition de version réduite, faite une seule fois à un défi qui
/// résiste : « Celui-là résiste. On le réduit ? »
///
/// La refuser, c'est ne rien faire : le plan, le niveau et le journal restent
/// tels quels.
class ReductionOffer {
  const ReductionOffer({required this.original, required this.reduced});

  /// Le défi déplacé trop souvent.
  final Challenge original;

  /// Sa version réduite, prise dans la bibliothèque.
  final Challenge reduced;

  @override
  bool operator ==(Object other) =>
      other is ReductionOffer &&
      other.original == original &&
      other.reduced == reduced;

  @override
  int get hashCode => Object.hash(original, reduced);
}
