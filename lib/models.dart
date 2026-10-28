/// Categorías de gasto disponibles.
enum Categoria {
  comida('Comida'),
  transporte('Transporte'),
  renta('Renta y servicios'),
  escuela('Escuela'),
  ocio('Ocio'),
  otro('Otro');

  const Categoria(this.nombre);
  final String nombre;
}

const List<String> diasSemana = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const List<String> municipios = [
  'Dolores Hidalgo C.I.N.',
  'San Miguel de Allende',
  'San Luis de la Paz',
  'San Diego de la Unión',
  'San Felipe',
  'Doctor Mora',
  'Victoria',
  'Xichú',
  'Otro',
];

class Gasto {
  Gasto({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });

  final int id;
  final String concepto;
  final double monto;
  final Categoria categoria;
  final DateTime fecha;
}

class Actividad {
  Actividad({
    required this.id,
    required this.nombre,
    required this.dia,
    required this.costo,
    this.realizada = false,
  });

  final int id;
  final String nombre;

  /// 1 = lunes ... 7 = domingo (igual que DateTime.weekday).
  final int dia;
  final double costo;
  bool realizada;
}

class MetaAhorro {
  MetaAhorro({
    required this.nombre,
    required this.objetivo,
    this.ahorrado = 0,
  });

  String nombre;
  double objetivo;
  double ahorrado;

  double get avance => objetivo <= 0 ? 0 : (ahorrado / objetivo).clamp(0.0, 1.0);
}

class ElementoLista {
  ElementoLista({required this.id, required this.texto, this.hecho = false});

  final int id;
  final String texto;
  bool hecho;
}

class Usuario {
  Usuario({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.municipio,
  });

  final String nombre;
  final String correo;
  final String contrasena;
  final String municipio;
}
