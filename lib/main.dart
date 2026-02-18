import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/nordic_theme.dart';
import 'features/calculator/presentation/calculator_shell.dart';

void main() {
  // Configure system UI (status bar, navigation bar)
  WidgetsFlutterBinding.ensureInitialized();
  NordicTheme.setSystemUIOverlay();

  // Wrap app with ProviderScope for Riverpod state management
  runApp(const ProviderScope(child: ZenithApp()));
}

class ZenithApp extends StatelessWidget {
  const ZenithApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenith - The Classy Financial Calculator',
      debugShowCheckedModeBanner: false,

      // Apply the Nordic dark theme
      theme: NordicTheme.darkTheme,

      // Launch the Calculator Shell (dual-mode: keypad + form)
      home: const CalculatorShell(),
    );
  }
}
