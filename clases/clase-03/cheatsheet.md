# Clase 03 - Cheatsheet

## Objetivo del cheatsheet
- Servir de ayuda memoria con las herramientas necesarias para resolver la tarea (dependencias, anotaciones, properties y el script de datos), sin resolver `Customer` por los alumnos.

## Dependencias necesarias

Agregar en el `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-h2console</artifactId>
</dependency>
```

| Dependencia | Para que sirve |
|---|---|
| `spring-boot-starter-data-jpa` | Trae JPA/Hibernate y Spring Data (permite extender `JpaRepository`). |
| `com.h2database:h2` | Driver/motor de la base H2 usada en desarrollo. |
| `spring-boot-h2console` | Habilita la auto-configuracion de la consola web de H2 (necesaria en Spring Boot 4.x; no alcanza solo con el driver). |

## Anotaciones necesarias para convertir una clase en entidad persistida

| Anotacion | Donde se coloca | Para que sirve |
|---|---|---|
| `@Entity` | Sobre la clase | Le dice a Hibernate que esta clase representa una tabla gestionada. |
| `@Table(name = "...")` | Sobre la clase (opcional) | Define el nombre real de la tabla. Si se omite, Hibernate usa el nombre de la clase. |
| `@Id` | Sobre el campo que es clave primaria | Marca cual campo identifica de forma unica cada fila. |
| `@GeneratedValue(strategy = GenerationType.IDENTITY)` | Sobre el campo `@Id` | Delega en la base de datos la generacion automatica del valor (ver guia de clase para otras estrategias: `SEQUENCE`, `TABLE`, `AUTO`). |
| `@Column(nullable = false)` | Sobre un campo | Marca que ese campo no puede quedar nulo en la tabla. |
| `JpaRepository<Entidad, TipoId>` | Interfaz que se extiende (no es una anotacion, pero cumple el mismo rol de "pieza necesaria") | Da CRUD basico (`save`, `findAll`, `findById`, `delete`, etc.) sin necesidad de implementarlo. |

### Ejemplo visto en clase: entidad `Product`

```java
import java.math.BigDecimal;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer stock;

    // getters y setters
}
```

Este es el mismo patron que hay que aplicar a la entidad de la tarea: cambian los campos propios de esa entidad, pero las anotaciones y su ubicacion son las mismas.

## Configuracion de base de datos: para que sirve cada property

Estas son las properties ya usadas para `Product` con H2; el datasource es el mismo para toda la aplicacion, no hace falta duplicarlo para una entidad nueva:

```properties
spring.datasource.url=jdbc:h2:mem:ecommerce
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

| Property | Para que sirve |
|---|---|
| `spring.datasource.url` | Direccion de conexion a la base: motor, host/puerto (si aplica) y nombre de la base. Con H2 en memoria (`jdbc:h2:mem:...`) no hay host real, todo vive en el proceso de la aplicacion. |
| `spring.datasource.driverClassName` | Clase Java del driver JDBC que sabe "hablar" con ese motor de base especifico. Cada motor tiene el suyo. |
| `spring.datasource.username` / `spring.datasource.password` | Credenciales de conexion. En H2 de desarrollo, `sa` sin password es el default; en una base real, son credenciales reales y no deberian quedar hardcodeadas en el repositorio. |
| `spring.jpa.hibernate.ddl-auto` | Estrategia de Hibernate para el esquema. Ver el detalle de cada valor abajo. |
| `spring.h2.console.enabled` | Habilita la consola web de H2 (solo existe para H2, no aplica a otros motores). Requiere ademas la dependencia `spring-boot-h2console` en Spring Boot 4.x. |
| `spring.h2.console.path` | Ruta donde se accede a la consola web (por defecto `/h2-console`). |

#### `spring.jpa.hibernate.ddl-auto`: que hace cada valor

| Valor | Que hace |
|---|---|
| `none` | Hibernate no toca el esquema. Hay que crear las tablas por fuera (script manual, Flyway/Liquibase, etc.). |
| `validate` | Hibernate compara las entidades contra las tablas existentes y falla si no coinciden. No crea ni modifica nada. |
| `update` | Hibernate crea las tablas si no existen y agrega columnas/cambios que detecte. Es el valor comodo para desarrollo con H2, usado en clase. |
| `create` | Hibernate borra y vuelve a crear el esquema completo cada vez que arranca la aplicacion. Se pierden los datos en cada reinicio. |
| `create-drop` | Igual que `create`, pero ademas borra el esquema al cerrar la aplicacion. Util solo para tests. |

Importante: `update`/`create`/`create-drop` son comodos para aprender y para H2, pero no se recomiendan en una base de datos real/productiva (riesgo de perder o corromper datos). Ahi conviene `validate`/`none` combinado con una herramienta de migracion (Flyway/Liquibase).

### Las mismas properties, usando PostgreSQL en vez de H2

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/ecommerce
spring.datasource.driverClassName=org.postgresql.Driver
spring.datasource.username=postgres
spring.datasource.password=tu_password
spring.jpa.hibernate.ddl-auto=validate
```

Cambios clave respecto a H2:
- La URL ahora apunta a un servidor real (`host:puerto/nombre_base`), no a una base en memoria.
- El driver cambia a `org.postgresql.Driver` (requiere la dependencia `org.postgresql:postgresql` en vez de `com.h2database:h2`).
- Las credenciales son reales, no `sa`/vacio.
- `ddl-auto` pasa a `validate` (o `none`): en una base persistente no conviene que Hibernate modifique el esquema automaticamente en cada arranque.
- Las properties `spring.h2.console.*` se eliminan directamente: no tienen sentido fuera de H2.

### Las mismas properties, usando SQL Server en vez de H2

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=ecommerce;encrypt=true;trustServerCertificate=true
spring.datasource.driverClassName=com.microsoft.sqlserver.jdbc.SQLServerDriver
spring.datasource.username=sa
spring.datasource.password=tu_password
spring.jpa.hibernate.ddl-auto=validate
```

Cambios clave respecto a H2:
- La URL usa el formato propio de SQL Server (`jdbc:sqlserver://host:puerto;databaseName=...`), con parametros adicionales de conexion (`encrypt`, `trustServerCertificate`) segun como este configurado el servidor.
- El driver cambia a `com.microsoft.sqlserver.jdbc.SQLServerDriver` (requiere la dependencia `com.microsoft.sqlserver:mssql-jdbc`).
- Aunque el usuario tambien se llame `sa` en SQL Server (es una coincidencia de nombre con el usuario por defecto de H2), la contrasena es real y propia del servidor configurado.
- `ddl-auto` en `validate`/`none` por la misma razon que en PostgreSQL.
- Tampoco aplican las properties de consola H2.

### Nota: no hace falta declarar el dialecto a mano
En versiones actuales de Spring Boot no es necesario setear `spring.jpa.database-platform` (por ejemplo `org.hibernate.dialect.PostgreSQLDialect`): Hibernate detecta el dialecto automaticamente a partir del driver/URL configurados. Alcanza con cambiar `url`, `driverClassName` y las credenciales.

## Script de datos de ejemplo: donde y como debe llamarse

- **Ubicacion**: `src/main/resources/data.sql` (raiz del classpath).
- **Nombre obligatorio**: tiene que llamarse exactamente `data.sql` (o `data-${platform}.sql` para variantes por motor). Cualquier otro nombre no se ejecuta automaticamente, salvo que se declare con `spring.sql.init.data-locations`.
- **Formato esperado**: sentencias `INSERT INTO <tabla> (<columnas>) VALUES (...);` usando el nombre real de la tabla (el definido en `@Table`, no el nombre de la clase Java).
- **Property adicional si el esquema lo genera Hibernate**: agregar `spring.jpa.defer-datasource-initialization=true`, sino falla con un error del estilo `Table "X" not found` porque el script intenta correr antes de que Hibernate cree las tablas.

## Errores comunes y solucion rapida

| Error | Solucion rapida |
|---|---|
| `Table "X" not found` al arrancar con `data.sql` | Agregar `spring.jpa.defer-datasource-initialization=true`. |
| La consola H2 no carga en `/h2-console` | Verificar que este la dependencia `org.springframework.boot:spring-boot-h2console` (no alcanza solo con `com.h2database:h2`). |
| La entidad no se persiste | Revisar que tenga `@Entity`, `@Id` y `@GeneratedValue`, y que el service use el repository y no una lista en memoria. |
| Cambios de esquema inesperados en una base real | No usar `ddl-auto=update` fuera de desarrollo; pasar a `validate`/`none` + una herramienta de migracion (Flyway/Liquibase). |
| Error de conexion al migrar de H2 a PostgreSQL/SQL Server | Revisar que se haya cambiado `url`, `driverClassName` y credenciales, y que la dependencia del driver correspondiente este en el `pom.xml`. |

