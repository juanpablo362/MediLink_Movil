import 'package:material_ui/material_ui.dart';

const Color medilinkInk = Color(0xFF1C3C42);
const Color medilinkCrema = Color(0xFFFBF8F3);
const Color medilinkCoral = Color(0xFFE0603A);
const Color medilinkCoralDark = Color(0xFFA83F1F);
const Color medilinkCoralSoft = Color(0xFFFFE5D9);
const Color medilinkBone200 = Color(0xFFE8E2D8);
const Color medilinkBone500 = Color(0xFF7A7266);
const Color medilinkBone600 = Color(0xFF5E584E);
const Color medilinkBone700 = Color(0xFF47423A);
const Color medilinkOk50 = Color(0xFFECF8F1);
const Color medilinkOk700 = Color(0xFF17633E);

ThemeData medilinkTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: medilinkInk,
    brightness: Brightness.light,
  );
  final scheme = base.copyWith(
    primary: medilinkInk,
    onPrimary: Colors.white,
    secondary: medilinkCoral,
    onSecondary: Colors.white,
    surface: medilinkCrema,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: medilinkCrema,
    useMaterial3: true,
  );
}
