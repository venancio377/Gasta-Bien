import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

void mostrarMensaje(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

/// Convierte el texto de un campo a monto. Devuelve null si no es válido.
double? parsearMonto(String? texto) {
  if (texto == null) return null;
  return double.tryParse(texto.trim().replaceAll(',', ''));
}

/// Validador de montos mayores a cero.
String? validarMonto(String? texto) {
  final v = parsearMonto(texto);
  if (v == null) return 'Escribe un monto válido';
  if (v <= 0) return 'El monto debe ser mayor a 0';
  return null;
}

final List<TextInputFormatter> soloMonto = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
];

/// Estilo de campo de texto usado en toda la app.
InputDecoration decoracionCampo(String etiqueta, {IconData? icono, String? prefijo}) {
  return InputDecoration(
    labelText: etiqueta,
    prefixIcon: icono == null ? null : Icon(icono),
    prefixText: prefijo,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

/// Fondo azul con degradado para las pantallas de acceso.
class FondoDegradado extends StatelessWidget {
  const FondoDegradado({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.child,
    this.conAtras = true,
  });

  final String titulo;
  final String? subtitulo;
  final Widget child;
  final bool conAtras;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: degradadoAzul),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (conAtras)
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  )
                else
                  const SizedBox(height: 48),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón blanco principal de las pantallas de acceso.
class BotonBlanco extends StatelessWidget {
  const BotonBlanco({super.key, required this.texto, required this.onPressed});

  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Paleta.azulTexto,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Tarjeta blanca con sombra suave para las pantallas internas.
class Tarjeta extends StatelessWidget {
  const Tarjeta({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Mensaje para pantallas sin contenido.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Paleta.azulClaro),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
