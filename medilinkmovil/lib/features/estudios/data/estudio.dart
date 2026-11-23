enum EstadoEstudio { lista, enProceso }

class Estudio {
  const Estudio({
    required this.folio,
    required this.nombre,
    required this.categoria,
    required this.lugar,
    required this.fecha,
    required this.estado,
  });

  final String folio;
  final String nombre;
  final String categoria;
  final String lugar;
  final String fecha;
  final EstadoEstudio estado;

  String get estadoTexto => switch (estado) {
    EstadoEstudio.lista => 'Lista',
    EstadoEstudio.enProceso => 'En proceso',
  };
}
