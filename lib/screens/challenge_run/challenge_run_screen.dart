import 'package:flutter/material.dart';

import '../../content/challenge_run_content.dart';
import '../../engine/clock.dart';
import '../../models/challenge.dart';
import '../../store/success_progress.dart';
import '../../theme/theme.dart';
import '../../validation/lock_detector.dart';
import 'success_view.dart';
import 'timer_run_view.dart';

/// Comment le défi en cours s'est terminé.
enum ChallengeRunOutcome { succeeded, abandoned }

/// Le milieu de l'écran, propre à un mode de validation. Le mode appelle
/// [onValidated] une fois, quand il a la preuve que le défi est fait.
typedef ChallengeRunBody =
    Widget Function(BuildContext context, VoidCallback onValidated);

/// L'enveloppe commune du défi en cours, quel que soit le mode de
/// validation : le titre du défi, l'arrêt en un tap, et l'écran de réussite.
/// Ce qu'il y a au milieu vient du mode ([bodyFor]).
///
/// L'arrêt n'a ni confirmation ni commentaire. Le retour système arrête aussi
/// le défi : il n'y a aucune autre navigation.
///
/// Rend un [ChallengeRunOutcome] à l'écran qui l'a ouvert.
class ChallengeRunScreen extends StatefulWidget {
  const ChallengeRunScreen({
    super.key,
    required this.challenge,
    required this.body,
    required this.onValidated,
    required this.onAbandoned,
  });

  final Challenge challenge;

  final ChallengeRunBody body;

  /// Enregistre la réussite et rend ce qu'elle fait avancer.
  final Future<SuccessProgress> Function() onValidated;

  /// Enregistre l'arrêt.
  final VoidCallback onAbandoned;

  /// Le milieu de l'écran pour [challenge], ou `null` si son mode de
  /// validation n'est pas encore construit.
  static ChallengeRunBody? bodyFor(
    Challenge challenge, {
    required Clock clock,
    required LockDetector lockDetector,
  }) => switch (challenge.validation) {
    ValidationMode.lockedTimer => (context, onValidated) => TimerRunView(
      target: challenge.estimatedDuration,
      clock: clock,
      lockDetector: lockDetector,
      onValidated: onValidated,
    ),
    // À venir : sport, co-présence, déclaratif.
    ValidationMode.health ||
    ValidationMode.qrCode ||
    ValidationMode.declarative => null,
  };

  @override
  State<ChallengeRunScreen> createState() => _ChallengeRunScreenState();
}

class _ChallengeRunScreenState extends State<ChallengeRunScreen> {
  bool _succeeded = false;
  SuccessProgress? _progress;

  Future<void> _onValidated() async {
    if (_succeeded) return;
    setState(() => _succeeded = true);
    final progress = await widget.onValidated();
    if (mounted) setState(() => _progress = progress);
  }

  void _abandon() {
    widget.onAbandoned();
    Navigator.of(context).pop(ChallengeRunOutcome.abandoned);
  }

  void _done() => Navigator.of(context).pop(ChallengeRunOutcome.succeeded);

  @override
  Widget build(BuildContext context) {
    return PopScope<ChallengeRunOutcome>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _succeeded ? _done() : _abandon();
      },
      child: Scaffold(
        body: _succeeded
            ? SuccessView(
                challengeId: widget.challenge.id,
                progress: _progress,
                onDone: _done,
              )
            : _running(context),
      ),
    );
  }

  Widget _running(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GlynaSpacing.screenGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.challenge.title,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: GlynaSpacing.md),
                SizedBox(
                  height: GlynaSpacing.minTouchTarget,
                  child: TextButton(
                    onPressed: _abandon,
                    child: Text(
                      ChallengeRunContent.abandon,
                      style: textTheme.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: widget.body(context, _onValidated)),
          ],
        ),
      ),
    );
  }
}
