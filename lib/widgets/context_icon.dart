import 'package:flutter/material.dart';

import '../content/bento_content.dart';
import '../models/challenge.dart';

/// Icône du contexte d'un défi : chez soi, dehors, n'importe où.
class ContextIcon extends StatelessWidget {
  const ContextIcon(this.context, {super.key});

  final ChallengeContext context;

  @override
  Widget build(BuildContext buildContext) {
    final (icon, label) = switch (context) {
      ChallengeContext.home => (Icons.home_outlined, BentoContent.contextHome),
      ChallengeContext.outside => (
        Icons.park_outlined,
        BentoContent.contextOutside,
      ),
      ChallengeContext.anywhere => (
        Icons.all_inclusive_rounded,
        BentoContent.contextAnywhere,
      ),
    };
    return Icon(icon, semanticLabel: label);
  }
}
