import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/comunes.dart';

/// Meta de ahorro opcional.
class SavingsTab extends StatelessWidget {
  const SavingsTab({super.key});

  Future<void> _editarMeta(BuildContext context) async {
    final meta = estado.meta;
    final nombre = TextEditingController(text: meta?.nombre ?? '');
    final objetivo = TextEditingController(
      text: meta == null ? '' : meta.objetivo.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(meta == null ? 'Nueva meta de ahorro' : 'Editar meta'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombre,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: '¿Para qué ahorras?'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ponle un nombre' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: objetivo,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: soloMonto,
                decoration: const InputDecoration(
                    labelText: 'Monto a juntar', prefixText: '\$ '),
                validator: validarMonto,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (guardar == true) {
      estado.guardarMeta(nombre.text.trim(), parsearMonto(objetivo.text)!);
    }
    nombre.dispose();
    objetivo.dispose();
  }

  Future<void> _abonar(BuildContext context) async {
    final monto = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar ahorro'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: monto,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: soloMonto,
            decoration: const InputDecoration(prefixText: '\$ '),
            validator: validarMonto,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (guardar == true) estado.abonarMeta(parsearMonto(monto.text)!);
    monto.dispose();
  }

  Future<void> _quitar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Quitar la meta?'),
        content: const Text('Se borra la meta y lo que llevabas registrado en ella.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmar == true) estado.eliminarMeta();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final meta = estado.meta;
        if (meta == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.savings_outlined,
                      size: 72, color: Paleta.azulClaro),
                  const SizedBox(height: 14),
                  const Text(
                    'La meta de ahorro es opcional.\nCrea una si quieres apartar dinero para algo en concreto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _editarMeta(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear meta'),
                  ),
                ],
              ),
            ),
          );
        }

        final completa = meta.avance >= 1;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Tarjeta(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.nombre,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => _editarMeta(context),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Quitar',
                        onPressed: () => _quitar(context),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pesos(meta.ahorrado),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Paleta.azulTexto,
                    ),
                  ),
                  Text('de ${pesos(meta.objetivo)}',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: meta.avance,
                      minHeight: 12,
                      backgroundColor: Paleta.fondo,
                      valueColor: AlwaysStoppedAnimation(
                        completa ? Paleta.verde : Paleta.azulOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completa
                        ? 'Meta cumplida'
                        : '${(meta.avance * 100).toStringAsFixed(0)}% · faltan ${pesos(meta.objetivo - meta.ahorrado)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: completa ? Paleta.verde : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _abonar(context),
                icon: const Icon(Icons.add),
                label: const Text('Agregar ahorro'),
              ),
            ),
          ],
        );
      },
    );
  }
}
