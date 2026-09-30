# Clase 03 - Resumen

## Objetivo de la clase
- Entender el paso de "dato temporal" a "entidad persistida".
- Introducir JPA/Hibernate de forma practica: entidad, repository y service conectados a una base real.
- Mostrar el patron minimo de persistencia con `Product`, usando H2 como base de desarrollo.
- Dejar claro que la clase enseña el patron sobre `Product`, mientras que la tarea exige aplicarlo a una entidad nueva (`Customer`).

## Conceptos vistos
- Diferencia entre DTO (contrato de entrada/salida) y entidad JPA (representacion de la tabla).
- Anotaciones basicas de persistencia: `@Entity`, `@Table`, `@Id`, `@GeneratedValue`, `@Column`.
- Estrategias de `@GeneratedValue` (`IDENTITY`, `SEQUENCE`, `TABLE`, `AUTO`) y por que se eligio `IDENTITY` para esta clase.
- `JpaRepository` y el CRUD basico que provee sin necesidad de implementarlo.
- Configuracion de H2 como datasource de desarrollo, incluyendo la dependencia adicional `spring-boot-h2console` requerida en Spring Boot 4.x.
- Significado de cada valor de `spring.jpa.hibernate.ddl-auto` (`none`, `validate`, `update`, `create`, `create-drop`) y por que `update` es comodo en H2 pero riesgoso en produccion.
- Carga de datos de ejemplo con `data.sql` y la necesidad de `spring.jpa.defer-datasource-initialization=true` cuando el esquema lo genera Hibernate.
- Por que `price` usa `BigDecimal` y no `Double`: precision exacta frente a errores de redondeo de punto flotante, mas relevante aun con una moneda local devaluada.

## Demo realizada
- Se convirtio `Product` en entidad JPA (`@Entity`, `@Table(name = "products")`, `@Id`, `@GeneratedValue`).
- Se creo `ProductRepository extends JpaRepository<Product, Long>`.
- Se ajusto `ProductService` para usar el repository en lugar de la lista en memoria.
- Se probo el flujo completo: `POST /api/products` para crear, `GET /api/products` para listar, verificando los datos desde H2.
- Se mostro la consola web de H2 (`/h2-console`) con la tabla `products` y sus filas.
- Se cargaron productos de ejemplo con `data.sql` para tener datos disponibles desde el arranque.

## Mini entregable alcanzado
- `Product` persistido en base de datos real (H2), con alta y listado funcionando sobre el repository.
- Evidencia de que la API mantiene el mismo contrato REST hacia afuera, aunque el almacenamiento interno cambio de memoria a base de datos.
- Base para que cada alumno aplique el mismo patron sobre `Customer` en la tarea.

## Dudas frecuentes y aclaraciones
- Por que no alcanza con agregar `com.h2database:h2`: en Spring Boot 4.x, la consola web requiere ademas la dependencia `spring-boot-h2console`.
- Por que `update` no es una buena idea en produccion: puede generar cambios de esquema inesperados; en una base real conviene `validate`/`none` + una herramienta de migracion (Flyway/Liquibase).
- Por que `data.sql` a veces falla con `Table "X" not found`: el script se ejecuta antes de que Hibernate cree las tablas, salvo que se agregue `spring.jpa.defer-datasource-initialization=true`.
- Por que `BigDecimal` en vez de `Double` para `price`: evita errores de precision de punto flotante, mas notorios con montos altos por la devaluacion de la moneda local.
- Por que no se resuelve `Customer` en clase: la mejor practica es dejar un ejercicio que aplique el mismo patron a una entidad nueva y distinta.

## Guion sugerido para la clase
- "Hasta ahora `Product` vivia en una lista en memoria. Eso sirve para aprender REST, pero no para un sistema real: los datos desaparecen al reiniciar la aplicacion."
- "Hoy vamos a convertir `Product` en una entidad JPA para que Hibernate la persista en una base de datos real, empezando por H2."
- "La entidad no reemplaza al DTO: el DTO sigue siendo el contrato de entrada/salida de la API, la entidad es la representacion de la tabla."
- "Vamos a ver `@Entity`, `@Table`, `@Id` y `@GeneratedValue`, y como `JpaRepository` nos da CRUD basico sin escribir SQL a mano."
- "La clave no es memorizar esta entidad puntual, sino entender el patron: entidad + repository + service conectados, para aplicarlo despues a `Customer` en la tarea."

