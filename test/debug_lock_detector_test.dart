import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/debug/debug_lock_detector.dart';

import 'support/fake_lock_detector.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late FakeLockDetector device;
  late DebugLockDetector lock;
  late List<bool> seen;

  void lifecycle(List<AppLifecycleState> states) {
    for (final state in states) {
      binding.handleAppLifecycleStateChanged(state);
    }
  }

  setUp(() {
    lifecycle([AppLifecycleState.resumed]);
    device = FakeLockDetector();
    lock = DebugLockDetector(device);
    seen = [];
  });

  test('sans simulation, relaie l\'appareil', () async {
    final subscription = lock.lockStates.listen(seen.add);
    await pumpEventQueue();
    device.lock();
    device.unlock();
    await pumpEventQueue();
    expect(seen, [false, true, false]);
    await subscription.cancel();
    expect(device.hasListener, isFalse);
  });

  test('en simulation, chaque sortie de l\'app est un verrouillage', () async {
    lock.setSimulating(true);
    final subscription = lock.lockStates.listen(seen.add);
    await pumpEventQueue();
    expect(device.hasListener, isFalse);

    device.lock();
    lifecycle([AppLifecycleState.inactive, AppLifecycleState.hidden]);
    lifecycle([AppLifecycleState.inactive, AppLifecycleState.resumed]);
    await pumpEventQueue();
    expect(seen, [false, true, false]);
    await subscription.cancel();
  });

  test('bascule à chaud, dans les deux sens', () async {
    final subscription = lock.lockStates.listen(seen.add);
    await pumpEventQueue();

    lock.setSimulating(true);
    await pumpEventQueue();
    expect(device.hasListener, isFalse);

    lock.setSimulating(false);
    await pumpEventQueue();
    expect(device.hasListener, isTrue);
    // L'appareil redonne son état courant dès le réabonnement.
    expect(seen, [false, false, false]);
    await subscription.cancel();
  });
}
