import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/comunes.dart';
import 'login_screen.dart';
import 'setup_screen.dart';

/// Registro de cuenta nueva.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  String _municipio = municipios.first;
  bool _ocultar = true;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _crearCuenta() {
    if (!_formKey.currentState!.validate()) return;
    estado.registrar(
      Usuario(
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim(),
        contrasena: _contrasena.text,
        municipio: _municipio,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SetupScreen()),
      (ruta) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FondoDegradado(
      titulo: 'Crea tu cuenta',
      subtitulo: 'Tarda un minuto. Después defines cuánto dinero tienes para la semana.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: decoracionCampo('Nombre', icono: Icons.person_outline),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Escribe tu nombre' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: decoracionCampo('Correo', icono: Icons.mail_outline),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                  return 'Escribe un correo válido';
                }
                return null;
              },
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
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _municipio,
              isExpanded: true,
              decoration: decoracionCampo('¿Dónde estudias?', icono: Icons.place_outlined),
              items: [
                for (final m in municipios)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: (v) => setState(() => _municipio = v ?? _municipio),
            ),
            const SizedBox(height: 26),
            BotonBlanco(texto: 'Crear cuenta', onPressed: _crearCuenta),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.9),
                ),
                child: const Text('Ya tengo cuenta · Iniciar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
