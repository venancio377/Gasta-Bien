import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/comunes.dart';

/// Lista de control de pendientes de la semana.
class ChecklistTab extends StatelessWidget {
  const ChecklistTab({super.key});

  Future<void> _agregar(BuildContext context) async {
    final texto = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo pendiente'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: texto,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Ej. Pagar la luz'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Escribe el pendiente' : null,
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
    if (guardar == true) estado.agregarElemento(texto.text.trim());
    texto.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final total = estado.lista.length;
        final hechos = total - estado.pendientesLista;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _agregar(context),
            backgroundColor: Paleta.azulOscuro,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo pendiente'),
          ),
          body: total == 0
              ? const EstadoVacio(
                  icono: Icons.checklist_outlined,
                  texto: 'Tu lista está vacía.\nAgrega lo que no quieres olvidar esta semana.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Tarjeta(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$hechos de $total completados',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              TextButton(
                                onPressed: hechos == 0
                                    ? null
                                    : estado.reiniciarLista,
                                child: const Text('Reiniciar'),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : hechos / total,
                              minHeight: 10,
                              backgroundColor: Paleta.fondo,
                              valueColor: const AlwaysStoppedAnimation(
                                  Paleta.verde),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final e in estado.lista)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey(e.id),
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
                          onDismissed: (_) => estado.eliminarElemento(e.id),
                          child: Tarjeta(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: CheckboxListTile(
                              value: e.hecho,
                              onChanged: (_) => estado.alternarElemento(e.id),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                e.texto,
                                style: TextStyle(
                                  decoration: e.hecho
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: e.hecho ? Colors.black45 : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
