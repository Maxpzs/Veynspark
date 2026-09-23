import 'package:flutter/material.dart';

import '../content/debug_content.dart';
import '../theme/theme.dart';
import 'debug_tools.dart';

/// Le panneau de débogage : l'état de la semaine, et de quoi remettre à zéro
/// ou voyager dans le temps. N'existe qu'en mode debug.
class DebugPanel extends StatefulWidget {
  const DebugPanel({super.key, required this.tools, required this.onChanged});

  final DebugTools tools;

  /// Appelé après chaque action, pour que l'écran relise ses données.
  final Future<void> Function() onChanged;

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  late Future<DebugWeek> _week = widget.tools.week();
  String? _message;
  bool _busy = false;

  /// Lance [action], puis relit la semaine. [action] peut rendre un message.
  Future<void> _run(Future<String?> Function() action) async {
    setState(() => _busy = true);
    String? message;
    try {
      message = await action();
      await widget.onChanged();
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _message = message;
          _week = widget.tools.week();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tools = widget.tools;
    final textTheme = Theme.of(context).textTheme;
    final actions = <(String, Future<String?> Function())>[
      (
        DebugContent.resetDay,
        () async {
          await tools.resetDay();
          return null;
        },
      ),
      (
        DebugContent.resetAll,
        () async {
          await tools.resetAll();
          return null;
        },
      ),
      (
        DebugContent.advanceDay,
        () async {
          tools.advanceDay();
          return null;
        },
      ),
      (
        DebugContent.advanceWeek,
        () async {
          tools.advanceWeek();
          return null;
        },
      ),
      (
        DebugContent.fillWeek,
        () async => DebugContent.filled(await tools.fillWeek()),
      ),
      (
        DebugContent.backToPresent,
        () async {
          tools.backToPresent();
          return null;
        },
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GlynaSpacing.screenGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(DebugContent.title, style: textTheme.titleLarge),
            const SizedBox(height: GlynaSpacing.sm),
            FutureBuilder<DebugWeek>(
              future: _week,
              builder: (context, snapshot) {
                final week = snapshot.data;
                if (week == null) return const SizedBox.shrink();
                return _WeekSummary(week);
              },
            ),
            if (_message case final message?) ...[
              const SizedBox(height: GlynaSpacing.xs),
              Text(message, style: textTheme.bodyMedium),
            ],
            const SizedBox(height: GlynaSpacing.md),
            for (final (label, action) in actions)
              SizedBox(
                height: GlynaSpacing.minTouchTarget,
                child: TextButton(
                  onPressed: _busy ? null : () => _run(action),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(label, style: textTheme.bodyLarge),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary(this.week);

  final DebugWeek week;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final progress = week.progress;
    final review = week.review;
    final lines = [
      DebugContent.now(week.now, week.daysAhead),
      DebugContent.week(progress.succeeded, progress.daysLeft),
      if (progress.goals.isEmpty) DebugContent.noGoal,
      for (final goal in progress.goals)
        DebugContent.quota(goal.title, goal.done, goal.target),
      if (review == null)
        DebugContent.reviewPending
      else
        DebugContent.review(
          review.succeeded.length,
          review.goals.where((g) => g.isReached).length,
          review.goals.length,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final line in lines) Text(line, style: style)],
    );
  }
}
