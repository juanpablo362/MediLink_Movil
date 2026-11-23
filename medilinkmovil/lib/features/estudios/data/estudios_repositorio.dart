import 'package:medilinkmovil/features/estudios/data/estudio.dart';

class EstudiosRepositorio {
  const EstudiosRepositorio();

  static const List<Estudio> _estudios = [
    Estudio(
      folio: 'ML-01040',
      nombre: 'Hemoglobina glucosilada',
      categoria: 'Química sanguínea',
      lugar: 'Laboratorio Aurora',
      fecha: '05/11/2026',
      estado: EstadoEstudio.lista,
    ),
    Estudio(
      folio: 'ML-01053',
      nombre: 'Tomografía de cráneo',
      categoria: 'Disponible el 14/11/2026',
      lugar: 'Centro Diagnóstico Norte',
      fecha: '14/11/2026',
      estado: EstadoEstudio.enProceso,
    ),
    Estudio(
      folio: 'ML-01048',
      nombre: 'Perfil de lípidos',
      categoria: 'Laboratorio del Valle',
      lugar: 'Laboratorio del Valle',
      fecha: '28/10/2026',
      estado: EstadoEstudio.lista,
    ),
  ];

  List<Estudio> listar({EstadoEstudio? estado}) {
    if (estado == null) {
      return List<Estudio>.unmodifiable(_estudios);
    }
    return List<Estudio>.unmodifiable(
      _estudios.where((estudio) => estudio.estado == estado),
    );
  }
}
