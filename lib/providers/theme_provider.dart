import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's theme mode state and persistence.
///
/// Uses [ValueNotifier] for reactive state management, allowing widgets
/// to rebuild when the theme mode changes. Theme preference is persisted
/// to [SharedPreferences] and restored on app startup.
class ThemeProvider {
  /// The key used to store the theme mode preference in SharedPreferences.
  static const String _themePreferenceKey = 'theme_mode';

  /// The notifier that holds the current theme mode value.
  ///
  /// Widgets can listen to this notifier to react to theme changes.
  final ValueNotifier<ThemeMode> themeModeNotifier;

  /// Creates a new [ThemeProvider] with an initial theme mode.
  ///
  /// Defaults to [ThemeMode.system] which follows the device's theme setting.
  ThemeProvider({ThemeMode initialMode = ThemeMode.system})
      : themeModeNotifier = ValueNotifier<ThemeMode>(initialMode);

  /// The current theme mode.
  ThemeMode get themeMode => themeModeNotifier.value;

  /// Sets the theme mode and persists it to storage.
  ///
  /// This method updates the [themeModeNotifier] value, which will trigger
  /// any listeners to rebuild, and saves the preference to [SharedPreferences].
  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await _saveTheme(mode);
  }

  /// Loads the saved theme preference from storage.
  ///
  /// If no preference is stored or the stored value is invalid,
  /// defaults to [ThemeMode.system]. Call this during app initialization
  /// to restore the user's theme preference.
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(_themePreferenceKey);

    if (savedValue != null) {
      final mode = _themeModeFromString(savedValue);
      themeModeNotifier.value = mode;
    }
    // If no saved value, keep the default (ThemeMode.system)
  }

  /// Saves the theme mode to persistent storage.
  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _themeModeToString(mode));
  }

  /// Converts a [ThemeMode] to a string for storage.
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Converts a stored string back to a [ThemeMode].
  ///
  /// Returns [ThemeMode.system] if the string is unrecognized,
  /// providing graceful handling of corrupted preferences.
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Disposes of the theme mode notifier.
  ///
  /// Call this when the provider is no longer needed to free resources.
  void dispose() {
    themeModeNotifier.dispose();
  }
}
