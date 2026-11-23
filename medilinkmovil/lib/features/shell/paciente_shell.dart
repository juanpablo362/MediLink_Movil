import 'package:material_ui/material_ui.dart';
import 'package:medilinkmovil/core/session/sesion_controller.dart';
import 'package:medilinkmovil/core/theme/medilink_theme.dart';
import 'package:medilinkmovil/features/cuenta/cuenta_page.dart';
import 'package:medilinkmovil/features/estudios/data/estudios_repositorio.dart';
import 'package:medilinkmovil/features/estudios/ui/estudios_page.dart';
import 'package:medilinkmovil/features/notificaciones/notificaciones_page.dart';

class PacienteShell extends StatefulWidget {
  const PacienteShell({
    super.key,
    required this.sesion,
    this.repositorio = const EstudiosRepositorio(),
  });

  final SesionController sesion;
  final EstudiosRepositorio repositorio;

  @override
  State<PacienteShell> createState() => _PacienteShellState();
}

class _PacienteShellState extends State<PacienteShell> {
  int _indice = 0;

  void _irA(int indice) => setState(() => _indice = indice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: [
          EstudiosPage(
            repositorio: widget.repositorio,
            nombre: widget.sesion.usuario ?? '',
            onNotificaciones: () => _irA(1),
            onCuenta: () => _irA(2),
          ),
          const NotificacionesPage(),
          const CuentaPage(),
        ],
      ),
      bottomNavigationBar: _BarraPaciente(indice: _indice, onChanged: _irA),
    );
  }
}

class _BarraPaciente extends StatelessWidget {
  const _BarraPaciente({required this.indice, required this.onChanged});

  final int indice;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: medilinkBone200)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _ItemBarra(
                  icono: Icons.assignment_outlined,
                  iconoActivo: Icons.assignment,
                  texto: 'Estudios',
                  activo: indice == 0,
                  onTap: () => onChanged(0),
                ),
                _ItemBarra(
                  icono: Icons.notifications_outlined,
                  iconoActivo: Icons.notifications,
                  texto: 'Notificaciones',
                  activo: indice == 1,
                  onTap: () => onChanged(1),
                ),
                _ItemBarra(
                  icono: Icons.person_outline,
                  iconoActivo: Icons.person,
                  texto: 'Cuenta',
                  activo: indice == 2,
                  onTap: () => onChanged(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  const _ItemBarra({
    required this.icono,
    required this.iconoActivo,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo ? medilinkInk : medilinkBone500;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(activo ? iconoActivo : icono, color: color),
            const SizedBox(height: 2),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 22,
              height: 3,
              decoration: BoxDecoration(
                color: activo ? medilinkCoral : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
