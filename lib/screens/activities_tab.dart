import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/comunes.dart';

/// Planificación de actividades de la semana con su costo estimado.
class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  Future<void> _nueva(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FormularioActividad(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final porDia = <int, List<Actividad>>{};
        for (final a in estado.actividades) {
          porDia.putIfAbsent(a.dia, () => []).add(a);
        }
        final dias = porDia.keys.toList()..sort();
        final pendiente = estado.costoActividadesPendientes;
        final alcanza = pendiente <= estado.disponible;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _nueva(context),
            backgroundColor: Paleta.azulOscuro,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nueva actividad'),
          ),
          body: estado.actividades.isEmpty
              ? const EstadoVacio(
                  icono: Icons.event_note_outlined,
                  texto: 'Planea tus salidas, comidas fuera o pasajes de la semana y mira si te alcanza.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Tarjeta(
                      child: Row(
                        children: [
                          Icon(
                            alcanza
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_rounded,
                            color: alcanza ? Paleta.verde : Paleta.ambar,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              alcanza
                                  ? 'Pendiente por gastar: ${pesos(pendiente)}. Tu saldo es ${pesos(estado.disponible)}.'
                                  : 'Pendiente por gastar: ${pesos(pendiente)}. Te faltan ${pesos(pendiente - estado.disponible)}.',
                              style: const TextStyle(height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final d in dias) ...[
                      const SizedBox(height: 18),
                      Text(diasSemana[d - 1],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      for (final a in porDia[d]!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey(a.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Paleta.rojo,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              estado.eliminarActividad(a.id);
                              mostrarMensaje(context, 'Actividad eliminada');
                            },
                            child: Tarjeta(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: CheckboxListTile(
                                value: a.realizada,
                                onChanged: (_) => estado.alternarActividad(a.id),
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(
                                  a.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: a.realizada
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: a.realizada ? Colors.black45 : null,
                                  ),
                                ),
                                subtitle: Text(
                                  a.costo > 0
                                      ? 'Costo estimado ${pesos(a.costo)}'
                                      : 'Sin costo',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _FormularioActividad extends StatefulWidget {
  const _FormularioActividad();

  @override
  State<_FormularioActividad> createState() => _FormularioActividadState();
}

class _FormularioActividadState extends State<_FormularioActividad> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _costo = TextEditingController();
  int _dia = DateTime.now().weekday;

  @override
  void dispose() {
    _nombre.dispose();
    _costo.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    estado.agregarActividad(
      _nombre.text.trim(),
      _dia,
      parsearMonto(_costo.text) ?? 0,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva actividad',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.sentences,
              decoration: decoracionCampo('Actividad', icono: Icons.event_outlined)
                  .copyWith(fillColor: Paleta.fondo),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe la actividad' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _dia,
              decoration: decoracionCampo('Día', icono: Icons.calendar_today_outlined)
                  .copyWith(fillColor: Paleta.fondo),
              items: [
                for (var i = 1; i <= 7; i++)
                  DropdownMenuItem(value: i, child: Text(diasSemana[i - 1])),
              ],
              onChanged: (v) => setState(() => _dia = v ?? _dia),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costo,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: soloMonto,
              decoration: decoracionCampo('Costo estimado (opcional)',
                      icono: Icons.attach_money, prefijo: '\$ ')
                  .copyWith(fillColor: Paleta.fondo),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return parsearMonto(v) == null ? 'Monto no válido' : null;
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar actividad'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
