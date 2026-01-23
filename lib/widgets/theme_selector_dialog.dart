import 'package:flutter/material.dart';

/// A dialog widget for selecting the app's theme mode.
///
/// This widget displays three radio options: Light, Dark, and System.
/// When System is selected, the app follows the device's theme setting.
///
/// Use the [show] static method to display this dialog and get the result.
class ThemeSelectorDialog extends StatefulWidget {
  /// Creates a ThemeSelectorDialog.
  ///
  /// The [currentMode] parameter specifies the currently active theme mode,
  /// which will be pre-selected when the dialog opens.
  const ThemeSelectorDialog({
    super.key,
    required this.currentMode,
  });

  /// The currently active theme mode.
  final ThemeMode currentMode;

  /// Shows the theme selector dialog and returns the selected theme mode.
  ///
  /// Returns the selected [ThemeMode] if the user confirms, or null if they cancel.
  /// The [currentMode] parameter specifies which option is initially selected.
  static Future<ThemeMode?> show(
    BuildContext context, {
    required ThemeMode currentMode,
  }) {
    return showDialog<ThemeMode>(
      context: context,
      builder: (context) => ThemeSelectorDialog(currentMode: currentMode),
    );
  }

  @override
  State<ThemeSelectorDialog> createState() => _ThemeSelectorDialogState();
}

class _ThemeSelectorDialogState extends State<ThemeSelectorDialog> {
  /// The currently selected theme mode in the dialog.
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  /// Handles the save action.
  void _handleSave() {
    Navigator.of(context).pop(_selectedMode);
  }

  /// Handles the cancel action.
  void _handleCancel() {
    Navigator.of(context).pop();
  }

  /// Handles selection of a theme mode option.
  void _handleModeSelected(ThemeMode? mode) {
    if (mode != null) {
      setState(() {
        _selectedMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            subtitle: const Text('Always use light theme'),
            value: ThemeMode.light,
            groupValue: _selectedMode,
            onChanged: _handleModeSelected,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            subtitle: const Text('Always use dark theme'),
            value: ThemeMode.dark,
            groupValue: _selectedMode,
            onChanged: _handleModeSelected,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Follow device setting'),
            value: ThemeMode.system,
            groupValue: _selectedMode,
            onChanged: _handleModeSelected,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
