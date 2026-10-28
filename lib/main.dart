import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const GastaBienApp());
}

/// Aplicación raíz.
class GastaBienApp extends StatelessWidget {
  const GastaBienApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasta Bien',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Paleta.azulOscuro,
        scaffoldBackgroundColor: Paleta.fondo,
      ),
      home: const WelcomeScreen(),
    );
  }
}
