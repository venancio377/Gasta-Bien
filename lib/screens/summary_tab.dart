import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/comunes.dart';

/// Resumen de la semana: presupuesto, gastado, disponible y categorías.
class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  static const _colores = {
    Categoria.comida: Color(0xFFE08A3C),
    Categoria.transporte: Color(0xFF5B8FC9),
    Categoria.renta: Color(0xFF7A62C9),
    Categoria.escuela: Color(0xFF2E9E6B),
    Categoria.ocio: Color(0xFFD1578C),
    Categoria.otro: Color(0xFF8A94A6),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final disponible = estado.disponible;
        final excedido = disponible < 0;
        final avance = estado.avancePresupuesto;
        final colorBarra = excedido
            ? Paleta.rojo
            : (avance > 0.8 ? Paleta.ambar : Paleta.verde);
        final porCategoria = estado.gastoPorCategoria;
        final categoriasOrdenadas = porCategoria.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final comprometido = estado.costoActividadesPendientes;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Tarjeta principal ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: degradadoAzul,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    excedido ? 'Te pasaste por' : 'Te quedan',
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pesos(disponible.abs()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: avance,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation(
                        excedido ? Paleta.rojo : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gastado ${pesos(estado.totalGastado)}',
                          style: const TextStyle(color: Colors.white)),
                      Text('de ${pesos(estado.presupuestoSemanal)}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Cuánto puedes gastar por día ----
            Tarjeta(
              child: Row(
                children: [
                  Icon(Icons.today, color: colorBarra, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          excedido
                              ? 'Sin margen para los próximos días'
                              : '${pesos(estado.disponiblePorDia)} por día',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          estado.diasRestantes == 1
                              ? 'Hoy es el último día de la semana'
                              : 'Quedan ${estado.diasRestantes} días contando hoy',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- Aviso de actividades ----
            if (comprometido > 0) ...[
              const SizedBox(height: 14),
              Tarjeta(
                child: Row(
                  children: [
                    Icon(
                      comprometido > disponible
                          ? Icons.warning_amber_rounded
                          : Icons.event_available,
                      color: comprometido > disponible
                          ? Paleta.ambar
                          : Paleta.azulOscuro,
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        comprometido > disponible
                            ? 'Tus actividades pendientes cuestan ${pesos(comprometido)} y no te alcanza.'
                            : 'Tus actividades pendientes cuestan ${pesos(comprometido)}. Te alcanza.',
                        style: const TextStyle(fontSize: 14, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ---- Gasto por categoría ----
            const SizedBox(height: 18),
            const Text('Gasto por categoría',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (categoriasOrdenadas.isEmpty)
              const Tarjeta(
                child: Text(
                  'Aún no registras gastos. Ve a la pestaña Gastos para anotar el primero.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              Tarjeta(
                child: Column(
                  children: [
                    for (final e in categoriasOrdenadas)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key.nombre),
                                Text(pesos(e.value),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: estado.totalGastado <= 0
                                    ? 0
                                    : e.value / estado.totalGastado,
                                minHeight: 7,
                                backgroundColor: Paleta.fondo,
                                valueColor:
                                    AlwaysStoppedAnimation(_colores[e.key]!),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
