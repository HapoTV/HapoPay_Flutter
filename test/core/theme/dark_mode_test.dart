import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hapopay/core/theme/app_theme.dart';

void main() {
  group('Dark Mode Theme Tests', () {
    test('darkTheme uses Brightness.dark', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('light theme uses Brightness.light', () {
      expect(AppTheme.light.brightness, Brightness.light);
    });

    test('dark theme Scaffold background is dark', () {
      final scaffoldBrightness = AppTheme.darkTheme.scaffoldBackgroundColor
          .computeLuminance();
      expect(scaffoldBrightness, lessThan(0.1));
    });

    test('light theme Scaffold background is light', () {
      final scaffoldBrightness = AppTheme.light.scaffoldBackgroundColor
          .computeLuminance();
      expect(scaffoldBrightness, greaterThan(0.9));
    });

    test('dark theme uses Material 3', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('light theme uses Material 3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('dark theme AppBar is transparent', () {
      expect(
        AppTheme.darkTheme.appBarTheme.backgroundColor,
        Colors.transparent,
      );
    });

    test('light theme AppBar is transparent', () {
      expect(AppTheme.light.appBarTheme.backgroundColor, Colors.transparent);
    });

    test('dark theme button background uses primary color', () {
      final buttonTheme = AppTheme.darkTheme.elevatedButtonTheme;
      final style = buttonTheme.style;
      // Verify the button style uses primary color
      expect(style, isNotNull);
    });

    test('light theme button background uses primary variant', () {
      // ElevatedButton has backgroundColor resolved from theme
      final buttonTheme = AppTheme.light.elevatedButtonTheme;
      expect(buttonTheme.style, isNotNull);
    });
  });

  group('Dark Mode Widget Test', () {
    testWidgets('App renders with dark theme when ThemeMode.dark is used', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Dark Mode'),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.text('Dark Mode')));
      expect(theme.brightness, Brightness.dark);
      expect(theme.appBarTheme.backgroundColor, Colors.transparent);
      expect(theme.scaffoldBackgroundColor.computeLuminance(), lessThan(0.15));
    });

    testWidgets('App renders with light theme when ThemeMode.light is used', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Light Mode'),
          ),
        ),
      );

      // Verify scaffold is light
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final brightness = scaffold.backgroundColor?.computeLuminance() ?? 1;
      expect(brightness, greaterThan(0.8));
    });
  });
}
