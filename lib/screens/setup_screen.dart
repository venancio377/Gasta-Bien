import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/comunes.dart';
import 'home_screen.dart';

/// Configuración inicial: presupuesto de la semana y meta de ahorro opcional.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _presupuesto = TextEditingController();
  final _metaNombre = TextEditingController();
  final _metaMonto = TextEditingController();
  bool _conMeta = false;

  @override
  void dispose() {
    _presupuesto.dispose();
    _metaNombre.dispose();
    _metaMonto.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    estado.definirPresupuesto(parsearMonto(_presupuesto.text)!);
    if (_conMeta) {
      estado.guardarMeta(_metaNombre.text.trim(), parsearMonto(_metaMonto.text)!);
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (ruta) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = estado.usuario?.nombre.split(' ').first ?? '';
    return FondoDegradado(
      conAtras: false,
      titulo: nombre.isEmpty ? 'Tu semana' : 'Hola, $nombre',
      subtitulo: '¿Con cuánto dinero cuentas esta semana para todos tus gastos?',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _presupuesto,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: soloMonto,
              decoration: decoracionCampo('Presupuesto semanal',
                  icono: Icons.attach_money, prefijo: '\$ '),
              validator: validarMonto,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
                value: _conMeta,
                onChanged: (v) => setState(() => _conMeta = v),
                activeColor: Colors.white,
                title: const Text(
                  'Quiero una meta de ahorro',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Opcional. Puedes crearla o quitarla después.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ),
            if (_conMeta) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _metaNombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: decoracionCampo('¿Para qué quieres ahorrar?',
                    icono: Icons.savings_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ponle un nombre a tu meta' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _metaMonto,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: soloMonto,
                decoration: decoracionCampo('Monto a juntar',
                    icono: Icons.flag_outlined, prefijo: '\$ '),
                validator: validarMonto,
              ),
            ],
            const SizedBox(height: 26),
            BotonBlanco(texto: 'Empezar', onPressed: _continuar),
          ],
        ),
      ),
    );
  }
}
