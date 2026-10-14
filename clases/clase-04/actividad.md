# Clase 04 - Actividad en clase

## Contexto
- `Product` (clase 03) y `Customer` (tarea de clase 03) ya son entidades JPA persistidas en H2, cada una de forma independiente.
- Hasta ahora no modelamos ninguna relacion entre entidades: cada tabla vive por separado.
- El siguiente paso natural del dominio de e-commerce es representar un **carrito de compras**, que por definicion necesita relacionarse con productos.
- Esta clase introduce el concepto de relaciones en JPA (`@OneToMany` / `@ManyToOne`), y por que la eleccion de que lado "es dueno" de la relacion no es un detalle menor sino que impacta directamente en las tablas generadas y en el SQL ejecutado.

## Objetivo de la actividad
- Entender la diferencia entre relacion unidireccional y bidireccional, y cuando conviene cada una.
- Comprender que el lado dueno de una relacion `@OneToMany`/`@ManyToOne` siempre deberia ser el lado `@ManyToOne` (el que fisicamente tiene la clave foranea).
- Ver en la practica que `mappedBy` no genera ninguna columna ni tabla extra: es pura comodidad de navegacion en Java.
- Seguir reforzando la separacion entre entidad JPA y DTO, ahora en un escenario con relaciones (evitar serializar la entidad directa y romper la API con referencias circulares).

## Consigna
1. Crear la entidad `Cart`:
   - `@Entity`, `@Table(name = "carts")`, `@Id` + `@GeneratedValue(strategy = GenerationType.IDENTITY)`.
   - Relacion `@OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)` hacia `CartItem` (no hace falta declarar `fetch`: `@OneToMany` ya es `LAZY` por defecto).
   - Metodo helper `addItem(CartItem item)` que agregue el item a la lista y sincronice la referencia inversa (`item.setCart(this)`).
2. Crear la entidad `CartItem`:
   - `@Entity`, `@Table(name = "cart_items")`, `@Id` + `@GeneratedValue(strategy = GenerationType.IDENTITY)`.
   - Campo `quantity` (`@Column(nullable = false)`).
   - `@ManyToOne(fetch = FetchType.LAZY)` + `@JoinColumn(name = "cart_id", nullable = false)` hacia `Cart` (lado dueno de la relacion con `Cart`).
   - `@ManyToOne(fetch = FetchType.LAZY)` + `@JoinColumn(name = "product_id", nullable = false)` hacia `Product` (relacion **unidireccional**: `Product` no conoce a `CartItem`).
3. Crear `CartRepository extends JpaRepository<Cart, Long>` (no hace falta repository propio para `CartItem`, se gestiona en cascada a traves de `Cart`).
4. Crear los DTOs de salida para evitar exponer la entidad JPA directamente:
   - `CartItemResponseDto(Long productId, String productName, BigDecimal price, Integer quantity)`.
   - `CartResponseDto(Long id, List<CartItemResponseDto> items)`.
5. Crear `CartService` con dos operaciones:
   - Crear un carrito vacio.
   - Buscar un carrito por id y mapearlo a `CartResponseDto` (incluyendo sus items, si tuviera).
6. Exponer los endpoints:
   - `POST /api/carts` -> crea un carrito vacio.
   - `GET /api/carts/{id}` -> devuelve el carrito con sus items (en esta clase puede estar vacio, ya que agregar productos queda para la tarea).
7. Probar el flujo en H2: crear un carrito, consultarlo, y revisar en la consola H2 que la tabla `cart_items` tiene la columna `cart_id` y que `carts` **no** tiene ninguna columna nueva por la relacion.
8. Extra breve - relacion `@OneToOne`: agregar la entidad `Address` (`street`, `city`, `zipCode`) y vincularla de forma unidireccional desde `Customer` (la entidad ya creada en la tarea de la clase 03) con `@OneToOne` + `@JoinColumn(name = "address_id", unique = true)`. No hace falta crear un endpoint nuevo para esto: alcanza con verificar en la consola H2 que la tabla `customers` ahora tiene la columna `address_id`, y entender por que aca si hace falta `unique = true` (a diferencia de `@ManyToOne`, donde no corresponde).

## Preguntas orientadoras para la clase
- ¿Por que devolver la entidad `Cart` tal cual rompería la API (riesgo de referencia circular `Cart -> CartItem -> Cart`)?
- ¿Quien es el "dueno" de la relacion (`mappedBy`) y por que importa a nivel de columnas generadas?
- ¿Que pasaria si declaramos `@OneToMany` en `Cart` sin `mappedBy` y sin `@JoinColumn`? ¿Y si le agregamos `@JoinColumn` pero sin `mappedBy`?
- ¿Por que `CartItem -> Product` queda unidireccional y no bidireccional?
- ¿Por que no hizo falta declarar `fetch = FetchType.LAZY` en el `@OneToMany` de `Cart`, pero si en los `@ManyToOne` de `CartItem`?
- ¿Por que en la relacion `Customer` -> `Address` hace falta `unique = true` en el `@JoinColumn`, y en `CartItem` -> `Cart`/`Product` no?

## Criterios de aceptacion
- Se entiende la diferencia entre relacion unidireccional y bidireccional, y se puede justificar la eleccion para cada relacion del modelo.
- La tabla `carts` no tiene ninguna columna extra producto de la relacion con `cart_items`.
- La tabla `cart_items` tiene las columnas `cart_id` y `product_id` como claves foraneas.
- La tabla `customers` tiene una nueva columna `address_id` producto de la relacion `@OneToOne` con `Address`.
- La API expone `CartResponseDto`/`CartItemResponseDto`, nunca la entidad JPA directamente.
- Se prueba al menos un caso feliz: crear un carrito y consultarlo por id.

## Pistas para la clase
- Fetch types por defecto en JPA: `@OneToMany` y `@ManyToMany` son `LAZY` por defecto; `@ManyToOne` y `@OneToOne` son `EAGER` por defecto. Por eso se recomienda forzar `LAZY` explicitamente en los `@ManyToOne`, pero es redundante hacerlo en el `@OneToMany`.
- `mappedBy` no es una columna ni una tabla: solo le indica a Hibernate que ese lado es de solo lectura/navegacion, y que la relacion ya esta gestionada por el campo indicado del otro lado.
- Si se declara `@OneToMany` sin `mappedBy` y sin `@JoinColumn`, Hibernate crea una tabla intermedia extra (como si fuera `@ManyToMany`). Si se declara con `@JoinColumn` pero sin `mappedBy`, evita la tabla extra pero genera un `INSERT` seguido de un `UPDATE` separado para completar la FK, en vez de un unico `INSERT` completo.
- La relacion de JPA (anotaciones) y la constraint fisica de clave foranea en la base de datos son conceptos independientes: se puede mapear `@ManyToOne` sobre una columna que no tiene una `FOREIGN KEY` real a nivel de motor de base de datos.
- Si el proyecto usa `ddl-auto=none`, anotaciones como `@Table(uniqueConstraints = ...)` o `@Column(unique = true)` no tienen ningun efecto en la base real, ya que Hibernate no ejecuta DDL en ese modo.
