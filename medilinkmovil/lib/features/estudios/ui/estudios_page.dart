import 'package:material_ui/material_ui.dart';
import 'package:medilinkmovil/core/theme/medilink_theme.dart';
import 'package:medilinkmovil/features/estudios/data/estudio.dart';
import 'package:medilinkmovil/features/estudios/data/estudios_repositorio.dart';
import 'package:medilinkmovil/features/estudios/ui/estudio_detalle_page.dart';

enum _Filtro { todas, listas, enProceso }

class EstudiosPage extends StatefulWidget {
  const EstudiosPage({
    super.key,
    required this.repositorio,
    required this.nombre,
    required this.onNotificaciones,
    required this.onCuenta,
  });

  final EstudiosRepositorio repositorio;
  final String nombre;
  final VoidCallback onNotificaciones;
  final VoidCallback onCuenta;

  @override
  State<EstudiosPage> createState() => _EstudiosPageState();
}

class _EstudiosPageState extends State<EstudiosPage> {
  final TextEditingController _busqueda = TextEditingController();
  _Filtro _filtro = _Filtro.todas;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<Estudio> get _visibles {
    final estado = switch (_filtro) {
      _Filtro.todas => null,
      _Filtro.listas => EstadoEstudio.lista,
      _Filtro.enProceso => EstadoEstudio.enProceso,
    };
    final base = widget.repositorio.listar(estado: estado);
    final consulta = _busqueda.text.trim().toLowerCase();
    if (consulta.isEmpty) {
      return base;
    }
    return base
        .where(
          (estudio) =>
              estudio.folio.toLowerCase().contains(consulta) ||
              estudio.nombre.toLowerCase().contains(consulta),
        )
        .toList(growable: false);
  }

  void _abrirDetalle() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const EstudioDetallePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estudios = _visibles;
    final nombre = _nombreVisible(widget.nombre);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola,',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: medilinkBone500),
                        ),
                        Text(
                          nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: medilinkInk,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Mis estudios',
                          style: TextStyle(color: medilinkBone500),
                        ),
                      ],
                    ),
                  ),
                  _Iniciales(
                    texto: _iniciales(widget.nombre),
                    onTap: widget.onCuenta,
                  ),
                  const SizedBox(width: 8),
                  _Campana(onTap: widget.onNotificaciones),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar folio o estudio',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: medilinkBone200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: medilinkBone200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: medilinkInk),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  _FiltroChip(
                    texto: 'Todas',
                    activo: _filtro == _Filtro.todas,
                    onTap: () => setState(() => _filtro = _Filtro.todas),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    texto: 'Listas',
                    activo: _filtro == _Filtro.listas,
                    onTap: () => setState(() => _filtro = _Filtro.listas),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    texto: 'En proceso',
                    activo: _filtro == _Filtro.enProceso,
                    onTap: () => setState(() => _filtro = _Filtro.enProceso),
                  ),
                ],
              ),
            ),
            Expanded(
              child: estudios.isEmpty
                  ? const Center(child: Text('Ningún estudio coincide.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      itemCount: estudios.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _EstudioCard(
                          estudio: estudios[index],
                          onTap: _abrirDetalle,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _nombreVisible(String nombre) {
  final limpio = nombre.trim();
  if (limpio.isEmpty) {
    return 'Paciente';
  }
  return limpio[0].toUpperCase() + limpio.substring(1);
}

String _iniciales(String nombre) {
  final partes = nombre
      .trim()
      .split(RegExp(r'\s+'))
      .where((parte) => parte.isNotEmpty)
      .toList();
  if (partes.isEmpty) {
    return 'P';
  }
  if (partes.length == 1) {
    final palabra = partes.first;
    return palabra.length == 1
        ? palabra.toUpperCase()
        : palabra.substring(0, 2).toUpperCase();
  }
  return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
}

class _Iniciales extends StatelessWidget {
  const _Iniciales({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: medilinkCoral, width: 1.5),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            color: medilinkCoral,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Campana extends StatelessWidget {
  const _Campana({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Badge(
        label: const Text('2'),
        backgroundColor: medilinkCoral,
        child: const Icon(Icons.notifications_outlined, color: medilinkInk),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? medilinkInk : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: activo ? medilinkInk : medilinkBone200),
          ),
          child: Text(
            texto,
            style: TextStyle(
              color: activo ? Colors.white : medilinkInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EstudioCard extends StatelessWidget {
  const _EstudioCard({required this.estudio, required this.onTap});

  final Estudio estudio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lista = estudio.estado == EstadoEstudio.lista;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: medilinkBone200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A1E1B17),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        estudio.folio,
                        style: const TextStyle(
                          color: medilinkBone600,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: lista ? medilinkOk50 : medilinkCoralSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: lista
                              ? const Color(0xFFB7DFC8)
                              : const Color(0xFFFFC7B0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: Text(
                          estudio.estadoTexto,
                          style: TextStyle(
                            color: lista ? medilinkOk700 : medilinkCoralDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  estudio.nombre,
                  style: const TextStyle(
                    color: medilinkInk,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  estudio.categoria,
                  style: const TextStyle(
                    color: medilinkBone700,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: medilinkBone200,
                  ),
                ),
                Row(
                  children: [
                    const _IconoLugar(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        estudio.lugar,
                        style: const TextStyle(
                          color: medilinkInk,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: medilinkBone700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estudio.fecha,
                      style: const TextStyle(
                        color: medilinkBone700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconoLugar extends StatelessWidget {
  const _IconoLugar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: medilinkCoral,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.apartment, size: 18, color: Colors.white),
    );
  }
}
