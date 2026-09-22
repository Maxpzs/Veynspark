import 'package:flutter/material.dart';

import '../../content/theme_specimen_content.dart';
import '../../theme/theme.dart';

/// TEMPORAIRE : montre toute l'échelle typographique et les cinq couleurs,
/// pour vérifier le rendu des polices et du thème sur appareil.
///
/// Un seul mode à la fois, pour ne jamais avoir deux roses à l'écran.
class ThemeSpecimenScreen extends StatefulWidget {
  const ThemeSpecimenScreen({super.key});

  @override
  State<ThemeSpecimenScreen> createState() => _ThemeSpecimenScreenState();
}

class _ThemeSpecimenScreenState extends State<ThemeSpecimenScreen> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? GlynaTheme.dark : GlynaTheme.light,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colors = GlynaColors.of(context);
          return Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(GlynaSpacing.screenGutter),
                children: [
                  _SectionTitle(ThemeSpecimenContent.colorSection),
                  ..._swatches(colors),
                  const SizedBox(height: GlynaSpacing.xxl),
                  _SectionTitle(ThemeSpecimenContent.typeSection),
                  ..._typeScale(theme.textTheme),
                  const SizedBox(height: GlynaSpacing.xl),
                  SizedBox(
                    height: GlynaSpacing.minTouchTarget,
                    child: FilledButton(
                      onPressed: () => setState(() => _dark = !_dark),
                      child: Text(
                        _dark
                            ? ThemeSpecimenContent.switchToLight
                            : ThemeSpecimenContent.switchToDark,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _swatches(GlynaColors colors) => [
    _Swatch(ThemeSpecimenContent.background, colors.background, colors.text),
    _Swatch(ThemeSpecimenContent.surface, colors.surface, colors.text),
    _Swatch(ThemeSpecimenContent.brand, colors.brand, colors.text),
    _Swatch(ThemeSpecimenContent.accent, colors.accent, colors.text),
    _Swatch(ThemeSpecimenContent.text, colors.text, colors.text),
  ];

  List<Widget> _typeScale(TextTheme t) {
    final styles = [
      t.displayLarge,
      t.displayMedium,
      t.displaySmall,
      t.headlineLarge,
      t.headlineMedium,
      t.headlineSmall,
      t.titleLarge,
      t.titleMedium,
      t.titleSmall,
      t.bodyLarge,
      t.bodyMedium,
      t.bodySmall,
      t.labelLarge,
      t.labelMedium,
      t.labelSmall,
    ];
    assert(styles.length == ThemeSpecimenContent.styleNames.length);
    return [
      for (var i = 0; i < styles.length; i++)
        _TypeSample(
          name: ThemeSpecimenContent.styleNames[i],
          style: styles[i]!,
          sample: i < ThemeSpecimenContent.displayStyleCount
              ? ThemeSpecimenContent.displaySample
              : ThemeSpecimenContent.bodySample,
        ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GlynaSpacing.md),
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color, this.outline);

  final String label;
  final Color color;
  final Color outline;

  String get _hex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: GlynaSpacing.sm),
      child: Row(
        children: [
          Container(
            width: GlynaSpacing.xxxl,
            height: GlynaSpacing.xxl,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: outline),
            ),
          ),
          const SizedBox(width: GlynaSpacing.md),
          Expanded(child: Text(label, style: textTheme.bodyLarge)),
          Text(_hex, style: textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _TypeSample extends StatelessWidget {
  const _TypeSample({
    required this.name,
    required this.style,
    required this.sample,
  });

  final String name;
  final TextStyle style;
  final String sample;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spec = ThemeSpecimenContent.styleSpec(
      style.fontSize!,
      (style.fontWeight ?? FontWeight.w400).value,
      style.height!,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: GlynaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name · $spec', style: textTheme.labelSmall),
          const SizedBox(height: GlynaSpacing.xxs),
          Text(sample, style: style),
        ],
      ),
    );
  }
}
