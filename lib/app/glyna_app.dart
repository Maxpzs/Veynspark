import 'package:flutter/material.dart';

import '../content/app_content.dart';
import '../screens/bento/bento_screen.dart';
import '../theme/theme.dart';

/// Racine de l'app. Sombre par défaut.
class GlynaApp extends StatelessWidget {
  const GlynaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppContent.title,
      debugShowCheckedModeBanner: false,
      theme: GlynaTheme.dark,
      home: const BentoScreen(),
    );
  }
}
