# MediLink móvil

Cliente Flutter del paciente para consultar estudios de laboratorio. Repositorio público: [https://github.com/juanpablo362/MediLink_Movil](https://github.com/juanpablo362/MediLink_Movil).

La aplicación está en `medilinkmovil/`. El detalle de herramientas, versiones y configuración está en [docs/REPORTE_HERRAMIENTAS.md](docs/REPORTE_HERRAMIENTAS.md).

## Requisitos

- Flutter 3.50.1 (canal stable) con Dart 3.14.0. [Instalación de Flutter](https://docs.flutter.dev/get-started/install).
- JDK 17 o superior. En este desarrollo se usó Eclipse Temurin 21.0.13.1. Gradle 9.5 no arranca sin un JDK.
- Android SDK con plataforma API 36 y Android SDK Build-Tools. La app admite desde API 24.
- Un emulador Android o un teléfono con depuración USB. En Windows no se puede compilar el destino iOS.
- Git.

Comprueba el entorno:

```powershell
flutter doctor
java -version
```

`java -version` debe mostrar 17 o más. Si no aparece, instala un JDK y define `JAVA_HOME` con la carpeta raíz del JDK (la que contiene `bin`). En una terminal nueva:

```powershell
# Ejemplo. Sustituye la ruta por la de tu instalación.
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\ruta\al\jdk", "User")
```

Cierra y vuelve a abrir la terminal. Flutter también puede usar un JDK concreto sin tocar el registro:

```powershell
flutter config --jdk-dir="C:\ruta\al\jdk"
```

## Ejecutar

```powershell
cd medilinkmovil
flutter pub get
flutter devices
flutter run
```

Si hay varios dispositivos:

```powershell
flutter run -d <id>
```

El identificador sale en `flutter devices`.

## Probar la aplicación

1. En acceso, escribe cualquier usuario y cualquier contraseña y pulsa **Entrar**.
2. El historial muestra tres estudios ficticios. La búsqueda filtra por folio o nombre. Los filtros son Todas, Listas y En proceso.
3. El detalle de un estudio, Notificaciones, Cuenta y **Abrir con enlace** muestran «En construcción».

## Pruebas

Desde `medilinkmovil/`:

```powershell
flutter analyze
flutter test
```
