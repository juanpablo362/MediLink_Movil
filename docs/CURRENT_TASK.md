# CURRENT_TASK.md — MediLink

**Incremento:** INC-01 — Registro de órdenes con operación offline y gestión segura de resultados PDF  
**Estado:** Especificación propuesta; pendiente de validación del equipo  
**Versión:** 1.0  
**Documento de contexto:** `PROJECT_CONTEXT.md`  
**Plan de trabajo:** `IMPLEMENTATION_PLAN.md`

## 1. Objetivo del incremento

Implementar y demostrar en la aplicación web de MediLink un flujo mínimo de principio a fin: el personal autorizado registra una orden de laboratorio, puede conservar una orden pendiente sin conexión, la sincroniza sin duplicados al recuperar conectividad, publica el PDF del resultado en almacenamiento privado y un usuario autorizado puede consultarlo. Los criterios de seguridad se aplican desde la API.

Este alcance **concreta**, sin sustituir, la prioridad del primer incremento indicada en el Entregable 2. No supone que las pantallas, endpoints o campos aquí propuestos ya estén desarrollados o aprobados.

## 2. Historias de usuario del incremento

| ID | Como… | Quiero… | Para… |
|---|---|---|---|
| HU-01 | Personal del laboratorio | Capturar una orden con datos mínimos y recibir confirmación | Registrar un estudio de forma trazable |
| HU-02 | Personal del laboratorio | Guardar temporalmente una orden al no tener conexión | Evitar perder la captura durante fallas de red |
| HU-03 | Personal del laboratorio | Reenviar órdenes pendientes sin generar duplicados | Recuperar el funcionamiento normal con integridad |
| HU-04 | Personal del laboratorio autorizado | Adjuntar un resultado PDF a una orden | Publicar el resultado de forma privada |
| HU-05 | Médico o paciente autorizado | Consultar o descargar un resultado asociado | Acceder al documento correspondiente |
| HU-06 | Usuario no autorizado | Recibir una denegación al solicitar resultados ajenos | Proteger la confidencialidad clínica |

## 3. Alcance funcional incluido

**F-01. Registro online de órdenes:** formulario Angular con validaciones básicas; solicitud a API; persistencia en PostgreSQL; respuesta con identificador de orden. Los campos exactos requieren aprobación (X-01).

**F-02. Captura offline limitada:** si la API no está disponible, guardar en IndexedDB la información mínima y `clientOperationId`; mostrar la orden como pendiente. No almacenar PDF ni expediente clínico completo.

**F-03. Sincronización e idempotencia:** reintentar órdenes pendientes al recuperar conectividad o por acción del usuario. La API debe reconocer un mismo `clientOperationId` y evitar registrar una segunda orden equivalente. La cola solo cambia a `sincronizada` tras confirmación válida.

**F-04. Publicación privada de resultado:** personal autorizado selecciona una orden y carga PDF; la API valida permisos y archivo, coloca el objeto en Cloudflare R2 privado y registra en PostgreSQL su referencia y metadatos.

**F-05. Consulta autorizada:** el backend verifica relación y permisos del solicitante sobre la orden/resultado antes de recuperar el archivo. Un usuario sin permisos recibe denegación sin exponer el archivo.

**F-06. Estado y errores visibles:** interfaz informa registro exitoso, pendiente de sincronización, error recuperable, error de validación y acceso denegado.

## 4. Fuera de alcance

- Cliente nativo/multiplataforma Flutter en funcionamiento.
- Envío de notificaciones push por Firebase Cloud Messaging.
- Consulta sin conexión de resultados o almacenamiento local de PDF.
- Expedientes clínicos completos offline.
- Facturación, pagos, interoperabilidad con terceros e integración con instrumental.
- Analítica avanzada, reportes estadísticos y funcionalidades administrativas no imprescindibles para probar el recorrido.
- Reglas de roles, tiempos de retención o tipos de estudio no documentados: requieren validación y no se asumirán en código.

## 5. Reglas de negocio y restricciones

| ID | Regla verificable |
|---|---|
| RN-01 | Una orden requiere los campos obligatorios que apruebe el equipo; la API rechaza solicitudes incompletas o inválidas. |
| RN-02 | Cada operación de creación lleva un `clientOperationId` estable; repetirla no crea una segunda orden. |
| RN-03 | El estado `sincronizada` se asigna solo después de una confirmación válida de la API. |
| RN-04 | Los errores temporales dejan la orden en la cola; los errores de validación/autorización se muestran y no se reintentan de forma indefinida. |
| RN-05 | La cola offline contiene solo datos mínimos de órdenes, sin PDF ni expediente completo. |
| RN-06 | Solo usuarios autenticados y autorizados pueden crear/publicar/consultar según permisos por recurso. |
| RN-07 | El almacenamiento de PDF es privado; la API verifica autorización antes de habilitar acceso. |
| RN-08 | PostgreSQL conserva referencia y metadatos de PDF, no su contenido binario. |
| RN-09 | Las credenciales se almacenan fuera del repositorio y las comunicaciones desplegadas usan HTTPS. |

## 6. Contratos REST de referencia (PROPUESTA; no definitivos)

| Operación | Endpoint sugerido | Entrada | Resultado esperado |
|---|---|---|---|
| Crear orden | `POST /api/ordenes` | Datos mínimos + `clientOperationId` | `201 Created` con identificador, o respuesta idempotente con la orden existente |
| Consultar orden | `GET /api/ordenes/{id}` | ID y credencial | Orden si el usuario está autorizado |
| Publicar PDF | `POST /api/ordenes/{id}/resultado` | PDF mediante `multipart/form-data` | Referencia y metadatos almacenados |
| Consultar PDF | `GET /api/ordenes/{id}/resultado/archivo` | Credencial y permiso sobre orden | PDF entregado por API o mecanismo seguro que se defina |

**Nota:** códigos HTTP concretos, formato de errores, DTO, límite de archivo y política de URL firmada se acordarán antes de implementar y probar el contrato. El ejemplo `201` describe únicamente el primer registro; una repetición idempotente debe devolver la misma identidad lógica, sin duplicar registros.

## 7. Criterios de aceptación (CA)

| ID | Escenario y condición verificable | Evidencia mínima |
|---|---|---|
| CA-01 | **Dado** un usuario autorizado y datos válidos, **cuando** crea una orden online, **entonces** la API confirma y existe exactamente una orden en PostgreSQL. | Captura de interfaz + respuesta API + consulta DB |
| CA-02 | **Dado** un campo obligatorio faltante, **cuando** se envía una orden, **entonces** la API la rechaza sin insertar registros y la interfaz muestra el error. | Prueba de validación y DB sin nueva fila |
| CA-03 | **Dado** que la API no está disponible, **cuando** el usuario registra una orden mínima, **entonces** se guarda en IndexedDB y aparece como `pendiente`, aun tras recargar la página. | DevTools IndexedDB + captura de estado |
| CA-04 | **Dada** una orden pendiente, **cuando** vuelve la conectividad y la API confirma, **entonces** la orden llega una sola vez a PostgreSQL y queda marcada `sincronizada`. | Capturas antes/después + conteo DB |
| CA-05 | **Dado** el mismo `clientOperationId` reenviado dos o más veces, **cuando** la API procesa las solicitudes, **entonces** no se crean órdenes duplicadas. | Prueba automatizada/repetición + conteo DB |
| CA-06 | **Dado** un fallo transitorio durante la sincronización, **cuando** no existe confirmación válida, **entonces** la orden sigue recuperable y no se marca como sincronizada. | Simulación de error de red + IndexedDB |
| CA-07 | **Dada** una orden válida y personal autorizado, **cuando** se publica un PDF aceptado, **entonces** el archivo se guarda privadamente en R2 y sus metadatos/referencia aparecen en PostgreSQL. | Evidencia API + objeto privado + registro DB |
| CA-08 | **Dado** un usuario autorizado para una orden con resultado, **cuando** solicita el PDF, **entonces** la API permite obtener el documento correcto. | Prueba de acceso permitido |
| CA-09 | **Dado** un usuario autenticado sin autorización sobre el resultado, **cuando** solicita el PDF, **entonces** se deniega el acceso y no se revela el archivo. | Prueba de acceso denegado |
| CA-10 | **Dado** un usuario sin autenticación, **cuando** solicita un recurso protegido, **entonces** se rechaza la solicitud y no se entrega información sensible. | Prueba API sin token |
| CA-11 | **Durante** una inspección de IndexedDB y PostgreSQL, **no** existen PDF locales ni binarios PDF en tablas relacionales. | Evidencia de inspección |
| CA-12 | **Al cerrar** el incremento, se puede ejecutar de forma repetible el recorrido crear → offline/sincronizar → publicar PDF → consultar autorizado, y las pruebas críticas pasan. | Guion de demostración + reporte de pruebas |

## 8. Casos de demostración

**Caso A — Registro online.** Autenticar a un usuario habilitado; crear orden con datos válidos; confirmar que aparece en PostgreSQL.

**Caso B — Registro offline.** Desconectar el navegador o detener la API; capturar una orden mínima; verificar su almacenamiento en IndexedDB y que persiste tras recarga; reactivar conectividad; sincronizar; confirmar un único registro.

**Caso C — Idempotencia.** Repetir la solicitud con el mismo identificador operativo; comprobar que el conteo no aumenta.

**Caso D — PDF autorizado.** Adjuntar archivo PDF válido; verificar metadatos en PostgreSQL y objeto privado en R2; abrirlo con credenciales autorizadas.

**Caso E — PDF no autorizado.** Solicitar el mismo documento con otra identidad sin permiso; demostrar acceso denegado y ausencia de enlace público.

## 9. Dependencias y pendientes que bloquean partes del desarrollo

- **X-01:** campos mínimos y sus validaciones; bloquea DTO, modelo y formulario definitivos.
- **X-02:** matriz de permisos y datos de vinculación médico/paciente; bloquea pruebas de autorización real.
- **X-03:** estados permitidos de orden y resultado; bloquea algunas transiciones de negocio.
- **X-04/X-05:** modalidad de entrega, tamaño y validación de PDF; bloquea contrato final de archivos.
- **X-06:** infraestructura y credenciales de ambiente; bloquea demostración desplegada, no pruebas locales con adaptadores o ambientes de desarrollo.
- **X-07/X-08:** responsables, fechas y comportamiento de sesión expirada en offline; bloquean cierre del plan y prueba de seguridad correspondiente.

**Criterio de entrada a implementación:** resolver al menos X-01 y X-02 para las funcionalidades que afecten; cerrar X-04/X-05 antes de integrar PDF. Las piezas sin dependencia pueden arrancar con interfaces y pruebas controladas, siempre marcadas como provisionales.

## 10. Definición de terminado (DoD)

El incremento se considera terminado solo cuando: (1) los CA-01 a CA-12 se ejecutan y cuentan con evidencia; (2) no hay defectos críticos abiertos de seguridad, pérdida de datos o duplicación; (3) el código y las configuraciones necesarias están documentados; (4) no hay secretos en el repositorio; (5) se demuestra el recorrido completo; y (6) las decisiones originalmente pendientes afectadas por el incremento constan como resueltas y aprobadas.

**Estado actual:** especificación preparada; implementación y aprobación aún no verificadas.
