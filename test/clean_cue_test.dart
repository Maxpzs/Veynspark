import 'package:flutter_test/flutter_test.dart';
import 'package:veynspark_v1/feedback/clean_cue.dart';

void main() {
  List<String> scale(int total) => [
    for (var i = 0; i < total; i++)
      CleanCue.forClean(index: i, total: total).assetPath,
  ];

  test('cinq tuiles : quatre notes montantes puis la résolution', () {
    expect(scale(5), [
      'assets/sounds/clean_note_0.wav',
      'assets/sounds/clean_note_1.wav',
      'assets/sounds/clean_note_2.wav',
      'assets/sounds/clean_note_3.wav',
      'assets/sounds/clean_resolve.wav',
    ]);
  });

  test('quatre tuiles : la résolution arrive un demi-ton plus tôt', () {
    expect(scale(4).last, 'assets/sounds/clean_resolve.wav');
    expect(scale(4)[2], 'assets/sounds/clean_note_2.wav');
  });

  test('une seule tuile : directement la résolution', () {
    expect(CleanCue.forClean(index: 0, total: 1).isResolution, isTrue);
  });
}
