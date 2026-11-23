# PROJECT_CONTEXT.md — MediLink

**Proyecto:** MediLink  
**Asignatura:** Desarrollo Móvil Integral  
**Entregable:** 3 — Paquete de contexto y especificación del incremento  
**Fecha:** 22 de noviembre de 2026  
**Versión:** 1.0 (propuesta para revisión del equipo)  
**Documento base:** *Entregable 2: Especificación de arquitectura y decisiones técnicas* (noviembre de 2026).

## 1. Propósito

Concentrar el contexto técnico y funcional que debe conocer cualquier integrante del equipo antes de realizar cambios en MediLink. Este documento se complementa con `CURRENT_TASK.md` (qué se implementará en el incremento) y `IMPLEMENTATION_PLAN.md` (cómo se desarrollará y verificará).

> **Convención de decisiones:** `DOCUMENTADA` = aparece en el Entregable 2, sin suponer una aprobación formal adicional; `PROPUESTA` = concreción sugerida para el incremento 1, pendiente de validación por el equipo; `PENDIENTE` = decisión sin resolver. Ninguna propuesta se considera aprobada automáticamente.

## 2. Contexto y problema

MediLink es un sistema para gestionar órdenes y resultados de estudios de laboratorio y facilitar la consulta de información autorizada por el personal del laboratorio, médicos y pacientes. El sistema debe ayudar a mantener la operación de registro de órdenes cuando falle la conectividad, sin perder integridad de datos, y proteger los documentos de resultados clínicos.

**Objetivo del producto:** centralizar la gestión de órdenes y resultados, mantener la continuidad de la captura de órdenes ante interrupciones de red y ofrecer consulta segura de resultados PDF.

**Usuarios identificados en la arquitectura:**

- **Personal del laboratorio:** administra pacientes, órdenes y resultados PDF.
- **Médico:** consulta estudios o resultados para los que tiene autorización.
- **Paciente:** consulta y descarga sus resultados autorizados.

La experiencia móvil independiente en Flutter y las notificaciones push están contempladas para una etapa posterior, no para el primer incremento.

## 3. Arquitectura y componentes

**Estilo:** cliente-servidor; backend como **monolito modular por capas**, desplegado inicialmente como una sola Web API. Se separan presentación, lógica de negocio y persistencia.

| Componente | Tecnología | Responsabilidad |
|---|---|---|
| Aplicación web/PWA | Angular | Interfaz de operación y consulta, captura de órdenes y capacidad offline acotada |
| API central | ASP.NET Core Web API | Reglas de negocio, validaciones, autenticación, autorización y acceso a datos |
| Datos relacionales | PostgreSQL | Usuarios, pacientes, médicos, órdenes y metadatos de resultados |
| Archivos privados | Cloudflare R2 | Almacenamiento de resultados PDF fuera de la base relacional |
| Cola local | IndexedDB | Persistencia temporal de órdenes pendientes de sincronización |
| Cliente móvil futuro | Flutter | Consulta móvil de resultados; fuera del primer incremento |
| Notificaciones futuras | Firebase Cloud Messaging | Avisos push; fuera del primer incremento |

**Flujo lógico:** Angular PWA → HTTPS/REST → ASP.NET Core Web API → PostgreSQL / Cloudflare R2. Cuando no existe conexión, Angular guarda **únicamente los datos mínimos de órdenes pendientes** en IndexedDB y los envía al recuperar conectividad. No se guardan PDF ni expedientes completos offline.

## 4. Principios y patrones técnicos

- **Inyección de dependencias e inversión de dependencias:** aislar lógica de negocio de infraestructura y facilitar pruebas.
- **Repository cuando aporte valor:** encapsular la persistencia sin crear capas redundantes.
- **Adapter:** desacoplar integraciones con Cloudflare R2 y, en fases futuras, Firebase Cloud Messaging.
- **Store and Forward:** persistir órdenes pendientes en IndexedDB para posterior envío.
- **Retry:** reintentar fallos transitorios sin duplicar operaciones; no repetir automáticamente errores de autorización o validación.

**Atributos de calidad objetivo:** mantenibilidad, seguridad, disponibilidad operativa, integridad, escalabilidad, usabilidad, portabilidad y testabilidad.

## 5. Reglas y restricciones del sistema

1. Todo acceso desde los clientes a la API debe realizarse por **HTTPS** en ambientes desplegados.
2. El diseño considera autenticación basada en **JWT** y autorización por recurso; el backend verifica los permisos sobre cada orden y resultado, nunca solo la interfaz.
3. Los PDF de resultados deben permanecer privados en Cloudflare R2 y no pueden exponerse mediante enlaces públicos permanentes.
4. PostgreSQL almacena información estructurada y **referencias/metadatos** de PDF, no los archivos binarios.
5. Cada intento de registrar una orden debe llevar un **identificador estable** para que los reintentos no generen registros duplicados (idempotencia).
6. Una orden pendiente debe conservarse localmente si la red o la API falla; solo puede marcarse sincronizada cuando la API confirme la persistencia.
7. No deben almacenarse PDF ni expedientes clínicos completos en IndexedDB. La disponibilidad offline se limita a la captura mínima de órdenes.
8. Se deben validar datos en servidor aun cuando la interfaz ya los haya validado.
9. Se deben usar transacciones y restricciones relacionales cuando se modifiquen registros relacionados.
10. Credenciales, claves JWT y secretos de R2 deben administrarse mediante configuración segura; nunca versionarse en el repositorio.
11. No registrar datos clínicos o tokens en logs sin una justificación explícita y controles apropiados.

## 6. Estado de decisiones

### 6.1 Decisiones documentadas en el Entregable 2

| Código | Decisión | Estado |
|---|---|---|
| D-01 | Arquitectura cliente-servidor y backend monolítico modular por capas | DOCUMENTADA |
| D-02 | Angular para aplicación web/PWA | DOCUMENTADA |
| D-03 | ASP.NET Core Web API para el backend REST | DOCUMENTADA |
| D-04 | PostgreSQL para datos relacionales | DOCUMENTADA |
| D-05 | Cloudflare R2 para PDF privados | DOCUMENTADA |
| D-06 | IndexedDB + Store and Forward + Retry para órdenes offline | DOCUMENTADA |
| D-07 | HTTPS, JWT y autorización por recurso como estrategia de seguridad | DOCUMENTADA |
| D-08 | Priorizar web, órdenes, PDF y offline en el primer incremento | DOCUMENTADA |
| D-09 | Flutter y notificaciones FCM no son prioridad del primer incremento | DOCUMENTADA |

### 6.2 Propuestas operativas específicas del incremento 1

| Código | Propuesta | Estado |
|---|---|---|
| P-01 | Entregar un recorrido vertical: crear orden → sincronizar si es necesario → adjuntar PDF → consultar PDF autorizado | PROPUESTA |
| P-02 | Usar UUID generado por cliente como `clientOperationId` único por creación de orden | PROPUESTA |
| P-03 | Estados de cola local `pendiente`, `sincronizando`, `sincronizada`, `error` | PROPUESTA |
| P-04 | Exponer endpoints REST de referencia descritos en `CURRENT_TASK.md` | PROPUESTA |
| P-05 | Procesar primero la cola manualmente y al volver a estar online, evitando sincronizaciones simultáneas | PROPUESTA |
| P-06 | Generar acceso a PDF a través de la API luego de verificar permisos | PROPUESTA, consistente con el diagrama UML |

### 6.3 Decisiones pendientes de resolver antes de codificar ciertos componentes

| Código | Pregunta pendiente | Impacto |
|---|---|---|
| X-01 | ¿Qué campos exactos forman los datos mínimos de una orden y cuáles son obligatorios? | Modelo, formulario y validaciones |
| X-02 | ¿Qué roles concretos y relación usuario-paciente/médico habilitan consulta? | Autorización por recurso |
| X-03 | ¿Cuál es el ciclo de vida y estados de una orden/resultado? | Reglas de negocio |
| X-04 | ¿Se usará descarga mediante API o URL firmada de corta duración? | Seguridad e integración R2 |
| X-05 | ¿Cuál será el límite de tamaño, validación y retención de PDF? | Seguridad, costos y pruebas |
| X-06 | ¿Qué alojamiento y ambientes se utilizarán? | Despliegue y configuración |
| X-07 | ¿Cuál es el plazo, definición de demostración y responsable de cada tarea? | Planificación y seguimiento |
| X-08 | ¿Cómo se manejará la expiración de sesión durante captura offline? | UX y seguridad |

**Regla de gobernanza:** cerrar cada decisión pendiente con fecha, responsable, justificación y actualización de los tres archivos antes de depender de ella en código.

## 7. Límites explícitos del incremento 1

**Incluido (propuesta):** base del proyecto web/API, modelo mínimo necesario, captura de órdenes, cola offline en IndexedDB, sincronización idempotente, carga de PDF privado, persistencia de metadatos, consulta autorizada y pruebas del recorrido.

**Excluido:** aplicación Flutter operativa, notificaciones FCM, almacenamiento offline de PDF, manejo offline de expedientes completos, analítica avanzada, integración con equipos de laboratorio, facturación, e interoperabilidad externa no especificada.

## 8. Referencias de trazabilidad

- Entregable 2, pp. 2–4: arquitectura, patrones y tecnologías.
- Entregable 2, pp. 5–6: diagramas de contexto y contenedores C4.
- Entregable 2, p. 7: secuencia de captura offline y sincronización; identificador único y no almacenamiento de PDF offline.
- Entregable 2, p. 8: publicación y consulta de PDF; acceso verificado por API, alternativa de URL firmada aún sin decidir.
- Entregable 2, pp. 9–10: vistas 4+1 y priorización Lean Startup del primer incremento.

## 9. Uso de los documentos

Antes de desarrollar, leer `PROJECT_CONTEXT.md`, revisar las decisiones pendientes de `CURRENT_TASK.md` y seguir las tareas y verificaciones de `IMPLEMENTATION_PLAN.md`. Ante un conflicto, las reglas de seguridad e integridad aquí establecidas prevalecen sobre decisiones de interfaz; cualquier modificación de alcance debe registrarse y aprobarse por el equipo.
