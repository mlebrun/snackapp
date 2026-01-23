import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Utility extension for applying animations conditionally.
///
/// In test environments (detected via WidgetsBinding type), animations
/// are skipped to avoid pending timer issues. In production, full
/// animations are applied.
extension ConditionalAnimate on Widget {
  /// Applies entrance animations (fade in + slide up) to the widget.
  ///
  /// In test environments, returns the widget unchanged to avoid
  /// pending timer issues. In production, applies staggered entrance
  /// animations based on the item index.
  ///
  /// Parameters:
  /// - [index]: The item index for staggered delay calculation.
  /// - [duration]: Base animation duration (default: 300ms).
  /// - [delayPerItem]: Delay multiplier per item (default: 50ms).
  Widget animateEntrance({
    required int index,
    Duration duration = const Duration(milliseconds: 300),
    Duration delayPerItem = const Duration(milliseconds: 50),
  }) {
    // Skip animations in test environment to avoid pending timer issues
    if (_isTestEnvironment) {
      return this;
    }

    return animate()
        .fadeIn(duration: duration, delay: delayPerItem * index)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: duration,
          delay: delayPerItem * index,
          curve: Curves.easeOutCubic,
        );
  }

  /// Detects if the app is running in a test environment.
  ///
  /// Checks if the WidgetsBinding is an AutomatedTestWidgetsFlutterBinding
  /// by examining the runtime type name.
  static bool get _isTestEnvironment {
    try {
      final binding = WidgetsBinding.instance;
      final typeName = binding.runtimeType.toString();
      return typeName.contains('Test');
    } catch (_) {
      return false;
    }
  }
}
