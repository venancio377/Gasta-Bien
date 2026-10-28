import 'package:flutter/material.dart';

/// Paleta tomada del boceto de la pantalla de bienvenida.
class Paleta {
  static const Color azulClaro = Color(0xFFA9C9EE);
  static const Color azulMedio = Color(0xFF5B8FC9);
  static const Color azulOscuro = Color(0xFF2F6DB5);
  static const Color azulTexto = Color(0xFF1F4E8C);
  static const Color fondo = Color(0xFFF3F7FC);
  static const Color verde = Color(0xFF2E9E6B);
  static const Color rojo = Color(0xFFD64545);
  static const Color ambar = Color(0xFFE0A21B);
}

const LinearGradient degradadoAzul = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Paleta.azulClaro, Paleta.azulMedio, Paleta.azulOscuro],
);

/// Formatea un monto como pesos: $1,250.50
String pesos(double valor) {
  final negativo = valor < 0;
  final partes = valor.abs().toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '${negativo ? '-' : ''}\$$entero.${partes[1]}';
}
