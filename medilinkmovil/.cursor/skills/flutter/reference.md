# Referencia — MediLink móvil

Documentos del producto (carpeta hermana de esta app):

- `../docs/PROJECT_CONTEXT.md` — arquitectura, decisiones y reglas de seguridad.
- `../docs/CURRENT_TASK.md` — alcance del incremento web (INC-01).
- `../docs/IMPLEMENTATION_PLAN.md` — plan de ese incremento.

## Qué es esta app

Cliente Flutter del paciente: consultar y, cuando exista contrato aprobado, descargar resultados autorizados. El personal de laboratorio y el médico operan la web Angular, no esta app.

INC-01 excluye la app Flutter operativa y las notificaciones FCM. Se puede construir la interfaz contra mockups y datos ficticios. No presentar esa UI como integración con la API, R2 ni push.

## Reglas que siguen vigentes

- HTTPS en ambientes desplegados. JWT lo emite y valida la API.
- El backend autoriza cada orden y resultado. La interfaz no basta.
- Los PDF permanecen privados. No enlaces públicos permanentes ni copias locales del archivo.
- PostgreSQL guarda metadatos, no el binario. Esta app tampoco guarda el binario.
- Secretos fuera del repositorio. No registrar datos clínicos ni tokens en logs.
- Demostraciones solo con datos ficticios.

## Mockups

Usar `mockups/ui/`:

| Archivo | Pantalla |
|---|---|
| `mockup-paciente-login.jpg` | Acceso |
| `mockup-paciente-historial.jpg` | Historial de resultados |
| `mockup-paciente-detalle.jpg` | Detalle de un resultado |
| `mockup-paciente-cuenta.jpg` | Cuenta |
| `mockup-paciente-notificaciones.jpg` | Bandeja de notificaciones |
| `mockup-paciente-push.jpg` | Notificación del sistema |

## Contratos

Los endpoints de `CURRENT_TASK.md` (`POST /api/ordenes`, PDF, etc.) están marcados como propuesta y cubren el flujo de laboratorio en la web. No copiarlos a un cliente móvil sin confirmación. Pendientes que bloquean integración: campos de orden (X-01), permisos (X-02), estados (X-03), entrega de PDF (X-04/X-05).
