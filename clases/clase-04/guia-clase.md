# Clase 04 - Guia base para explicar la clase

## Objetivo de la clase
- Introducir relaciones entre entidades JPA (`@OneToMany` / `@ManyToOne`).
- Entender que decidir el lado "dueno" de una relacion no es un detalle de sintaxis: define que tabla tiene la clave foranea y cuantas sentencias SQL se ejecutan.
- Ver la diferencia entre relacion bidireccional y unidireccional, y aplicar cada una donde corresponde.
- Mantener la separacion entidad/DTO ya trabajada en clases anteriores, ahora en un escenario con relaciones (evitar referencias circulares al serializar).

## Agenda sugerida
1. Recordatorio breve de la clase 03
2. Por que necesitamos relaciones ahora (`Cart`/`CartItem`/`Product`)
3. Entidad `Cart` con `@OneToMany`
4. Entidad `CartItem` con `@ManyToOne` (doble relacion: `Cart` y `Product`)
5. Por que `CartItem` es el lado dueno (y que pasa si no lo es)
6. `CartRepository`
7. DTOs de salida (`CartResponseDto`, `CartItemResponseDto`)
8. `CartService` y `CartController`
9. Demo en vivo + consola H2
10. Cierre y dudas

## 1) Recordatorio de la clase anterior
- `Product` y `Customer` ya son entidades JPA persistidas en H2, cada una de forma totalmente independiente.
- Hasta la clase 03 nunca tuvimos que decidir "quien tiene la clave foranea", porque no habia relaciones.

Frase guia para la clase:

> "Si la clase 03 nos enseno a persistir una entidad sola, la clase 04 nos ensena a persistir dos entidades que se necesitan entre si."

## 2) ¿Por que necesitamos relaciones ahora?
Un carrito de compras no tiene sentido como entidad aislada: por definicion contiene productos. Necesitamos modelar:

- Un `Cart` (el carrito).
- Varios `CartItem` (cada producto agregado, con su cantidad).
- Cada `CartItem` apunta a un `Product` ya existente.

Esto nos obliga a resolver dos preguntas de diseno antes de escribir una sola linea de codigo:

1. ¿`Cart` necesita conocer a sus `CartItem` (bidireccional), o alcanza con que `CartItem` conozca a su `Cart` (unidireccional)?
2. ¿`CartItem` necesita que `Product` lo conozca de vuelta, o alcanza con que `CartItem` conozca a `Product`?

### Regla general para decidir
> "Bidireccional solo si ambos lados necesitan navegar objeto-a-objeto con frecuencia. Si no, unidireccional + consulta por repository."

Aplicado a nuestro modelo:

- **`Cart` <-> `CartItem`: bidireccional.** El caso de uso central de la clase es "mostrar el carrito con sus items" (`cart.getItems()`), y ademas lo vamos a usar para buscar si un producto ya esta en el carrito sin necesitar un repository extra.
- **`CartItem` -> `Product`: unidireccional.** `Product` no tiene ningun caso de uso en esta clase que requiera "dame todos los `CartItem` que me referencian". Agregar esa relacion inversa seria acoplar `Product` a un concepto (carritos) que no le corresponde.

## 3) Entidad `Cart`

```java
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity                      // marca la clase como entidad gestionada por JPA/Hibernate (se mapea a una tabla)
@Table(name = "carts")       // nombre real de la tabla; si se omite, Hibernate usa el nombre de la clase
public class Cart {

    @Id                                                   // clave primaria de la entidad
    @GeneratedValue(strategy = GenerationType.IDENTITY)    // delega en la BD la generacion automatica del id (columna auto-incremental)
    private Long id;

    @OneToMany(
        mappedBy = "cart",          // el campo "cart" de CartItem es quien tiene la FK real; Cart solo navega/lee esta relacion, no la gestiona
        cascade = CascadeType.ALL,  // las operaciones sobre Cart (guardar, borrar) se propagan a sus CartItem asociados
        orphanRemoval = true        // si un CartItem se saca de la lista "items", se borra de la base (no queda huerfano sin carrito)
    )
    // no hace falta declarar "fetch" aca: @OneToMany ya es LAZY por defecto en JPA
    private List<CartItem> items = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public List<CartItem> getItems() {
        return items;
    }

    // Metodo helper: agrega un item y sincroniza el lado inverso de la relacion.
    // Sin este metodo, habria que acordarse de llamar item.setCart(cart) manualmente
    // cada vez que se agrega un item, con el riesgo de olvidarlo y dejar los dos lados
    // de la relacion desincronizados en memoria.
    public void addItem(CartItem item) {
        items.add(item);
        item.setCart(this);
    }
}
```

### Explicacion de cada parametro usado

#### `@OneToMany(mappedBy = "cart", ...)`
- `mappedBy = "cart"`: le dice a Hibernate "no soy yo (`Cart`) quien tiene la columna de la relacion en la tabla; es el campo llamado `cart` dentro de `CartItem`". Por eso `carts` no recibe ninguna columna ni tabla extra: esta anotacion es pura navegacion en Java, sin impacto fisico en el esquema de `Cart`.
- `cascade = CascadeType.ALL`: equivale a aplicar todas las operaciones de ciclo de vida (`PERSIST`, `MERGE`, `REMOVE`, `REFRESH`, `DETACH`) desde `Cart` hacia sus `CartItem`. En la practica, con esto alcanza con hacer `cartRepository.save(cart)` para que tambien se guarden los `CartItem` nuevos que se hayan agregado a la lista.
- `orphanRemoval = true`: si un `CartItem` deja de estar en la lista `items` (por ejemplo, se remueve con `items.remove(item)`), Hibernate lo borra de la base automaticamente en el proximo flush/commit.

## 4) Entidad `CartItem`

```java
import jakarta.persistence.*;

@Entity
@Table(name = "cart_items")
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)   // la cantidad no puede quedar nula en la tabla
    private Integer quantity;

    @ManyToOne(fetch = FetchType.LAZY)   // forzamos LAZY: por defecto @ManyToOne es EAGER, y no queremos cargar el Cart completo cada vez que se trae un CartItem
    @JoinColumn(
        name = "cart_id",    // nombre de la columna FK en la tabla cart_items
        nullable = false     // todo CartItem debe pertenecer a un carrito (no puede existir "suelto")
    )
    private Cart cart;

    @ManyToOne(fetch = FetchType.LAZY)   // idem: evitamos el EAGER por defecto para no traer el Product completo sin necesidad
    @JoinColumn(
        name = "product_id",
        nullable = false
    )
    private Product product;   // relacion unidireccional: Product no tiene ningun campo que apunte de vuelta a CartItem

    public Long getId() {
        return id;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Cart getCart() {
        return cart;
    }

    public void setCart(Cart cart) {
        this.cart = cart;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }
}
```

### Explicacion de cada parametro usado

#### `@ManyToOne(fetch = FetchType.LAZY)`
- `fetch = FetchType.LAZY`: en vez de traer el `Cart`/`Product` relacionado inmediatamente al cargar un `CartItem`, Hibernate solo trae un proxy y ejecuta la consulta real recien cuando se accede a sus datos (por ejemplo `cartItem.getProduct().getName()`). Importante: `@ManyToOne` y `@OneToOne` son `EAGER` por defecto en JPA, por eso hace falta sobreescribirlo explicitamente; en cambio `@OneToMany` y `@ManyToMany` ya son `LAZY` por defecto (de ahi que no se repita en `Cart`).

#### `@JoinColumn(name = "...", nullable = false)`
- `name`: nombre de la columna fisica que va a actuar como clave foranea en `cart_items`.
- `nullable = false`: la columna no admite nulos; en este modelo todo `CartItem` necesita si o si un `Cart` y un `Product` validos.

### ¿Por que `CartItem` es el lado "dueno" de ambas relaciones?
`CartItem` es quien declara los `@JoinColumn` (`cart_id`, `product_id`), es decir, quien fisicamente tiene las columnas de clave foranea en su tabla. Esa es la definicion de "lado dueno" en JPA: el lado `@ManyToOne` siempre es el dueno de la relacion con el lado `@OneToMany`.

### Que pasaria si lo modelaramos al reves (bonus para explicar si surge la duda)
- Si se declara `@OneToMany` en `Cart` **sin** `mappedBy` y **sin** `@JoinColumn`: Hibernate no tiene forma de saber que `cart_items` podria tener la FK, asi que crea una **tabla intermedia extra** (`cart_cart_items`), como si fuera un `@ManyToMany`. Antipatron tipico.
- Si se declara `@OneToMany` en `Cart` con `@JoinColumn` pero **sin** `mappedBy`: evita la tabla intermedia, pero como `Cart` sigue siendo quien "gestiona" la relacion, Hibernate genera un `INSERT` sin la FK y despues un `UPDATE` aparte para completarla, en vez de un unico `INSERT` completo. Con `CartItem` como dueno (nuestro modelo), el `INSERT` ya incluye la FK desde el principio.

## 4.1) Relacion `@OneToOne` - version breve con `Customer`/`Address`

Antes de seguir con `CartRepository`, vale la pena mostrar `@OneToOne` porque es la relacion mas facil de razonar: solo hay que decidir quien tiene la FK (igual que en `@ManyToOne`), pero ademas esa FK tiene que ser `unique` para garantizar que la cardinalidad sea realmente 1 a 1 y no una variante disfrazada de `@ManyToOne`.

```java
@Entity
@Table(name = "addresses")
public class Address {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String street;

    @Column(nullable = false)
    private String city;

    @Column(nullable = false)
    private String zipCode;

    // getters y setters
}
```

```java
// Customer.java (agregar este campo a la entidad ya creada en la tarea de la clase 03)

@OneToOne(fetch = FetchType.LAZY)   // @OneToOne tambien es EAGER por defecto (igual que @ManyToOne); lo forzamos a LAZY por la misma razon
@JoinColumn(
    name = "address_id",   // columna FK nueva en la tabla customers
    unique = true          // clave del OneToOne: garantiza que cada address pertenezca a un unico customer (sin esto, varios customers podrian apuntar a la misma address, y en los hechos seria un ManyToOne)
)
private Address address;
```

### Explicacion de lo nuevo respecto a `@ManyToOne`
- La anotacion `@OneToOne` se usa igual que `@ManyToOne` en cuanto a sintaxis (`@JoinColumn` del lado dueno), pero la diferencia de fondo esta en `unique = true`. Esa restriccion es la que efectivamente convierte la relacion en 1 a 1 a nivel de base de datos; sin ella, el modelo de objetos dice "uno a uno" pero la base permitiria "muchos a uno".
- Es **unidireccional** (igual que `CartItem -> Product`): `Address` no tiene ningun campo que apunte de vuelta a `Customer`. Si se necesitara navegar `address.getCustomer()`, se agregaria `mappedBy` del lado `Address`, con el mismo criterio ya visto en `Cart`/`CartItem`.
- Recordatorio de la clase anterior: si el proyecto usa `ddl-auto=none`, `unique = true` no genera ninguna constraint fisica real; solo documenta la intencion en el codigo. Para que la unicidad se cumpla de verdad en ese caso, hay que agregarla en el script de esquema (`ALTER TABLE customers ADD CONSTRAINT uq_customer_address UNIQUE (address_id);`).

### Mensaje clave para explicar en clase
> "De los tres tipos de relacion que vemos hoy, `@OneToOne` es el mas facil de razonar: es basicamente un `@ManyToOne` al que le agregamos `unique = true` para que la cardinalidad sea realmente 1 a 1."

## 5) `CartRepository`

```java
public interface CartRepository extends JpaRepository<Cart, Long> {
}
```

No hace falta un repository propio para `CartItem`: gracias a `cascade = CascadeType.ALL` en `Cart.items`, alcanza con guardar el `Cart` para que sus `CartItem` se persistan en la misma operacion.

## 6) DTOs de salida

Igual que con `Product`/`Customer`, no se debe devolver la entidad JPA directamente: haria falta serializar un proxy lazy (`Cart.items`) y se arriesgaria un loop de referencias (`Cart -> CartItem -> Cart`).

```java
public record CartItemResponseDto(
    Long productId,
    String productName,
    BigDecimal price,
    Integer quantity
) {
}
```

```java
public record CartResponseDto(
    Long id,
    List<CartItemResponseDto> items
) {
}
```

## 7) `CartService`

```java
@Service
public class CartService {

    private final CartRepository cartRepository;

    public CartService(CartRepository cartRepository) {
        this.cartRepository = cartRepository;
    }

    public CartResponseDto createCart() {
        Cart cart = new Cart();
        Cart saved = cartRepository.save(cart);
        return toResponseDto(saved);
    }

    public CartResponseDto getCart(Long cartId) {
        Cart cart = cartRepository.findById(cartId)
                .orElseThrow(() -> new NoSuchElementException("Carrito no encontrado: " + cartId));
        return toResponseDto(cart);
    }

    private CartResponseDto toResponseDto(Cart cart) {
        List<CartItemResponseDto> items = cart.getItems().stream()
                .map(item -> new CartItemResponseDto(
                        item.getProduct().getId(),
                        item.getProduct().getName(),
                        item.getProduct().getPrice(),
                        item.getQuantity()
                ))
                .toList();
        return new CartResponseDto(cart.getId(), items);
    }
}
```

### Observacion didactica
El manejo de la excepcion (`NoSuchElementException`) todavia es simple a proposito: el formato uniforme de errores con `@ControllerAdvice` recien se ve en la clase 05. Por ahora alcanza con devolver un 404 basico desde el controller.

## 8) `CartController`

```java
@RestController
@RequestMapping("/api/carts")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @PostMapping
    public ResponseEntity<CartResponseDto> createCart() {
        CartResponseDto response = cartService.createCart();
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CartResponseDto> getCart(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(cartService.getCart(id));
        } catch (NoSuchElementException ex) {
            return ResponseEntity.notFound().build();
        }
    }
}
```

## 9) Flujo de la clase en vivo
Se puede seguir este guion para la demo:

### Paso 1: explicar el problema
"Hasta ahora cada entidad vivia sola. Un carrito, por definicion, necesita relacionarse con productos. Hoy aprendemos a modelar esa relacion."

### Paso 2: mostrar `Cart` y explicar `mappedBy`
"`Cart` tiene una lista de `CartItem`, pero `mappedBy` le dice a Hibernate que no cree ninguna columna nueva en `carts`: la relacion la gestiona el otro lado."

### Paso 3: mostrar `CartItem` y explicar el doble `@ManyToOne`
"`CartItem` es quien realmente tiene las columnas `cart_id` y `product_id`. Por eso es el lado dueno de ambas relaciones."

### Paso 4: mostrar el metodo `addItem()`
"Esto es lo que mantiene sincronizados los dos lados de la relacion bidireccional: si no lo hicieramos, `item.getCart()` podria quedar en `null` aunque el item ya este en la lista."

### Paso 5: correr la aplicacion
"Creamos un carrito con `POST /api/carts` y lo consultamos con `GET /api/carts/{id}`."

### Paso 6: mostrar H2 console
"Importante: miren la tabla `carts`, no tiene ninguna columna nueva. La FK esta solo en `cart_items`."

## 10) Endpoints de ejemplo

```http
POST /api/carts
```

Respuesta esperada:

```json
{
  "id": 1,
  "items": []
}
```

```http
GET /api/carts/1
```

Respuesta esperada (carrito vacio en esta clase, ya que agregar productos queda para la tarea):

```json
{
  "id": 1,
  "items": []
}
```

## 11) Errores comunes a explicar
- Olvidar `mappedBy` en el `@OneToMany` de `Cart` (genera tabla intermedia o updates extra, segun el caso).
- Declarar `@ManyToOne` sin pensar en `fetch`, dejando el `EAGER` por defecto y cargando relaciones de mas sin darse cuenta.
- Olvidar sincronizar los dos lados de la relacion bidireccional (agregar a la lista sin llamar `setCart()`), dejando el modelo inconsistente en memoria dentro de la misma transaccion.
- Devolver la entidad `Cart` directamente en el controller en vez del DTO (riesgo de loop de serializacion y de exponer el proxy lazy de Hibernate).
- Confundir la anotacion de relacion de JPA con una constraint fisica de clave foranea: son conceptos independientes (se puede mapear `@ManyToOne` sobre una columna que no tiene una `FOREIGN KEY` real en el motor de base de datos).

## 11.1) ¿Y `@ManyToMany`? (mencion, sin implementacion)
JPA tambien ofrece `@ManyToMany` para modelar relaciones N a N directo, generando una tabla intermedia automaticamente. En este curso **no la vamos a usar**, y vale la pena explicar por que, conectandolo con lo que ya hicimos:

- Casi siempre una relacion N a N de negocio termina necesitando atributos propios (en nuestro caso, `quantity`; en otros dominios podria ser una fecha, un estado, un precio). `@ManyToMany` no puede modelar esos atributos: solo representa el vinculo "A se relaciona con B", nada mas.
- `Cart` <-> `Product` es, conceptualmente, una relacion muchos-a-muchos (un carrito tiene muchos productos, un producto puede estar en muchos carritos). En vez de usar `@ManyToMany`, la resolvimos con una **entidad intermedia explicita** (`CartItem`), que ademas carga el atributo `quantity`. Es el mismo patron que se usa en la gran mayoria de proyectos reales con relaciones N a N: entidad de join explicita en vez de `@ManyToMany` directo.
- Beneficio extra de la entidad explicita: tiene su propio `@Id`, se puede indexar, consultar o testear de forma independiente (`CartItem` podria tener su propio repository si hiciera falta), cosa que la tabla de join autogenerada por `@ManyToMany` no permite con la misma comodidad.

### Mensaje clave para explicar en clase
> "No vamos a usar `@ManyToMany` en este curso. Cuando aparece una relacion muchos-a-muchos de negocio, preferimos modelarla con una entidad intermedia explicita, como ya hicimos con `CartItem`."

## 12) Diferencia clave a enfatizar
### Relacion bidireccional (`Cart` <-> `CartItem`)
- Ambos lados necesitan navegar el uno hacia el otro con frecuencia.
- Requiere mantener sincronizados los dos lados (metodo helper `addItem()`).
- El lado `mappedBy` no tiene ningun impacto fisico en su propia tabla.

### Relacion unidireccional (`CartItem` -> `Product`)
- Solo un lado necesita navegar hacia el otro.
- Mas simple: no hay que sincronizar nada ni agregar metodos helper.
- Si en el futuro hiciera falta la direccion inversa, se resuelve con una consulta de repository (`findByProductId`), no agregando una relacion nueva a `Product`.

## 13) Preguntas de cierre para reforzar aprendizaje
- ¿Por que `carts` no tiene ninguna columna nueva por la relacion con `cart_items`?
- ¿Que diferencia hay entre el `fetch` por defecto de `@ManyToOne` y el de `@OneToMany`?
- ¿Por que `CartItem` es el lado dueno de la relacion con `Cart`?
- ¿Que riesgo hay si se devuelve la entidad `Cart` directamente en vez de `CartResponseDto`?
- ¿Por que `CartItem -> Product` se modelo unidireccional?

## 14) Objetivo de la siguiente actividad (tarea)
La tarea de esta clase retoma exactamente este modelo para agregar la funcionalidad que todavia falta: un endpoint para agregar un producto existente a un carrito existente (`POST /api/carts/{cartId}/items`). El detalle de esa consigna se define en `tarea.md`; esta guia solo deja construida la base de entidades, repository, DTOs y los dos endpoints iniciales (crear carrito, consultar carrito).

## 15) Recomendacion pedagogica final
No conviene entrar en detalles de `@ManyToMany` en esta clase. El objetivo es que el alumno entienda el patron minimo de relacion 1-a-N con JPA y por que la eleccion del lado dueno no es arbitraria. Esa base alcanza para que la tarea (agregar producto al carrito) se resuelva aplicando el mismo criterio, sin introducir conceptos nuevos.

Vale aclarar que `Order`/`OrderItem` (cabecera + lineas), que se va a ver mas adelante en el programa, usa estructuralmente el **mismo patron relacional** que `Cart`/`CartItem` (`@OneToMany`/`@ManyToOne`, mismo criterio de lado dueno). La complejidad adicional que trae una orden no es de modelado de relaciones, sino de reglas de negocio: por ejemplo, guardar una copia del precio del producto al momento de la compra (en vez de referenciarlo en vivo, ya que el precio de `Product` puede cambiar despues), o manejar transiciones de estado de la orden. Esos temas no corresponden a esta clase.
