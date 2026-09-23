import 'package:flutter/foundation.dart';

/// Les défis à qui une version réduite a déjà été proposée. Une proposition
/// n'est jamais répétée, qu'elle ait été acceptée ou refusée.
@immutable
class ReductionLedger {
  ReductionLedger([Set<String> offered = const {}])
    : _offered = Set.unmodifiable(offered);

  factory ReductionLedger.fromJson(Map<String, Object?> json) =>
      ReductionLedger({...(json['offered'] as List<Object?>).cast<String>()});

  final Set<String> _offered;

  bool wasOffered(String challengeId) => _offered.contains(challengeId);

  ReductionLedger record(String challengeId) =>
      ReductionLedger({..._offered, challengeId});

  Map<String, Object?> toJson() => {
    'offered': [..._offered]..sort(),
  };

  @override
  bool operator ==(Object other) =>
      other is ReductionLedger && setEquals(other._offered, _offered);

  @override
  int get hashCode => Object.hashAllUnordered(_offered);
}
