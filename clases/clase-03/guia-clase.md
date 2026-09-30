# Clase 03 - Guia base para explicar la clase

## Objetivo de la clase
- Comprender la transicion de un sistema que guarda datos en memoria a uno que persiste datos en base de datos.
- Introducir el concepto de JPA/Hibernate de forma practica y aplicada.
- Mostrar el patron minimo de persistencia en Spring Boot: entidad, repository, service y controller.
- Dejar una base clara para que luego la clase 04 pueda ampliar con relaciones entre entidades.

## Agenda sugerida
1. Recordatorio breve de la clase 02
2. Introduccion a persistencia y JPA
3. Entidad `Product` con `@Entity`
4. `ProductRepository` con `JpaRepository`
5. Ajuste del service para acceder a la BD
6. Configuracion de H2
7. Demo de alta y listado
8. Cierre y dudas

## 1) Recordatorio de la clase anterior
Antes de entrar al tema de persistencia, conviene reforzar lo que ya se aprendio:

- Los DTOs definen el contrato de entrada.
- Las validaciones se hacen en el DTO con `@Valid`.
- El controller recibe la request y delega.
- El service encapsula la logica de negocio.
- La API no debe depender de una estructura en memoria para funcionar.

Frase guia para la clase:

> "Si la clase 02 cuidaba la calidad de la entrada, la clase 03 cuida la persistencia de la informacion."

## 2) ¿Por que necesitamos persistencia?
Cuando una API corre en memoria, los datos desaparecen al reiniciar la aplicacion. Eso sirve para aprender REST, pero no para un sistema real.

En un proyecto de e-commerce real, necesitamos:

- guardar productos
- consultar stock
- recuperar datos tras reinicios
- mantener integridad de informacion
- preparar la base para relaciones futuras

## 3) Introduccion a JPA/Hibernate
JPA es la especificacion de persistencia de Java, y Hibernate es la implementacion mas usada.

En la practica, para nosotros importa entender que:

- JPA nos permite mapear clases Java a tablas de base de datos.
- Hibernate se encarga de hacer ese mapeo y gestion de entidades.
- Spring Data JPA nos da repositorios listos para CRUD y consultas simples.

### Concepto clave
La entidad representa una fila de la base de datos.

No es lo mismo:

- DTO: estructura de entrada/salida de la API
- Entidad: modelo persistido en la base de datos

## 4) Entidad `Product`
La entidad es la clase que representa el producto que se va a guardar en la base.

Ejemplo base:

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

### Explicacion de cada anotacion

#### `@Entity`
Indica que la clase es una entidad JPA. Hibernate la va a gestionar como una tabla.

#### `@Table(name = "products")`
Permite especificar el nombre real de la tabla en la base de datos. Si no se declara, Hibernate usa el nombre de la clase por defecto.

#### `@Id`
Define la clave primaria de la entidad.

#### `@GeneratedValue(strategy = GenerationType.IDENTITY)`
Indica que la base de datos va a generar el valor del id automaticamente.

##### Tipos de `GenerationType` disponibles
Vale la pena mencionarlos brevemente, aunque en esta clase solo usemos `IDENTITY`:

- `GenerationType.IDENTITY`: delega en una columna auto-incremental de la base de datos (por ejemplo `AUTO_INCREMENT` o `IDENTITY` nativo). Es la opcion mas simple y la que mejor soporta H2. Desventaja: no permite obtener el id antes del `INSERT`, lo que puede limitar ciertas optimizaciones de batch.
- `GenerationType.SEQUENCE`: usa una secuencia de base de datos (`CREATE SEQUENCE`). Es la opcion recomendada para bases como PostgreSQL, porque permite mejor rendimiento en inserciones batch. Requiere que la base soporte secuencias (H2 y PostgreSQL si, MySQL tradicionalmente no).
- `GenerationType.TABLE`: simula una secuencia usando una tabla auxiliar para llevar el contador. Funciona en cualquier base de datos, pero es la opcion mas lenta porque requiere una transaccion extra para leer y actualizar el contador.
- `GenerationType.AUTO`: deja que Hibernate elija automaticamente la estrategia segun el dialecto de la base de datos configurada. Es comoda para prototipos, pero menos predecible: conviene ser explicito en proyectos reales.

### Mensaje clave para explicar en clase (GeneratedValue)
> "Usamos `IDENTITY` porque es la forma mas directa de generar ids en H2 y es facil de entender. Cuando migremos a PostgreSQL mas adelante, vale la pena evaluar `SEQUENCE` por una cuestion de performance, pero eso no cambia el patron general que estamos aprendiendo hoy."

#### `@Column(nullable = false)`
Marca que el campo no puede ser nulo en la tabla.

### ¿Por que `BigDecimal` y no `Double` para `price`?
En esta clase usamos `BigDecimal` para `price`, coherente con lo ya definido desde la clase 01. Esto es especialmente importante en nuestro contexto, con una moneda local con muchos digitos y alta variacion de valores: `Double` (y `float`) usan representacion binaria de punto flotante, que no puede representar con exactitud la mayoria de los valores decimales y puede acumular errores de redondeo en operaciones aritmeticas (sumas de carrito, totales de orden, impuestos, etc.). `BigDecimal` evita ese problema porque representa los valores decimales de forma exacta.

Esto no es solo una cuestion teorica: con montos grandes (por una moneda devaluada) los errores de precision de `Double` se notan mas rapido y pueden generar diferencias de centavos que despues son dificiles de rastrear en un sistema de facturacion real.

### Nota opcional (avanzado): `precision` y `scale` en columnas `BigDecimal`
Si se quiere un control mas fino de la columna numerica en la base de datos, `@Column` acepta `precision` (cantidad total de digitos) y `scale` (cantidad de esos digitos que van despues de la coma). Por ejemplo, `precision = 10, scale = 2` permite hasta 10 digitos en total, 2 decimales.

Esto es opcional: si no se especifica, Hibernate igual mapea `price` a una columna numerica, aunque el precision/scale por defecto puede variar segun el dialecto de base de datos (H2, PostgreSQL, SQL Server, etc.). Para los valores que se usan en esta clase no hace falta declararlo explicitamente; alcanza con saber que existe esta opcion para cuando se necesite mayor control (por ejemplo, en una capa de facturacion real).

### Mensaje clave para explicar en clase
> "La entidad no es un DTO. Esta clase representa la estructura que se guarda en la base de datos, no el contrato HTTP."

## 5) Repository y acceso a datos
La capa repository es la responsable de interactuar con la base de datos.

Ejemplo:

```java
public interface ProductRepository extends JpaRepository<Product, Long> {
}
```

Con esto ya tenemos operaciones como:

- save()
- findById()
- findAll()
- delete()
- deleteById()

### ¿Por que esto importa?
Porque evita que el service tenga que manejar SQL manualmente o listas locales. El repository centraliza la persistencia.

## 6) Ajuste del service
El service cambia de:

- manejar una lista en memoria

A:

- delegar el almacenamiento y la consulta a `ProductRepository`

Ejemplo base:

```java
@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }
}
```

### Observacion didactica
El controller no cambia mucho desde la perspectiva del cliente, pero la implementacion interna deja de depender de datos temporales.

## 7) Configuracion de H2
Para empezar, conviene usar H2 en memoria o modo local para no depender de una base externa ni de permisos especiales.

En Spring Boot 4.x, la auto-configuracion de la consola web de H2 se movio a un artefacto separado del modulo principal de auto-configuracion. Esto significa que no alcanza con el driver de base de datos: tambien hace falta declarar explicitamente la dependencia de la consola.

Dependencias necesarias (en el `pom.xml`):

```xml
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

Y en `application.properties`:

```properties
spring.datasource.url=jdbc:h2:mem:ecommerce
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

### ¿Por que H2?
- facilita la demo en clase
- no requiere una instalacion compleja
- permite ver la base real funcionando
- sirve como base para luego migrar a PostgreSQL o SQL Server

### Aclaracion importante: `spring.jpa.hibernate.ddl-auto`
Esta propiedad le dice a Hibernate que estrategia usar para el esquema de la base de datos (crear tablas, actualizarlas, validarlas, etc.). Es una de las configuraciones que mas confusion genera, asi que conviene explicarla con cuidado.

Valores posibles:

- `none`: Hibernate no toca el esquema. Hay que crearlo por fuera (migraciones, scripts SQL).
- `validate`: Hibernate valida que las entidades coincidan con el esquema existente, pero no lo modifica. Si no coincide, falla al arrancar.
- `update`: Hibernate compara las entidades contra el esquema actual y aplica los cambios que faltan (agrega tablas o columnas). No suele borrar ni corregir columnas existentes.
- `create`: Hibernate borra el esquema existente y lo vuelve a crear desde cero al arrancar la aplicacion.
- `create-drop`: igual que `create`, pero ademas borra el esquema al apagar la aplicacion (util para tests o demos en memoria).

### Mensaje clave para explicar en clase
> "`update` es comodo para aprender y para una base H2 en memoria, porque no queremos escribir el esquema a mano en cada clase. Pero en un proyecto real, con una base persistente, `update` es riesgoso: puede generar cambios de esquema inesperados y no reemplaza una estrategia seria de migraciones."

Para dejarlo claro frente al grupo con perfil legacy (acostumbrado a control estricto de esquemas en mainframe): en un entorno productivo lo habitual es usar `validate` o `none`, y delegar la creacion/evolucion del esquema a herramientas de migracion como Flyway o Liquibase. Eso se puede mencionar como preview de buenas practicas, sin necesidad de implementarlo todavia (queda fuera del alcance de esta clase).

### Nota importante para Spring Boot 4.x (verificado en la documentacion oficial)
Segun la referencia oficial de Spring Boot, la consola H2 se auto-configura solo cuando se cumplen estas condiciones:
- la aplicacion es web basada en servlet
- `org.springframework.boot:spring-boot-h2console` esta en el classpath
- se esta usando Spring Boot DevTools

Si no se usa DevTools, se puede igualmente habilitar la consola seteando `spring.h2.console.enabled=true`, pero el artefacto `spring-boot-h2console` sigue siendo necesario en el classpath: es el modulo que contiene la auto-configuracion de la consola en Spring Boot 4.x (se separo del auto-configure principal).

En resumen:
- `com.h2database:h2` -> driver y motor de base de datos
- `org.springframework.boot:spring-boot-h2console` -> auto-configuracion de la consola web
- `spring.h2.console.enabled=true` -> activa la consola si el artefacto esta presente

Sin el artefacto de consola, las properties `spring.h2.console.*` no tienen efecto porque no existe el auto-configurador que las lea.

### Carga de datos de ejemplo con `data.sql`
Para que los alumnos puedan jugar con la persistencia sin tener que cargar productos a mano en cada reinicio, conviene agregar un script simple de datos de ejemplo.

Archivo: `src/main/resources/data.sql`

```sql
INSERT INTO products (name, price, stock) VALUES ('Laptop 15', 1200.50, 10);
INSERT INTO products (name, price, stock) VALUES ('Mouse inalambrico', 25.90, 50);
INSERT INTO products (name, price, stock) VALUES ('Teclado mecanico', 89.99, 30);
INSERT INTO products (name, price, stock) VALUES ('Monitor 24 pulgadas', 210.00, 15);
```

Spring Boot detecta automaticamente este archivo en el classpath y lo ejecuta contra el datasource al arrancar la aplicacion.

### Aclaracion importante: ¿Spring Boot ejecuta cualquier script SQL de `resources`?
No. Por defecto, Spring Boot solo busca y ejecuta automaticamente dos nombres especificos en la raiz del classpath (`src/main/resources`):

- `schema.sql`: para crear/ajustar el esquema (DDL).
- `data.sql`: para cargar datos (DML), que es el que usamos en esta clase.

Un archivo con cualquier otro nombre (por ejemplo `productos-demo.sql` o `seed.sql`) **no se ejecuta solo**. Para que Spring Boot lo tome, hay que declararlo explicitamente con las properties `spring.sql.init.schema-locations` y `spring.sql.init.data-locations`, por ejemplo:

```properties
spring.sql.init.data-locations=classpath:seed.sql
```

Otros detalles utiles para mencionar si surge la duda en clase:
- Tambien se soportan variantes por motor de base de datos: `schema-${platform}.sql` y `data-${platform}.sql` (por ejemplo `data-postgresql.sql`), usando `spring.sql.init.platform` para definir `${platform}`.
- Por defecto, esta inicializacion por script solo se ejecuta automaticamente si la base es embebida (como H2 en memoria). Para forzarla siempre, se usa `spring.sql.init.mode=always`.
- Esto es distinto del `import.sql` de Hibernate (una convencion propia de Hibernate, no de Spring Boot, que solo aplica cuando `ddl-auto` es `create` o `create-drop`). En esta clase usamos el mecanismo de Spring Boot (`data.sql`), que es mas simple de explicar y mas independiente del valor de `ddl-auto`.

### Aclaracion importante: orden de inicializacion con Hibernate
Cuando el esquema lo genera Hibernate (por `ddl-auto=update` o `create`), por defecto Spring Boot ejecuta `data.sql` ANTES de que Hibernate cree las tablas. Eso provoca un error tipico: `Table "PRODUCTS" not found`.

Para evitarlo, hay que agregar esta property en `application.properties`:

```properties
spring.jpa.defer-datasource-initialization=true
```

Esto le indica a Spring Boot que espere a que Hibernate termine de crear/actualizar el esquema antes de correr `data.sql`.

### Mensaje clave para explicar en clase
> "El script `data.sql` es una forma rapida de tener datos para probar el `GET /api/products` apenas arranca la aplicacion, sin depender de hacer POSTs manuales. Pero si usamos Hibernate para generar el esquema, hay que decirle a Spring Boot que espere con `spring.jpa.defer-datasource-initialization=true`, sino el script se ejecuta demasiado temprano y falla porque la tabla todavia no existe."

Con esto, al arrancar la aplicacion y consultar `GET /api/products`, los alumnos ya van a ver productos cargados sin haber hecho ningun `POST` previo, lo que facilita la demo y la exploracion libre.

## 8) Flujo de la clase en vivo
Se puede seguir este guion para la demo:

### Paso 1: explicar el problema
"Hoy el producto vive en una lista. Eso funciona para aprender, pero no para una aplicacion real. Necesitamos guardar la informacion en una base de datos."

### Paso 2: mostrar la entidad
"Esta clase `Product` va a pasar a ser una entidad JPA. La diferencia es que ahora representa una tabla y no solo un POJO de negocio."

### Paso 3: crear el repository
"El repository es la capa de acceso a datos. Con `JpaRepository` ya tenemos CRUD basico."

### Paso 4: adaptar el service
"El servicio deja de manejar la coleccion en memoria y delega al repository."

### Paso 5: correr la aplicacion
"Con H2 levantado, podemos crear un 'Product' a traves del endpoint y luego consultarlo."

### Paso 6: mostrar H2 console
"Desde la consola H2 se puede ver que la fila existe en la tabla `products` (y, si cargamos el `data.sql`, ya se ven los productos precargados desde el arranque de la aplicacion)."

## 9) Endpoint de ejemplo
La API sigue teniendo la misma forma de antes, pero ya persistiendo:

```http
POST /api/products
Content-Type: application/json

{
  "name": "Auriculares bluetooth",
  "price": 45.00,
  "stock": 20
}
```

Respuesta esperada (si ya se cargo el `data.sql` con 4 productos de ejemplo, el nuevo id continua desde ahi):

```json
{
  "id": 5,
  "name": "Auriculares bluetooth",
  "price": 45.00,
  "stock": 20
}
```

Y luego:

```http
GET /api/products
```

Con la lista completa desde la base de datos: los 4 productos precargados por `data.sql` mas el que se acaba de crear por `POST`. Esto es un buen momento para remarcar que los ids no dependen de lo que el cliente envia, sino de la estrategia de `@GeneratedValue` configurada en la entidad.

## 10) Errores comunes a explicar
- olvidar `@Entity`
- no agregar `@Id`
- no levantar H2 correctamente
- mezclar DTO y entidad en el mismo objeto
- guardar una entidad sin usar el repository
- pensar que validacion y persistencia son lo mismo
- agregar solo `com.h2database:h2` y esperar que la consola funcione, sin incluir `org.springframework.boot:spring-boot-h2console` (en Spring Boot 4.x no alcanza con el driver)
- agregar `data.sql` y no entender por que falla con `Table "PRODUCTS" not found`, por no haber seteado `spring.jpa.defer-datasource-initialization=true` cuando el esquema lo crea Hibernate

## 11) Diferencia clave a enfatizar
### DTO
- define la entrada/salida de la API
- se usa para comunicar con clientes
- acompana el contrato HTTP

### Entidad
- representa la tabla real
- se usa para persistencia
- no siempre debe exponerse tal cual al cliente

## 12) Preguntas de cierre para reforzar aprendizaje
- ¿Que cambio de arquitectura hubo entre la clase 02 y la 03?
- ¿Por que H2 es una buena eleccion para empezar?
- ¿Que responsabilidad tiene `ProductRepository`?
- ¿Cual es la diferencia entre un DTO y una entidad?
- ¿Que pasa si un objeto no tiene `@Id`?

## 13) Objetivo de la siguiente clase
La siguiente clase va a construir sobre esta base y mostrar relaciones entre entidades, por ejemplo:

- `Product` y `Category`
- `Cart` y `CartItem`
- `Order` y `OrderItem`

Eso se logra porque ya entendimos como una entidad se persiste y se consulta en la base de datos.

## 14) Recomendacion pedagógica final
No conviene hacer una clase de JPA avanzada. El objetivo es que el alumno entienda el patron minimo de persistencia y vea un flujo funcional real.

La clase debe mostrar que:

- el negocio sigue igual
- la API sigue igual desde afuera
- la diferencia grande esta en la capa de persistencia

Y eso es justamente el salto conceptual que se busca en la clase 03.
