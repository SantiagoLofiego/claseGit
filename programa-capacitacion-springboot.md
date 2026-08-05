# Programa de Capacitacion - Java Spring Boot (Proyecto Evolutivo)

## Objetivo general
Construir una API REST de e-commerce de forma incremental, clase a clase, simulando un flujo real de trabajo en una consultora: analisis de requerimientos, diseno de contratos, implementacion, pruebas y evolucion.

## Parametros confirmados para esta edicion
- Duracion por clase: entre 1:30 y 2:00 horas.
- Version de lenguaje: Java 21.
- Base de datos objetivo por etapas:
  - Inicio con H2 (menor friccion por permisos en equipos de clientes).
  - Migracion posterior a PostgreSQL o SQL Server si el entorno lo permite.
- Flujo de trabajo obligatorio: uso de Git desde etapas tempranas.
- Modalidad de aprendizaje: mini entregables incrementales por clase (sin modelado completo desde el dia 1).

## Perfil de participantes
- Personas con base Java y sintaxis ya cubierta.
- Parte del grupo con experiencia en tecnologias legacy (por ejemplo, mainframe/COBOL).
- Parte del grupo con perfil junior y cercania a frontend.

## Metodologia sugerida por clase
- 20% marco conceptual.
- 50% live coding guiado.
- 20% ejercicio practico por parejas.
- 10% cierre, recap y Q&A.

Distribucion sugerida para clases de 90-120 minutos:
- 15-20 min: contexto y conceptos.
- 45-60 min: implementacion guiada.
- 20-30 min: actividad practico-aplicada.
- 10 min: recap, dudas y mini entregable.

## Proyecto base
Dominio: backend de e-commerce.

Capas objetivo desde el inicio:
- controller
- service
- dto
- model

Evolucion posterior:
- repository (cuando se introduzca JPA)
- validaciones
- manejo de errores global
- seguridad
- testing

---

## Plan clase a clase

## Clase 1 - Primer API REST funcional (sin BD)
Objetivo:
- Entender arquitectura minima de Spring Boot y flujo request-response.

Temas:
- Que es Spring Boot y por que se usa en backend empresarial.
- Estructura inicial del proyecto.
- Controllers, Services, DTOs.
- Endpoints GET/POST basicos.
- Datos en memoria para simular persistencia.

Entrega esperada:
- Modulo Product con endpoints:
  - GET /api/products
  - GET /api/products/{id}
  - POST /api/products
- DTO de entrada y salida.
- Service con logica simple.

Mini entregable:
- API de productos funcionando en memoria, con prueba de endpoints en Postman/Insomnia.

Ejercicio:
- Agregar endpoint para actualizar stock.

## Clase 2 - Diseno de contratos y validaciones
Objetivo:
- Mejorar calidad del contrato API y evitar datos invalidos.

Temas:
- Buen diseno de DTOs.
- Bean Validation (jakarta validation).
- Respuestas HTTP adecuadas (200, 201, 400, 404).
- Introduccion a versionado simple de API (conceptual).

Entrega esperada:
- Validaciones en request DTOs.
- Mensajes de error basicos (sin ControllerAdvice aun).

Mini entregable:
- Contrato de API endurecido con validaciones y respuestas HTTP semanticas.

Ejercicio:
- Crear modulo Customer con endpoints minimos y validaciones.

## Clase 3 - Persistencia con JPA/Hibernate
Objetivo:
- Persistir datos en base relacional y entender ORM basico.

Temas:
- Entidad, Repository, Service.
- Configuracion de datasource (H2 primero; plan de migracion a PostgreSQL/SQL Server).
- Ciclo de vida de entidades.
- Introduccion a migraciones (opcional: Flyway/Liquibase, al menos concepto).

Entrega esperada:
- Product persistido en BD.
- Repositorio JpaRepository.

Mini entregable:
- Primer endpoint persistiendo y consultando datos reales en H2.

Ejercicio:
- Pasar modulo Customer de memoria a BD.

## Clase 4 - Relaciones entre entidades
Objetivo:
- Modelar negocio real con relaciones.

Temas:
- OneToMany, ManyToOne, ManyToMany (segun alcance).
- Problemas comunes de serializacion y como evitarlos.
- Separacion entidad vs DTO para evitar acoplamiento.

Entrega esperada:
- Modulo Cart y CartItem relacionados con Product.

Mini entregable:
- Flujo minimo de carrito con relaciones basicas persistidas.

Ejercicio:
- Endpoint para agregar producto al carrito.

## Clase 5 - Manejo global de errores
Objetivo:
- Estandarizar respuestas de error de la API.

Temas:
- Excepciones custom de negocio.
- @ControllerAdvice y @ExceptionHandler.
- Estructura comun de error response.

Entrega esperada:
- Manejo global para errores de validacion, no encontrado y conflicto.

Mini entregable:
- Formato uniforme de errores para toda la API.

Ejercicio:
- Agregar reglas de negocio con excepciones claras (stock insuficiente, por ejemplo).

## Clase 6 - Consultas, filtros y paginacion
Objetivo:
- Exponer endpoints escalables para listados.

Temas:
- Paginacion y sorting con Spring Data.
- Filtros simples por query params.
- Criterios de busqueda y performance basica.

Entrega esperada:
- GET /api/products con paginacion, orden y filtro por nombre/categoria.

Mini entregable:
- Endpoint de listado escalable listo para crecer en volumen.

Ejercicio:
- Endpoint de listado de ordenes por estado y fecha.

## Clase 7 - Testing profesional
Objetivo:
- Asegurar calidad con pruebas automatizadas.

Temas:
- Unit tests de service (Mockito).
- Integration tests de controller (MockMvc/TestRestTemplate).
- Estructura Given-When-Then.

Entrega esperada:
- Set de tests para modulo Product y Cart.

Mini entregable:
- Suite base de tests automatizados ejecutable por el equipo.

Ejercicio:
- Cubrir caso de stock insuficiente con test.

## Clase 8 - Seguridad base
Objetivo:
- Introducir autenticacion/autorizacion en API.

Temas:
- Conceptos de Spring Security.
- Roles basicos (ADMIN/CUSTOMER).
- JWT (introduccion practica, alcance controlado).

Entrega esperada:
- Endpoints protegidos por rol.

Mini entregable:
- Politica minima de acceso por roles aplicada sobre endpoints criticos.

Ejercicio:
- Restringir creacion/actualizacion de productos a rol ADMIN.

## Clase 9 - Observabilidad y configuracion por ambientes
Objetivo:
- Acercarse a estandares operativos de produccion.

Temas:
- Profiles (dev/test/prod).
- Logging estructurado basico.
- Actuator: health/info y metricas introductorias.

Entrega esperada:
- Configuracion separada por ambiente.
- Endpoints de salud habilitados.

Mini entregable:
- Proyecto preparado para diagnostico operativo basico.

Ejercicio:
- Definir checklist de readiness para deploy.

## Clase 10 - Documentacion y consumo de API
Objetivo:
- Facilitar adopcion por otros equipos.

Temas:
- OpenAPI/Swagger.
- Convenciones de documentacion.
- Ejemplos de request/response y errores.

Entrega esperada:
- Documentacion navegable y actualizada.

Mini entregable:
- Contrato API documentado y facil de consumir por frontend.

Ejercicio:
- Documentar endpoints de checkout y pagos simulados.

## Clase 11 - End-to-end de caso de negocio
Objetivo:
- Integrar todo en un flujo completo.

Temas:
- Flujo: alta cliente -> carrito -> checkout -> orden.
- Reglas de negocio encadenadas.
- Revisión de arquitectura y deuda tecnica.

Entrega esperada:
- Demo funcional completa del recorrido de compra.

Mini entregable:
- Flujo de negocio integrado de punta a punta.

Ejercicio:
- Agregar estado de orden y auditoria simple.

## Clase 12 - Cierre orientado a consultoria
Objetivo:
- Consolidar buenas practicas de trabajo real.

Temas:
- Estrategias de branching y pull requests.
- Criterios de Definition of Done.
- Plan de evolucion tecnica del proyecto.

Entrega esperada:
- Roadmap post-curso y backlog priorizado.

Mini entregable:
- Plan de continuidad tecnica y funcional para el proyecto.

Ejercicio:
- Proponer 3 historias nuevas con estimacion inicial.

---

## Hitos pedagogicos por etapa
- Etapa 1 (Clases 1-2): API basica, contratos y validacion.
- Etapa 2 (Clases 3-6): Persistencia, relaciones, errores, consultas.
- Etapa 3 (Clases 7-10): Calidad, seguridad, observabilidad, documentacion.
- Etapa 4 (Clases 11-12): Integracion completa y forma de trabajo profesional.

## Criterios de exito
- Los estudiantes pueden leer y extender una API Spring Boot por capas.
- Pueden agregar endpoints nuevos respetando contrato y validaciones.
- Comprenden como pasar de un prototipo en memoria a una API productiva.
- Pueden colaborar bajo una dinamica de equipo (PR, tests, criterios comunes).

## Git y colaboracion (transversal)
- Definir desde clase 1 una estrategia simple de ramas (main + feature/*).
- Cada mini entregable debe cerrar con commit claro y pull request.
- Incluir checklist de revision minima: compila, corre, endpoints probados, naming consistente.
- Introducir Conventional Commits de forma progresiva (sin rigidez excesiva al inicio).

## Estructura sugerida del repositorio para cada clase
Cada clase debe tener su carpeta con material reutilizable:
- resumen.md: que se vio y por que.
- actividad.md: consigna de trabajo en clase.
- tarea.md: desafio post-clase.
- cheatsheet.md: referencia rapida para la actividad.

## Riesgos frecuentes y mitigaciones
- Riesgo: demasiado foco en anotaciones sin entender flujo.
  - Mitigacion: diagrama request-response en cada clase.
- Riesgo: mezclar entidad y DTO demasiado pronto.
  - Mitigacion: mantener separacion desde clase 1.
- Riesgo: saltar a seguridad compleja sin dominar base REST.
  - Mitigacion: introducir seguridad recien cuando CRUD y errores esten firmes.

## Dinamica sugerida para publico mixto
- Pairing cruzado (legacy + junior/front).
- Mini ejercicios con criterios de aceptacion concretos.
- Espacio de preguntas al cierre para conectar conceptos con proyectos reales.

---

## Backlog de temas opcionales (segun interes)
- MapStruct para mapeo DTO-entidad.
- Caching (intro).
- Resilience (retries/timeouts) si hay integraciones.
- Dockerizacion y pipeline CI/CD.
- Introduccion a arquitectura hexagonal.

## Registro de cambios del programa
- 2026-08-05: Version inicial del programa creada.
- 2026-08-05: Ajuste con decisiones reales del curso (duracion, Java 21, H2, Git y mini entregables).
