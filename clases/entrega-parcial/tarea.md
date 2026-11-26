# Entrega Final Springboot

## Objetivo
Esta entrega integra, en un unico proyecto funcional, todos los ejercicios y tareas resueltos desde la clase 07 hasta la clase 13. No incorpora contenido nuevo: es la consolidacion de lo que ya se trabajo clase a clase.

El objetivo es verificar que el proyecto completo compila, levanta y responde correctamente, con la arquitectura por capas (`controller` -> `service` -> `dto` -> `model`/`entity` -> `repository`) sostenida de punta a punta.

## Alcance
Resumen por clase de lo que debe estar resuelto e integrado:

- **Clase 07**: modulo `Product` en memoria, con endpoints basicos y DTOs de entrada/salida.
- **Clase 08**: validaciones con Bean Validation sobre `ProductRequestDto` y sobre un DTO nuevo (`CustomerRequestDto`).
- **Clase 09**: `Product` y `Customer` persistidos con JPA/Hibernate sobre H2.
- **Clase 10**: relaciones entre entidades: `Cart` / `CartItem` (`@OneToMany` / `@ManyToOne`) y `Customer` / `Address` (`@OneToOne`).
- **Clase 11**: manejo global de errores con `@RestControllerAdvice`, excepciones de negocio y formato uniforme de error.
- **Clase 12**: consultas con query methods y JPQL sobre `Product` (busqueda por nombre, categoria, rango de precio, orden).
- **Clase 13**: paginacion, sorting y filtros combinables sobre el listado de productos.

## Entidades (JPA)

### `Product`
- `id`: `Long`
- `name`: `String`
- `description`: `String`
- `category`: `String`
- `price`: `BigDecimal`
- `stock`: `Integer`

### `Customer`
- `id`: `Long`
- `firstName`: `String`
- `lastName`: `String`
- `email`: `String`
- `phone`: `String`
- `address`: `Address` (relacion `@OneToOne`, unidireccional, `@JoinColumn(name = "address_id", unique = true)`)

### `Address`
- `id`: `Long`
- `street`: `String`
- `city`: `String`
- `zipCode`: `String`

### `Cart`
- `id`: `Long`
- `items`: `List<CartItem>` (relacion `@OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)`)
- Metodo helper `addItem(CartItem item)` que sincroniza ambos lados de la relacion.

### `CartItem`
- `id`: `Long`
- `cart`: `Cart` (`@ManyToOne`, lado dueno de la relacion con `Cart`)
- `product`: `Product` (`@ManyToOne`, relacion unidireccional)
- `quantity`: `Integer`

## DTOs esperados

### Product
- `ProductRequestDto`: `name`, `description`, `category`, `price`, `stock` (con validaciones: `name` obligatorio, `price` positivo, `stock` mayor o igual a cero).
- `ProductResponseDto`: `id`, `name`, `description`, `category`, `price`, `stock`.
- `ProductStockUpdateDto`: `quantity` (cantidad a sumar al stock existente; el producto se identifica por `{id}` en la URL, no en el body).

### Customer
- `CustomerRequestDto`: `firstName`, `lastName`, `email`, `phone` (con las validaciones definidas en clase 02: `firstName`/`lastName` obligatorios con minimo de caracteres, `email` con formato valido, `phone` opcional con minimo de digitos si se envia).
- `CustomerResponseDto`: `id`, `firstName`, `lastName`, `email`, `phone`.

### Cart
- `CartItemResponseDto`: `productId`, `productName`, `price`, `quantity`.
- `CartResponseDto`: `id`, `items` (lista de `CartItemResponseDto`).
- `AddCartItemRequestDto`: `productId` (obligatorio), `quantity` (obligatorio, mayor a cero).

### Errores
- `ApiErrorResponse`: `timestamp`, `status`, `error`, `message`, `path`.

## Repositorios

- `ProductRepository extends JpaRepository<Product, Long>`, con:
  - Query methods: busqueda por nombre (ignorando mayusculas/minusculas), por categoria, por rango de precio.
  - Al menos una consulta JPQL con `@Query` (por ejemplo, orden por precio descendente dentro de una categoria).
  - Un metodo que reciba `Pageable` y devuelva `Page<Product>`, soportando los filtros combinables de la clase 07 (`category`, rango de precio).
- `CustomerRepository extends JpaRepository<Customer, Long>`.
- `CartRepository extends JpaRepository<Cart, Long>` (no hace falta repository propio para `CartItem`: se gestiona en cascada a traves de `Cart`).

## Servicios

- `ProductService`: listar (con paginacion y filtros), buscar por id, crear, actualizar stock, lanzar `ResourceNotFoundException` cuando corresponda.
- `CustomerService`: listar, buscar por id, crear, lanzar `ResourceNotFoundException` cuando corresponda.
- `CartService`: crear carrito vacio, buscar carrito por id, agregar item a un carrito existente (resolviendo `Cart` y `Product` por id y usando `cart.addItem(item)`), lanzando `ResourceNotFoundException` o `ConflictException` segun el caso.

## Manejo global de errores

- `GlobalExceptionHandler` anotado con `@RestControllerAdvice`, con handlers para:
  - `ResourceNotFoundException` -> HTTP 404
  - `ConflictException` -> HTTP 409
  - `MethodArgumentNotValidException` -> HTTP 400
  - `Exception` (fallback) -> HTTP 500
- Todas las respuestas de error deben devolver un `ApiErrorResponse` con el mismo formato, sin exponer detalles internos (stack traces) al cliente.

## Endpoints esperados

### Product
- `GET /api/products` (con soporte de `page`, `size`, `sort` y filtros combinables `category`, `minPrice`, `maxPrice`)
- `GET /api/products/{id}`
- `POST /api/products`
- `PATCH /api/products/{id}/stock`
- `GET /api/products/search?name=...`
- `GET /api/products/category?category=...`
- `GET /api/products/price-range?min=...&max=...`

### Customer
- `GET /api/customers`
- `GET /api/customers/{id}`
- `POST /api/customers`

### Cart
- `POST /api/carts`
- `GET /api/carts/{id}`
- `POST /api/carts/{cartId}/items`

## Validaciones esperadas

- `@Valid` activo en todos los `@RequestBody` que lo requieran (`ProductRequestDto`, `CustomerRequestDto`, `AddCartItemRequestDto`).
- Reglas minimas: campos obligatorios no vacios, `price` positivo, `stock`/`quantity` no negativos, `email` con formato valido.
- Los errores de validacion deben responder con HTTP 400 y el formato uniforme de `ApiErrorResponse`.

## Persistencia

- Todas las entidades (`Product`, `Customer`, `Address`, `Cart`, `CartItem`) persistidas en H2.
- Relaciones correctamente mapeadas:
  - `Cart` (1) -> `CartItem` (N), `mappedBy = "cart"`.
  - `CartItem` (N) -> `Product` (1), unidireccional.
  - `Customer` (1) -> `Address` (1), unidireccional, con `unique = true` en el `@JoinColumn`.
- La API nunca expone entidades JPA directamente: siempre se mapea a DTOs de respuesta.

## Criterios de aceptacion de la entrega

- El proyecto compila y levanta sin errores.
- Todos los endpoints listados responden correctamente con datos reales persistidos en H2.
- Las validaciones de los DTOs de entrada funcionan y devuelven HTTP 400 con formato uniforme.
- Los casos de error de negocio (recurso no encontrado, conflicto) devuelven el codigo HTTP correcto con `ApiErrorResponse`.
- El listado de productos soporta paginacion, orden y filtros combinables sin romper los endpoints de busqueda mas simples de la clase 06.
- Se puede demostrar el flujo completo: crear un cliente, crear un producto, crear un carrito, agregar el producto al carrito y consultarlo.
- La separacion por capas (`controller` / `service` / `dto` / `model` o `entity` / `repository`) se mantiene en todo el proyecto, sin mezclar entidades JPA con DTOs de API.

## Forma de entrega

- Repositorio Git con el proyecto completo, historial de commits legible por clase o por funcionalidad.