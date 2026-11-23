# Reporte de herramientas, versiones y configuración

**Proyecto:** MediLink móvil (`medilinkmovil`)  
**Fecha:** 22 de noviembre de 2026  
**Repositorio:** [https://github.com/juanpablo362/MediLink_Movil](https://github.com/juanpablo362/MediLink_Movil)  
**Visibilidad:** pública  
**Rama por defecto:** `main`

Las instrucciones para configurar el entorno y ejecutar la aplicación están en el [README](../README.md).

## Herramientas y versiones

| Herramienta | Versión | Dónde se fija |
|---|---|---|
| Flutter | 3.50.1, canal stable, revisión `ae9b586f34` (2026-11-18) | SDK instalado en el equipo |
| Dart | 3.14.0 | `medilinkmovil/pubspec.yaml` (`sdk: ^3.14.0`) |
| DevTools | 2.61.0 | Incluido con Flutter |
| `material_ui` | 1.11.1 (restricción `^1.1.0`) | `pubspec.yaml` y `pubspec.lock` |
| `flutter_lints` | 6.0.0 | `pubspec.yaml` |
| Kotlin | 2.4.20 | `android/settings.gradle.kts` |
| Android Gradle Plugin | 9.3.1 | `android/settings.gradle.kts` |
| Gradle | 9.5.0 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Java de compilación | 17 (bytecode) | `android/app/build.gradle.kts` |
| JDK usado en este equipo | Eclipse Temurin 21.0.13.1+2 | Instalación local; no va en el repositorio |
| Android `compileSdk` / `targetSdk` | 36 | Valores del SDK de Flutter 3.50.1 |
| Android `minSdk` | 24 | Valores del SDK de Flutter 3.50.1 |
| NDK | 28.2.13676358 | Valores del SDK de Flutter 3.50.1 |
| Sistema de desarrollo | Windows 11 (10.0.26200) | Equipo local |
| Git | Repositorio en `main` | Este directorio |

No hay paquetes de estado, enrutador ni cliente HTTP. La interfaz usa `package:material_ui/material_ui.dart`. El estado de sesión es un `ChangeNotifier` en memoria.

## Configuración del proyecto

- Paquete Dart: `medilinkmovil`. Versión de la app: `0.1.0+1`. `publish_to: none`.
- Plataformas generadas: Android e iOS. La ejecución documentada es Android.
- `android/local.properties` lo genera Flutter en cada máquina (ruta del SDK y de Flutter) y está en `.gitignore`. No se versiona.
- `android/gradle.properties` deja la memoria de Gradle y AndroidX. No fija `org.gradle.java.home`, para no atar el proyecto a una ruta de un solo equipo.
- Análisis estático: `analysis_options.yaml` incluye `package:flutter_lints/flutter.yaml`.
- Identificador Android de plantilla: `com.example.medilinkmovil`.

En el equipo de desarrollo el JDK quedó en `%LOCALAPPDATA%\Programs\jdk-21\jdk-21.0.13.1+2` y Flutter se apuntó con `flutter config --jdk-dir`. Esa configuración es del usuario, no del repositorio. Quien clone el proyecto debe tener `java` en el PATH o repetir `flutter config --jdk-dir`.

`flutter doctor` en este equipo también avisó de dos piezas que no impiden `flutter run` en Android si el SDK ya está instalado: faltan Android cmdline-tools y no está instalado Chrome. El destino web no forma parte de esta entrega.

## Versionamiento

El remoto `origin` es `https://github.com/juanpablo362/MediLink_Movil.git`.

Historial publicado al escribir este reporte:

| Commit | Fecha | Autor | Mensaje |
|---|---|---|---|
| `c23d0d8` | 2026-11-22 | Tempest012 | Documentos |

Ese commit está en `main` y en `origin/main`. La carpeta `medilinkmovil/` y este reporte están en el árbol de trabajo local; todavía no forman parte de ese commit remoto. Para que un revisor los vea en GitHub hay que confirmarlos y empujar la rama `main` desde este equipo.
