import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snackapp/main.dart';
import 'package:snackapp/providers/theme_provider.dart';
import 'package:snackapp/widgets/theme_selector_dialog.dart';

void main() {
  /// Set up mock SharedPreferences before each test.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider unit tests', () {
    test('Initializes with default ThemeMode.system', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, equals(ThemeMode.system));
      provider.dispose();
    });

    test('Initializes with custom initial mode', () {
      final provider = ThemeProvider(initialMode: ThemeMode.dark);
      expect(provider.themeMode, equals(ThemeMode.dark));
      provider.dispose();
    });

    test('setThemeMode updates the notifier value', () async {
      final provider = ThemeProvider();

      expect(provider.themeMode, equals(ThemeMode.system));

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, equals(ThemeMode.dark));

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, equals(ThemeMode.light));

      provider.dispose();
    });

    test('setThemeMode saves preference to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));

      provider.dispose();
    });

    test('loadSavedTheme loads saved preference', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final provider = ThemeProvider();

      expect(provider.themeMode, equals(ThemeMode.system)); // Before load

      await provider.loadSavedTheme();

      expect(provider.themeMode, equals(ThemeMode.dark));

      provider.dispose();
    });

    test('loadSavedTheme loads light theme', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final provider = ThemeProvider();

      await provider.loadSavedTheme();

      expect(provider.themeMode, equals(ThemeMode.light));

      provider.dispose();
    });

    test('loadSavedTheme defaults to system on invalid value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'invalid_value'});
      final provider = ThemeProvider();

      await provider.loadSavedTheme();

      expect(provider.themeMode, equals(ThemeMode.system));

      provider.dispose();
    });

    test('loadSavedTheme keeps system when no value stored', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.loadSavedTheme();

      expect(provider.themeMode, equals(ThemeMode.system));

      provider.dispose();
    });

    test('themeModeNotifier notifies listeners on change', () async {
      final provider = ThemeProvider();
      final notifiedValues = <ThemeMode>[];

      provider.themeModeNotifier.addListener(() {
        notifiedValues.add(provider.themeMode);
      });

      await provider.setThemeMode(ThemeMode.dark);
      await provider.setThemeMode(ThemeMode.light);

      expect(notifiedValues, equals([ThemeMode.dark, ThemeMode.light]));

      provider.dispose();
    });
  });

  group('ThemeSelectorDialog widget tests', () {
    testWidgets('Dialog shows title and three options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ThemeSelectorDialog.show(
                  context,
                  currentMode: ThemeMode.system,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog title
      expect(find.text('Choose Theme'), findsOneWidget);

      // Verify three options are shown
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Verify subtitles
      expect(find.text('Always use light theme'), findsOneWidget);
      expect(find.text('Always use dark theme'), findsOneWidget);
      expect(find.text('Follow device setting'), findsOneWidget);
    });

    testWidgets('Current mode is pre-selected', (WidgetTester tester) async {
      ThemeMode? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ThemeSelectorDialog.show(
                  context,
                  currentMode: ThemeMode.dark,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog shows Dark option
      expect(find.text('Dark'), findsOneWidget);

      // Immediately save without changing selection - should return Dark (the current mode)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(result, equals(ThemeMode.dark));
    });

    testWidgets('Cancel button closes dialog and returns null',
        (WidgetTester tester) async {
      ThemeMode? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ThemeSelectorDialog.show(
                  context,
                  currentMode: ThemeMode.system,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Choose Theme'), findsNothing);

      // Verify null was returned
      expect(result, isNull);
    });

    testWidgets('Selecting option and saving returns selected mode',
        (WidgetTester tester) async {
      ThemeMode? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ThemeSelectorDialog.show(
                  context,
                  currentMode: ThemeMode.system,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify dialog is closed and Dark was returned
      expect(find.text('Choose Theme'), findsNothing);
      expect(result, equals(ThemeMode.dark));
    });

    testWidgets('Can change selection before saving',
        (WidgetTester tester) async {
      ThemeMode? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ThemeSelectorDialog.show(
                  context,
                  currentMode: ThemeMode.system,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select Dark theme first
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Then change to Light theme
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify Light was returned (the final selection)
      expect(result, equals(ThemeMode.light));
    });
  });

  group('Theme integration tests', () {
    testWidgets('Settings icon is visible in AppBar',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify settings icon is present
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Verify it has a tooltip
      final settingsButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.settings),
      );
      expect(settingsButton.tooltip, equals('Settings'));
    });

    testWidgets('Settings icon visible on Recipes tab',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should be on Recipes tab by default
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Settings icon visible on Grocery List tab',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Settings icon should still be visible
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Tapping settings icon opens theme dialog',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap settings icon
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify theme dialog is shown
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('System is default selected theme',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Open settings dialog
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify dialog is showing
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Save without changing - should keep System as default
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify no theme preference was actually saved (since System is default)
      // Reopen dialog and verify selection persisted correctly
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Save again without change - should return system
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('system'));
    });

    testWidgets('Can select dark theme and save', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Open settings dialog
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Select Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Choose Theme'), findsNothing);

      // Verify preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    testWidgets('Can select light theme and save', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Open settings dialog
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Select Light theme
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('light'));
    });

    testWidgets('Cancel does not change theme', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Open settings dialog
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Select Dark theme but cancel
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Choose Theme'), findsNothing);

      // Verify preference was NOT saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), isNull);
    });

    testWidgets('Saved theme is restored on reopen dialog',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Open settings and select Dark theme
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify Dark theme was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));

      // Reopen settings dialog
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify dialog shows all options
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Save without changing - should still be Dark
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify Dark is still the saved preference
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    testWidgets('Theme persists across app restart simulation',
        (WidgetTester tester) async {
      // Set up initial saved preference for dark theme
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Allow time for loadSavedTheme to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify MaterialApp is using dark theme mode (indicating preference was loaded)
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));

      // Open settings dialog and save without changing to verify Dark is the current selection
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Save without changing - confirms Dark was loaded as the current theme
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify the preference is still dark
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    testWidgets('MaterialApp uses correct themeMode',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Initially should be system
      expect(materialApp.themeMode, equals(ThemeMode.system));

      // Change to dark theme
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Find the updated MaterialApp
      final updatedMaterialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(updatedMaterialApp.themeMode, equals(ThemeMode.dark));
    });
  });

  group('ThemeScope tests', () {
    testWidgets('ThemeScope provides ThemeProvider to descendants',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      ThemeProvider? capturedProvider;

      await tester.pumpWidget(
        const MyApp(),
      );
      await tester.pumpAndSettle();

      // Access ThemeScope from a nested widget context
      // Use first scaffold since there may be nested scaffolds
      final context = tester.element(find.byType(Scaffold).first);
      capturedProvider = ThemeScope.of(context);

      expect(capturedProvider, isNotNull);
      expect(capturedProvider.themeMode, equals(ThemeMode.system));
    });
  });
}
