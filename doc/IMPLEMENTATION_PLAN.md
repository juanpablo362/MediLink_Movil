# IMPLEMENTATION_PLAN.md — MediLink

**Incremento:** INC-01 — Órdenes, sincronización offline y PDF privados  
**Estado:** Plan propuesto, no cronograma aprobado  
**Documentos relacionados:** `PROJECT_CONTEXT.md` · `CURRENT_TASK.md`

## 1. Estrategia

Entregar una **rebanada vertical** que recorra Angular PWA → ASP.NET Core Web API → PostgreSQL / Cloudflare R2 e IndexedDB según corresponda. Favorecer primero las reglas de integridad y autorización, después la UX y por último la demostración integral. Se priorizan pruebas automatizadas de validación, idempotencia y autorización.

> Las duraciones y asignaciones individuales no se conocen; por ello se ofrece un orden de dependencias y responsables por rol, no fechas inventadas. El equipo debe completar nombres y calendario antes de adoptar este plan.

## 2. Hitos, tareas concretas y evidencias

| Fase | Tareas concretas | Responsable sugerido | Dependencias | Evidencia de salida |
|---|---|---|---|---|
| 0. Alineación | Aprobar campos mínimos de orden, permisos por recurso, estados, política PDF y contrato API; registrar decisiones | Equipo completo | Ninguna | Registro de acuerdos actualizado |
| 1. Base técnica | Organizar proyectos Angular/API; variables de entorno; conexión PostgreSQL; migraciones; DI; JWT y protección básica de rutas | Backend + frontend | Fase 0 para contratos finales | Compilación y conexión funcional |
| 2. Modelo/API de órdenes | Crear entidades y restricciones; endpoint de creación; validación server-side; índice único para `clientOperationId`; pruebas de repetición | Backend | Fase 1 y X-01 | CA-01, CA-02, CA-05 |
| 3. Captura web | Crear formulario y servicio HTTP; mostrar confirmación, validaciones y errores; integrar autenticación | Frontend | Fase 2 | CA-01, CA-02 |
| 4. Offline | Crear almacenamiento IndexedDB mínimo; guardar pendientes; mantener ID estable; estados de sincronización y control de reintentos | Frontend | Fases 2–3 | CA-03, CA-06, CA-11 |
| 5. Sincronización | Enviar cola al recuperar comunicación y de forma manual; procesar una misma operación sin duplicar; confirmar antes de marcar sincronizada | Frontend + backend | Fase 4 | CA-04, CA-05, CA-06 |
| 6. Gestión de PDF | Adaptador de R2 con bucket privado; API de publicación; validación de archivo; persistencia de metadatos; control de permisos | Backend + frontend | X-02, X-04, X-05 | CA-07, CA-11 |
| 7. Consulta segura | Endpoint/mecanismo de consulta verificado; pantalla de resultado y tratamiento de 401/403; pruebas por recurso | Backend + frontend | Fase 6 | CA-08, CA-09, CA-10 |
| 8. Calidad y cierre | Pruebas unitarias/integración/e2e, revisión de seguridad, demo, README y evidencias | Equipo completo | Fases 1–7 | CA-01 a CA-12 y DoD |

## 3. Detalle de implementación por componente

### 3.1 Backend ASP.NET Core Web API

1. Crear módulos claros para autenticación/autorización, órdenes y resultados. Mantener negocio separado de controladores y adaptadores externos.
2. Modelar usuarios, pacientes, médicos, órdenes y metadatos de resultado **solo en la medida aprobada para este incremento**.
3. Configurar PostgreSQL, migraciones, claves foráneas, transacciones e índice único de `clientOperationId`. Definir cómo responder a dos solicitudes simultáneas con el mismo identificador.
4. Implementar DTO y validaciones de creación de orden. Rechazar datos inválidos sin persistir parcialmente.
5. Implementar autenticación JWT y autorización por recurso; no aceptar permisos basados solamente en IDs que envíe el cliente.
6. Implementar carga de PDF con controles acordados (tipo, tamaño, contenido); utilizar un adaptador para Cloudflare R2 y mantener los objetos privados.
7. Guardar referencia y metadatos en PostgreSQL. Ante fallo entre R2 y DB, aplicar una estrategia acordada de compensación/limpieza para no dejar archivos huérfanos sin control.
8. Ofrecer consulta mediante API o acceso firmado de breve duración **solo después de resolver X-04** y verificar autorización.
9. Producir documentación del contrato (por ejemplo, OpenAPI) y pruebas de los casos críticos.

**Estructura sugerida, no obligatoria:** `Api/` (endpoints y middleware), `Application/` (casos de uso), `Domain/` (reglas y entidades), `Infrastructure/` (PostgreSQL y R2), `Tests/`.

### 3.2 Angular PWA

1. Crear rutas/pantallas para ingreso, registro de orden, lista/estado de pendientes, carga de PDF y consulta del resultado, según roles acordados.
2. Conectar servicios HTTP tipados a la API; proteger vistas sin depender de esa protección para autorización real.
3. Crear un `clientOperationId` **una sola vez por nueva orden** y conservarlo en todos los reintentos.
4. Implementar un repositorio local IndexedDB únicamente con los campos mínimos aprobados, ID y estado técnico; excluir PDF y expedientes completos.
5. Guardar en cola cuando no se pueda confirmar la operación. Evitar perder datos si la página se recarga.
6. Permitir sincronización manual y al recuperar conectividad, con exclusión mutua local para evitar dos bucles simultáneos. El evento `online` solo inicia una comprobación; no garantiza que la API responda.
7. Marcar la orden como sincronizada **solo cuando** la respuesta de la API confirme el mismo registro lógico. Mantener errores recuperables visibles; nunca eliminar órdenes no confirmadas.
8. Mostrar errores de permiso y expiración de sesión sin exponer datos sensibles.
9. Verificar que la PWA permita cargar la interfaz offline donde corresponda; no prometer acceso offline a documentos PDF.

**Estructura sugerida:** `features/ordenes/`, `features/resultados/`, `core/auth/`, `core/api/`, `core/offline/`.

### 3.3 Datos y almacenamiento

- En **PostgreSQL**, guardar órdenes y metadatos; usar restricciones de unicidad y relacionales para preservar consistencia.
- En **IndexedDB**, guardar de manera temporal la cola mínima y su estado; no PDF.
- En **Cloudflare R2**, guardar PDF en bucket privado; la referencia del objeto no debe convertirse por sí sola en una autorización de acceso.
- Definir políticas de borrado, retención y recuperación antes de usar información clínica real. Para la demostración, utilizar **datos ficticios**, nunca datos de pacientes reales.

## 4. Plan de pruebas

| Tipo | Prueba concreta | Criterios vinculados |
|---|---|---|
| Unitarias backend | Validaciones de campos obligatorios y reglas de órdenes | CA-02 |
| Integración API + DB | Crear orden, volver a enviar mismo ID, comprobar una fila incluso con solicitudes concurrentes | CA-01, CA-05 |
| Frontend | Captura válida/inválida, estado pendiente y mensajes de error | CA-01, CA-02, CA-03 |
| Persistencia local | Guardar pendiente, recargar página, recuperar cola | CA-03, CA-11 |
| Integración offline | Caída de API → orden pendiente → recuperación → confirmación única | CA-04, CA-06 |
| Integración R2 + DB | Publicar PDF y verificar archivo privado + metadatos | CA-07, CA-11 |
| Seguridad | Sin token, token sin permiso y token autorizado para diferentes recursos | CA-08, CA-09, CA-10 |
| Recorrido e2e | Ejecutar los casos A–E de `CURRENT_TASK.md` | CA-12 |

**Datos de prueba:** usuarios ficticios con permisos distintos, órdenes ficticias y PDF de prueba sin información de salud real.

## 5. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Reintento crea órdenes duplicadas | Integridad | `clientOperationId` estable + unicidad en DB + prueba concurrente |
| Pérdida de una orden pendiente | Operación | IndexedDB persistente, estado explícito, nunca eliminar sin confirmación |
| Sesión expirada al volver online | Seguridad/UX | Detener envío y solicitar autenticación antes del reintento |
| Archivo R2 accesible públicamente | Confidencialidad | Bucket privado + autorización por recurso y pruebas negativas |
| Se guarda PDF pero falla DB | Inconsistencia | Compensación/limpieza y registro controlado de fallo |
| Información clínica en equipo compartido | Privacidad | Minimización de datos offline; revisar política de sesiones y limpieza |
| Falta de permisos/campos acordados | Retrabajo | Resolver X-01/X-02 y aprobar contrato antes de cerrar tareas |
| Servicios de nube no configurados | Bloqueo de demo | Definir entornos, cuentas y secretos; usar adaptadores simulados solo para pruebas locales, nunca presentar simulación como integración real |

## 6. Orden de trabajo / checklist de seguimiento

- [ ] **T-01:** Revisar el Entregable 2 con el equipo y validar alcance INC-01.
- [ ] **T-02:** Resolver X-01 a X-05 y documentar decisiones y reglas.
- [ ] **T-03:** Definir responsables, fecha, repositorio y ambiente (X-06/X-07).
- [ ] **T-04:** Inicializar/build de Angular, API y conexión PostgreSQL.
- [ ] **T-05:** Implementar autenticación y autorización base.
- [ ] **T-06:** Implementar modelo, creación de órdenes e índice idempotente.
- [ ] **T-07:** Integrar formulario Angular con API.
- [ ] **T-08:** Implementar cola IndexedDB y visualización de pendientes.
- [ ] **T-09:** Implementar y probar sincronización y fallas de red.
- [ ] **T-10:** Integrar Cloudflare R2 privado y publicación de PDF.
- [ ] **T-11:** Implementar consulta de PDF con comprobación de permisos.
- [ ] **T-12:** Ejecutar CA-01 a CA-12 y corregir defectos.
- [ ] **T-13:** Preparar demostración con datos ficticios y recopilar evidencias.
- [ ] **T-14:** Revisar DoD, actualizar documentos y aprobar cierre del incremento.

## 7. Evidencias que deben adjuntarse a la entrega técnica

1. Repositorio y referencia a commit/versión revisada.
2. Capturas o video breve de los cinco casos de demostración (A–E).
3. Evidencia de PostgreSQL: orden única y metadatos PDF (ocultando secretos y datos personales).
4. Evidencia de IndexedDB: orden pendiente antes y sincronizada después.
5. Evidencia del bucket R2 privado y prueba de acceso autorizado/denegado.
6. Resultados de pruebas automatizadas o reporte manual trazado a CA-01…CA-12.
7. Registro de decisiones cerradas, pendientes restantes y alcance expresamente diferido.

## 8. Puerta de salida del incremento

El equipo marca INC-01 como **terminado** solo si:

- Los 12 criterios de aceptación están aprobados con evidencia.
- El recorrido integral funciona sin duplicar órdenes y sin perder pendientes bajo los escenarios probados.
- Los PDF solo se acceden tras comprobar permisos, sin enlaces públicos permanentes.
- No se almacenan PDF o expedientes completos offline ni secretos en el repositorio.
- Se documentaron los entornos, las instrucciones de ejecución y las decisiones cerradas.
- El equipo validó que no se incluyeron funcionalidades fuera de alcance por accidente.

**Resultado actual del documento:** plan listo para revisión; ninguna tarea o prueba se marca como ejecutada sin evidencia.
