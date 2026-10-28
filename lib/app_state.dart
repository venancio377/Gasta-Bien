import 'package:flutter/foundation.dart';

import 'models.dart';

/// Estado global de la app. Vive en memoria: al cerrar la app se reinicia.
class AppState extends ChangeNotifier {
  Usuario? _registrado;
  Usuario? usuario; // sesión activa

  double presupuestoSemanal = 0;
  final List<Gasto> gastos = [];
  final List<Actividad> actividades = [];
  MetaAhorro? meta;
  final List<ElementoLista> lista = [];

  int _siguienteId = 1;
  int _nuevoId() => _siguienteId++;

  // ---------------- Sesión ----------------

  /// Crea la cuenta e inicia sesión.
  void registrar(Usuario nuevo) {
    _registrado = nuevo;
    usuario = nuevo;
    _cargarListaInicial();
    notifyListeners();
  }

  /// Devuelve true si las credenciales coinciden con la cuenta registrada.
  bool iniciarSesion(String correo, String contrasena) {
    final u = _registrado;
    if (u == null) return false;
    if (u.correo.toLowerCase() == correo.trim().toLowerCase() &&
        u.contrasena == contrasena) {
      usuario = u;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool get hayCuenta => _registrado != null;

  void cerrarSesion() {
    usuario = null;
    notifyListeners();
  }

  // ---------------- Presupuesto y gastos ----------------

  void definirPresupuesto(double monto) {
    presupuestoSemanal = monto;
    notifyListeners();
  }

  double get totalGastado => gastos.fold(0.0, (s, g) => s + g.monto);

  double get disponible => presupuestoSemanal - totalGastado;

  double get avancePresupuesto => presupuestoSemanal <= 0
      ? 0
      : (totalGastado / presupuestoSemanal).clamp(0.0, 1.0);

  /// Días que quedan de la semana contando hoy (lunes-domingo).
  int get diasRestantes => 8 - DateTime.now().weekday;

  double get disponiblePorDia =>
      diasRestantes <= 0 ? 0 : disponible / diasRestantes;

  Map<Categoria, double> get gastoPorCategoria {
    final mapa = <Categoria, double>{};
    for (final g in gastos) {
      mapa[g.categoria] = (mapa[g.categoria] ?? 0) + g.monto;
    }
    return mapa;
  }

  void agregarGasto(String concepto, double monto, Categoria categoria) {
    gastos.insert(
      0,
      Gasto(
        id: _nuevoId(),
        concepto: concepto,
        monto: monto,
        categoria: categoria,
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void eliminarGasto(int id) {
    gastos.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // ---------------- Actividades ----------------

  double get costoActividadesPendientes => actividades
      .where((a) => !a.realizada)
      .fold(0.0, (s, a) => s + a.costo);

  void agregarActividad(String nombre, int dia, double costo) {
    actividades.add(
      Actividad(id: _nuevoId(), nombre: nombre, dia: dia, costo: costo),
    );
    actividades.sort((a, b) => a.dia.compareTo(b.dia));
    notifyListeners();
  }

  void alternarActividad(int id) {
    final a = actividades.firstWhere((x) => x.id == id);
    a.realizada = !a.realizada;
    notifyListeners();
  }

  void eliminarActividad(int id) {
    actividades.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ---------------- Meta de ahorro (opcional) ----------------

  void guardarMeta(String nombre, double objetivo) {
    final actual = meta;
    if (actual == null) {
      meta = MetaAhorro(nombre: nombre, objetivo: objetivo);
    } else {
      actual.nombre = nombre;
      actual.objetivo = objetivo;
    }
    notifyListeners();
  }

  void abonarMeta(double monto) {
    final m = meta;
    if (m == null) return;
    m.ahorrado += monto;
    notifyListeners();
  }

  void eliminarMeta() {
    meta = null;
    notifyListeners();
  }

  // ---------------- Lista de control ----------------

  void _cargarListaInicial() {
    if (lista.isNotEmpty) return;
    const base = [
      'Pagar la renta del cuarto',
      'Comprar la despensa de la semana',
      'Separar el pasaje de ida y vuelta a casa',
      'Revisar el saldo de la tarjeta de transporte',
      'Anotar los gastos del día',
    ];
    for (final t in base) {
      lista.add(ElementoLista(id: _nuevoId(), texto: t));
    }
  }

  int get pendientesLista => lista.where((e) => !e.hecho).length;

  void agregarElemento(String texto) {
    lista.add(ElementoLista(id: _nuevoId(), texto: texto));
    notifyListeners();
  }

  void alternarElemento(int id) {
    final e = lista.firstWhere((x) => x.id == id);
    e.hecho = !e.hecho;
    notifyListeners();
  }

  void eliminarElemento(int id) {
    lista.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void reiniciarLista() {
    for (final e in lista) {
      e.hecho = false;
    }
    notifyListeners();
  }
}

/// Instancia única usada por todas las pantallas.
final AppState estado = AppState();
