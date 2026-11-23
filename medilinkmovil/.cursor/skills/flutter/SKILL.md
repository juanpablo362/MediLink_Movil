---
name: flutter
description: >-
  Implementa y revisa la app Flutter de MediLink (medilinkmovil) con el paquete
  material_ui, flutter_lints y las pantallas de paciente de mockups/ui.
  Usar al editar Dart, widgets, pubspec.yaml, navegación, tema o pruebas de
  esta app, o cuando el usuario mencione Flutter, material_ui o MediLink móvil.
---

# Flutter — MediLink móvil

App de consulta del paciente. Paquete `medilinkmovil`. SDK Dart `^3.14.0`. Plataformas actuales: Android e iOS.

## Imports

Los widgets de Material salen de `material_ui`, no del SDK embebido.

```dart
import 'package:material_ui/material_ui.dart';
```

Ese export ya incluye `package:flutter/widgets.dart`. No importar `package:flutter/material.dart`. No añadir `cupertino_ui` ni otro paquete de UI salvo que el usuario lo pida.

`pubspec.yaml` declara `material_ui: ^1.1.0` y `flutter_lints`. No cambiar versiones ni añadir dependencias (Riverpod, Bloc, go_router, HTTP, almacenamiento) sin que el usuario lo pida. Estado con `ChangeNotifier`. Navegación con `Navigator` y un `IndexedStack` en el shell.

## Antes de tocar UI

1. Leer el mockup en `mockups/ui/` (fuente visual). Los JPG de `mockups/` son la versión anterior.
2. Copiar estructura, jerarquía y textos visibles. Textos de interfaz en español.
3. Reutilizar el tema existente. No inventar otra paleta si `ThemeData` ya está definido.

Pantallas construidas: acceso (`mockup-paciente-login.jpg`) e historial de estudios (`mockup-paciente-historial.jpg`). La barra inferior es Estudios, Notificaciones y Cuenta. Detalle, notificaciones, cuenta, el aviso push y «Abrir con enlace» muestran «En construcción». No completarlas hasta que el usuario lo pida.

## Arquitectura

Por feature. Dos capas solo donde hay datos:

- **ui**: páginas y widgets. No llama HTTP ni decide permisos.
- **data**: modelo y repositorio. El repositorio en memoria se sustituye por la API sin mover las páginas.

Sin capa `domain`. Sin paquetes de estado ni de router.

`lib/main.dart` solo llama a `runApp`. `lib/app.dart` arma `MaterialApp` (locale `es`, tema de `core/theme/`) y elige acceso o shell según `SesionController`.

```
lib/
  main.dart
  app.dart
  core/
    theme/medilink_theme.dart
    session/sesion_controller.dart
  features/
    acceso/acceso_page.dart
    shell/paciente_shell.dart
    estudios/
      ui/estudios_page.dart
      ui/estudio_detalle_page.dart
      data/estudio.dart
      data/estudios_repositorio.dart
    notificaciones/notificaciones_page.dart
    cuenta/cuenta_page.dart
test/
```

Nombres de archivo en `snake_case`. Constructores `const` cuando el widget lo permita. Notificaciones y cuenta no tienen repositorio hasta que haya contenido real. El detalle de un estudio se abre con `Navigator.push` encima de Estudios.

## Datos clínicos

Datos de demostración ficticios. No commitear secretos, tokens, keystores ni PDFs reales. No guardar resultados PDF ni expedientes en el dispositivo. La API y la autorización viven en el backend; esta app no decide permisos.

El contrato REST de `../docs/` es una propuesta del incremento web y marca Flutter fuera de ese incremento. No inventar endpoints ni clientes HTTP. Si hace falta integrar la API, leer [reference.md](reference.md) y confirmar el contrato con el usuario.

## Verificación

Tras cambiar Dart:

```bash
dart format .
flutter analyze
```

Si hay tests afectados o nuevos, `flutter test`. Corregir lo que falle antes de dar la tarea por terminada.

## Referencia

Reglas de producto, documentos y límites de alcance: [reference.md](reference.md).
