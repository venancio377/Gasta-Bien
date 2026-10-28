import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/comunes.dart';
import 'activities_tab.dart';
import 'checklist_tab.dart';
import 'expenses_tab.dart';
import 'savings_tab.dart';
import 'summary_tab.dart';
import 'welcome_screen.dart';

/// Contenedor principal con la barra de navegación inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  static const _titulos = [
    'Resumen',
    'Gastos',
    'Actividades',
    'Ahorro',
    'Lista de control',
  ];

  static const _paginas = <Widget>[
    SummaryTab(),
    ExpensesTab(),
    ActivitiesTab(),
    SavingsTab(),
    ChecklistTab(),
  ];

  Future<void> _editarPresupuesto() async {
    final controlador = TextEditingController(
      text: estado.presupuestoSemanal.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final nuevo = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Presupuesto semanal'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controlador,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: soloMonto,
            decoration: const InputDecoration(prefixText: '\$ '),
            validator: validarMonto,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, parsearMonto(controlador.text));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controlador.dispose();
    if (nuevo != null) estado.definirPresupuesto(nuevo);
  }

  void _cerrarSesion() {
    estado.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (ruta) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _titulos[_indice],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            backgroundColor: Paleta.azulOscuro,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                iconColor: Colors.white,
                onSelected: (valor) {
                  if (valor == 'presupuesto') _editarPresupuesto();
                  if (valor == 'salir') _cerrarSesion();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'presupuesto',
                    child: Text('Cambiar presupuesto'),
                  ),
                  PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
                ],
              ),
            ],
          ),
          body: IndexedStack(index: _indice, children: _paginas),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indice,
            onDestinationSelected: (i) => setState(() => _indice = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Resumen',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Gastos',
              ),
              const NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note),
                label: 'Actividades',
              ),
              const NavigationDestination(
                icon: Icon(Icons.savings_outlined),
                selectedIcon: Icon(Icons.savings),
                label: 'Ahorro',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: estado.pendientesLista > 0,
                  label: Text('${estado.pendientesLista}'),
                  child: const Icon(Icons.checklist_outlined),
                ),
                selectedIcon: const Icon(Icons.checklist),
                label: 'Lista',
              ),
            ],
          ),
        );
      },
    );
  }
}
