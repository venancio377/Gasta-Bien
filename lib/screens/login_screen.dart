import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/comunes.dart';
import 'home_screen.dart';
import 'register_screen.dart';

/// Inicio de sesión contra la cuenta registrada en esta sesión de la app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) return;
    if (!estado.hayCuenta) {
      mostrarMensaje(context, 'Aún no hay una cuenta. Crea una primero.');
      return;
    }
    if (estado.iniciarSesion(_correo.text, _contrasena.text)) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (ruta) => false,
      );
    } else {
      mostrarMensaje(context, 'Correo o contraseña incorrectos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FondoDegradado(
      titulo: 'Bienvenido de vuelta',
      subtitulo: 'Entra para ver cuánto te queda esta semana.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: decoracionCampo('Correo', icono: Icons.mail_outline),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe tu correo' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contrasena,
              obscureText: _ocultar,
              decoration: decoracionCampo('Contraseña', icono: Icons.lock_outline)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
            ),
            const SizedBox(height: 26),
            BotonBlanco(texto: 'Iniciar sesión', onPressed: _entrar),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.9),
                ),
                child: const Text('¿No tienes cuenta? · Regístrate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
