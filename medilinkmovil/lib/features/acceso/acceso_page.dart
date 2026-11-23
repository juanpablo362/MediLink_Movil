import 'package:material_ui/material_ui.dart';
import 'package:medilinkmovil/core/session/sesion_controller.dart';
import 'package:medilinkmovil/core/theme/medilink_logo.dart';
import 'package:medilinkmovil/core/theme/medilink_theme.dart';
import 'package:medilinkmovil/core/ui/en_construccion_page.dart';

class AccesoPage extends StatefulWidget {
  const AccesoPage({super.key, required this.sesion});

  final SesionController sesion;

  @override
  State<AccesoPage> createState() => _AccesoPageState();
}

class _AccesoPageState extends State<AccesoPage> {
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _entrar() {
    final usuario = _usuario.text.trim();
    final contrasena = _contrasena.text;
    if (usuario.isEmpty || contrasena.trim().isEmpty) {
      setState(() => _error = 'Escribe usuario y contraseña.');
      return;
    }
    setState(() => _error = null);
    widget.sesion.entrar(usuario);
  }

  void _abrirConEnlace() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const EnConstruccionPage(conRegreso: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            const MedilinkLogo(),
            const SizedBox(height: 12),
            const Center(child: _ChipPaciente()),
            const SizedBox(height: 40),
            Text(
              'Inicia sesión',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: medilinkInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consulta tu historial de estudios y resultados',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: medilinkBone500,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Usuario',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usuario,
              textInputAction: TextInputAction.next,
              decoration: _campo(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contraseña',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contrasena,
              obscureText: true,
              onSubmitted: (_) => _entrar(),
              decoration: _campo(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: medilinkCoral,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _entrar,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _abrirConEnlace,
              child: const Text(
                'Abrir con enlace',
                style: TextStyle(
                  color: medilinkInk,
                  decoration: TextDecoration.underline,
                  decorationColor: medilinkInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _campo() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: medilinkBone200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: medilinkBone200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: medilinkInk, width: 1.4),
      ),
    );
  }
}

class _ChipPaciente extends StatelessWidget {
  const _ChipPaciente();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: medilinkCoralSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          'Paciente',
          style: TextStyle(
            color: medilinkCoralDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
