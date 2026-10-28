import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/comunes.dart';

IconData iconoCategoria(Categoria c) {
  switch (c) {
    case Categoria.comida:
      return Icons.restaurant;
    case Categoria.transporte:
      return Icons.directions_bus;
    case Categoria.renta:
      return Icons.home_work_outlined;
    case Categoria.escuela:
      return Icons.school_outlined;
    case Categoria.ocio:
      return Icons.sports_esports_outlined;
    case Categoria.otro:
      return Icons.category_outlined;
  }
}

/// Registro de gastos de la semana.
class ExpensesTab extends StatelessWidget {
  const ExpensesTab({super.key});

  Future<void> _nuevoGasto(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FormularioGasto(),
    );
  }

  String _fecha(DateTime f) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${diasSemana[f.weekday - 1]} ${dos(f.hour)}:${dos(f.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _nuevoGasto(context),
            backgroundColor: Paleta.azulOscuro,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo gasto'),
          ),
          body: estado.gastos.isEmpty
              ? const EstadoVacio(
                  icono: Icons.receipt_long_outlined,
                  texto: 'Todavía no hay gastos esta semana.\nToca «Nuevo gasto» para anotar el primero.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: estado.gastos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final g = estado.gastos[i];
                    return Dismissible(
                      key: ValueKey(g.id),
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
                        estado.eliminarGasto(g.id);
                        mostrarMensaje(context, 'Gasto eliminado');
                      },
                      child: Tarjeta(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Paleta.azulClaro.withOpacity(0.4),
                              child: Icon(iconoCategoria(g.categoria),
                                  color: Paleta.azulTexto),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g.concepto,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    '${g.categoria.nombre} · ${_fecha(g.fecha)}',
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '-${pesos(g.monto)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Paleta.rojo),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _FormularioGasto extends StatefulWidget {
  const _FormularioGasto();

  @override
  State<_FormularioGasto> createState() => _FormularioGastoState();
}

class _FormularioGastoState extends State<_FormularioGasto> {
  final _formKey = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _monto = TextEditingController();
  Categoria _categoria = Categoria.comida;

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    estado.agregarGasto(
      _concepto.text.trim(),
      parsearMonto(_monto.text)!,
      _categoria,
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
            const Text('Nuevo gasto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _concepto,
              textCapitalization: TextCapitalization.sentences,
              decoration: decoracionCampo('Concepto', icono: Icons.edit_outlined)
                  .copyWith(fillColor: Paleta.fondo),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe en qué gastaste' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: soloMonto,
              decoration: decoracionCampo('Monto',
                      icono: Icons.attach_money, prefijo: '\$ ')
                  .copyWith(fillColor: Paleta.fondo),
              validator: validarMonto,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in Categoria.values)
                  ChoiceChip(
                    label: Text(c.nombre),
                    selected: _categoria == c,
                    onSelected: (_) => setState(() => _categoria = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar gasto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
