import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';

/// Global test configuration for flutter_animate.
///
/// This file is automatically loaded by the Flutter test framework
/// before running tests. It configures flutter_animate to work
/// properly in test environments by disabling hot reload restart
/// behavior.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Disable animation restart on hot reload for test stability
  Animate.restartOnHotReload = false;

  // Run the actual tests
  await testMain();
}
