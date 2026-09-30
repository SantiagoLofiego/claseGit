# Clase 03 - Actividad en clase

## Contexto
- Partimos del modulo `Product` construido en las clases anteriores con DTOs y validaciones.
- En la clase 01 el producto vivia en memoria; en la clase 02 se reforzo la calidad del contrato de entrada.
- Ahora toca el siguiente paso natural: persistir esos datos en base de datos usando JPA/Hibernate.
- La clase debe dejar claro que la capa REST se mantiene igual desde afuera, pero por dentro el almacenamiento ya no es una lista local, sino una entidad gestionada por Spring Data.
- La estrategia didactica es comenzar con H2 para bajar la friccion tecnica y poder mostrar resultados concretos sin requerir permisos de infraestructura.

## Objetivo de la actividad
- Entender el cambio conceptual de "dato temporal" a "entidad persistida".
- Ver como Spring Data y JPA reemplazan la logica manual de almacenamiento.
- Demostrar que un producto puede guardarse, consultarse y recuperarse desde una base de datos real usando H2.

## Consigna
1. Revisar la estructura actual del modulo `Product` y identificar que piezas deben pasar a persistencia.
2. Convertir la clase de dominio en entidad JPA con anotaciones basicas:
   - `@Entity`
   - `@Table(name = "products")`
   - `@Id`
   - `@GeneratedValue`
3. Crear el repository correspondiente para `Product` usando `JpaRepository`.
4. Ajustar el service para que la logica de alta y listado use el repository, no una lista en memoria.
5. Configurar H2 como datasource de desarrollo, agregando tanto el driver (`com.h2database:h2`) como la dependencia de la consola web (`org.springframework.boot:spring-boot-h2console`, requerida en Spring Boot 4.x para que la consola funcione).
6. Probar el flujo completo:
   - crear un producto por `POST /api/products`
   - leer la lista por `GET /api/products`
   - verificar que la informacion se obtiene desde la base de datos.
7. Observar la diferencia entre el modelo DTO y la entidad JPA para evitar mezclar capas.

## Preguntas orientadoras para la clase
- ¿Por que no se usa una lista en memoria cuando ya estamos en una API real?
- ¿Que responsabilidad tiene cada capa cuando agregamos JPA?
- ¿Cual es la diferencia entre un DTO de entrada y una entidad de persistencia?
- ¿Por que H2 es una buena opcion para empezar?
- ¿Que pasa si olvidamos la clave primaria o la anotacion `@Entity`?

## Criterios de aceptacion
- Se entiende la diferencia entre DTO y entidad de persistencia.
- El proyecto usa un `Repository` para consultar y guardar productos.
- La API sigue funcionando con endpoints basicos sobre datos reales.
- Se prueba al menos un caso feliz de alta y consulta.
- Se observa el flujo completo: request -> controller -> service -> repository -> base de datos.
- Se identifica el rol de H2 como base de desarrollo y la posibilidad de migrar luego a PostgreSQL o SQL Server.

## Pistas para la clase
- La entidad pertenece a la capa de dominio/persistencia, el DTO pertenece a la capa de API.
- `@Valid` sigue siendo relevante para validar entrada, pero no reemplaza la persistencia.
- No conviene mezclar la logica de negocio del DTO con la estructura de la base de datos.
- Cuando trabajamos con JPA, la entidad se vuelve una representacion del registro en la BD.
- Si la clase se ve muy larga, conviene mantener el enfoque en el patron minimo y no entrar en relaciones complejas aun.
- El objetivo no es hacer un modelo perfecto; el objetivo es que el alumno comprenda el paso de memoria a base de datos con una demo clara.
- En Spring Boot 4.x, si la consola H2 no carga en `/h2-console`, lo primero a revisar es si esta agregada la dependencia `org.springframework.boot:spring-boot-h2console` (no alcanza solo con el driver `com.h2database:h2`).
