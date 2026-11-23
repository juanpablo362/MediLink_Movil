import 'package:material_ui/material_ui.dart';
import 'package:medilinkmovil/core/session/sesion_controller.dart';
import 'package:medilinkmovil/core/theme/medilink_theme.dart';
import 'package:medilinkmovil/features/acceso/acceso_page.dart';
import 'package:medilinkmovil/features/shell/paciente_shell.dart';

class MedilinkApp extends StatefulWidget {
  const MedilinkApp({super.key});

  @override
  State<MedilinkApp> createState() => _MedilinkAppState();
}

class _MedilinkAppState extends State<MedilinkApp> {
  final SesionController _sesion = SesionController();

  @override
  void dispose() {
    _sesion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sesion,
      builder: (context, _) {
        return MaterialApp(
          title: 'MediLink',
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: medilinkTheme(),
          home: _sesion.activa
              ? PacienteShell(sesion: _sesion)
              : AccesoPage(sesion: _sesion),
        );
      },
    );
  }
}
