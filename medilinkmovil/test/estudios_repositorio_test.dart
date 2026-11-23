import 'package:flutter_test/flutter_test.dart';
import 'package:medilinkmovil/features/estudios/data/estudio.dart';
import 'package:medilinkmovil/features/estudios/data/estudios_repositorio.dart';

void main() {
  test('el filtro por estado no pierde ítems', () {
    const repositorio = EstudiosRepositorio();

    final todos = repositorio.listar();
    final listas = repositorio.listar(estado: EstadoEstudio.lista);
    final enProceso = repositorio.listar(estado: EstadoEstudio.enProceso);

    expect(listas.length + enProceso.length, todos.length);
    expect({
      ...listas.map((estudio) => estudio.folio),
      ...enProceso.map((estudio) => estudio.folio),
    }, todos.map((estudio) => estudio.folio).toSet());
  });
}
