import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

/// Represents an ingredient within a recipe.
class Ingredient {
  final String id;
  final String name;
  final String? quantity;

  Ingredient({required this.id, required this.name, this.quantity});

  /// Creates a new Ingredient with a unique ID.
  factory Ingredient.create({required String name, String? quantity}) {
    return Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
    );
  }

  /// Creates a copy of this Ingredient with the given fields replaced.
  Ingredient copyWith({String? id, String? name, String? quantity}) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Represents a recipe containing a list of ingredients.
class Recipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  bool isInStock;

  Recipe({
    required this.id,
    required this.name,
    List<Ingredient>? ingredients,
    this.isInStock = false,
  }) : ingredients = ingredients ?? [];

  /// Creates a new Recipe with a unique ID.
  factory Recipe.create({required String name}) {
    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
  }

  /// Creates a copy of this Recipe with the given fields replaced.
  Recipe copyWith({
    String? id,
    String? name,
    List<Ingredient>? ingredients,
    bool? isInStock,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      ingredients: ingredients ?? List.from(this.ingredients),
      isInStock: isInStock ?? this.isInStock,
    );
  }
}

void main() {
  runApp(const MyApp());
}

/// The root widget of the Snack App.
///
/// Configures the app-wide theme using Material Design 3 Expressive with
/// dynamic color support and comprehensive component themes.
/// Uses [DynamicColorBuilder] to adapt to system colors on Android 12+,
/// with a fallback to a green seed color scheme using the fidelity variant
/// for more vibrant, emotionally resonant colors.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Default seed color for the app theme when dynamic colors are unavailable.
  static const Color _seedColor = Colors.green;

  /// Creates a comprehensive M3 Expressive [ThemeData] from a [ColorScheme].
  ///
  /// Includes component themes for Cards, Dialogs, FABs, AppBar, TabBar,
  /// InputDecoration, BottomSheet, and more with expressive shapes and styling.
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final textTheme = GoogleFonts.robotoTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      // Card theme with expressive rounded corners
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surfaceContainer,
      ),
      // Dialog theme with large expressive corners
      dialogTheme: DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
      // FAB theme with expressive shape
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      // AppBar theme for M3 Expressive look
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      // TabBar theme with expressive indicator
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.titleSmall,
      ),
      // Input decoration theme with filled style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      // BottomSheet theme with expressive top corners
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: colorScheme.surfaceContainerLow,
        dragHandleColor: colorScheme.onSurfaceVariant,
        showDragHandle: true,
      ),
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 1,
        ),
      ),
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      // ListTile theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: colorScheme.onSurfaceVariant,
      ),
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // Use dynamic colors from system (Android 12+)
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Fallback to seed color with fidelity variant for vibrant colors
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: Brightness.light,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: Brightness.dark,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          );
        }

        return MaterialApp(
          title: 'Snack App',
          theme: _buildTheme(lightColorScheme, Brightness.light),
          darkTheme: _buildTheme(darkColorScheme, Brightness.dark),
          home: const HomeScreen(),
        );
      },
    );
  }
}
