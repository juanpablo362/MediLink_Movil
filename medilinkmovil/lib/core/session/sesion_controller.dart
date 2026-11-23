import 'package:material_ui/material_ui.dart';

/// Sesión del paciente solo en memoria. No guarda tokens ni datos clínicos.
class SesionController extends ChangeNotifier {
  String? _usuario;

  String? get usuario => _usuario;

  bool get activa => _usuario != null;

  void entrar(String usuario) {
    final nombre = usuario.trim();
    if (nombre.isEmpty) {
      return;
    }
    _usuario = nombre;
    notifyListeners();
  }

  void cerrar() {
    _usuario = null;
    notifyListeners();
  }
}
