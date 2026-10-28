# Clase 04 - Resumen

## Objetivo de la clase
- Entender como una entidad JPA deja de ser aislada y pasa a formar parte de un modelo relacional real.
- Introducir relaciones entre entidades con `@OneToMany` y `@ManyToOne`.
- Mostrar que el lado "dueno" de la relacion define la clave foranea y, por lo tanto, el esquema fisico de la base.
- Dejar claro que la clase no se trata solo de anotaciones: se trata de modelar un negocio real (carrito + items) sin romper la API.

## Conceptos vistos
- Diferencia entre relacion unidireccional y bidireccional.
- `@OneToMany(mappedBy = "cart")` como lado de navegacion, no como propietario literal de la FK.
- `@ManyToOne` en `CartItem` como lado dueno, porque es quien declara `@JoinColumn` sobre `cart_id` y `product_id`.
- `cascade = CascadeType.ALL` y `orphanRemoval = true` como herramientas para mantener la consistencia del grafo de entidades.
- `fetch = FetchType.LAZY` para evitar cargar relaciones pesadas sin necesidad.
- Importancia de no serializar entidades JPA directamente: riesgo de referencias circulares entre `Cart` y `CartItem`.
- Uso de DTOs de salida (`CartResponseDto`, `CartItemResponseDto`) para preservar el contrato de API limpio.

## Demo realizada
- Se modeló `Cart` con una colección `items` y el metodo helper `addItem(CartItem item)`.
- Se modeló `CartItem` con dos relaciones `@ManyToOne`: una hacia `Cart` y otra hacia `Product`.
- Se explicó que `Cart` no agrega columnas a la tabla, porque la FK vive en `cart_items`.
- Se validó en H2 que la tabla `cart_items` cuenta con `cart_id` y `product_id`, mientras que `carts` no recibe columnas extra por la relacion.
- Se mostró la diferencia entre una relacion bidireccional (`Cart` <-> `CartItem`) y una unidireccional (`CartItem` -> `Product`).
- Se introdujo la idea de `@OneToOne` como cierre conceptual con `Customer` + `Address` y la restriccion `unique = true`.

## Mini entregable alcanzado
- Modelo de carrito funcional con relaciones persistidas en H2.
- Endpoint `POST /api/carts` para crear un carrito vacio.
- Endpoint `GET /api/carts/{id}` para consultar el carrito con sus items.
- Base para la tarea: agregar un producto al carrito a traves de `POST /api/carts/{cartId}/items`.
- Comprensión practica de por que la FK se declara en el lado `@ManyToOne` y no en el `@OneToMany`.

## Dudas frecuentes y aclaraciones
- ¿Por que `Cart` no tiene una columna `cart_id`? Porque la relacion se modela desde el lado hijo (`CartItem`), que es quien guarda la FK.
- ¿Para que sirve `mappedBy`? Para indicar que el otro lado de la relacion ya gestiona la base de datos; no genera una columna ni una tabla adicional.
- ¿Por que `CartItem` tiene dos `@ManyToOne`? Porque un item necesita apuntar a su carrito y a su producto.
- ¿Por que `Product` no conoce a `CartItem`? Porque no es necesario navegar desde producto hacia los carritos que lo contienen; eso agregaria acoplamiento innecesario.
- ¿Por que `@OneToOne` usa `unique = true`? Para garantizar que la FK sea unica y no se convierta en un `@ManyToOne` silencioso.

## Guion sugerido para la clase
- "La clase 03 nos enseño a persistir una entidad aislada. La clase 04 nos enseña a persistir una entidad dentro de un grafo de negocio real."
- "No todo se resuelve declarando anotaciones: hay que decidir quien tiene la FK, porque eso define la estructura real de la base."
- "Si un carrito tiene muchos items, entonces el item es el que guarda la referencia al carrito. Eso no es solo detalle tecnico: es la diferencia entre una tabla con columnas extra o una tabla con una FK bien ubicada."
- "La clave no es memorizar la anotacion exacta, sino entender el patron: entidad, relacion, DTO y decision de dominio."
- "La tarea de esta clase es aplicar la misma idea a un caso de uso nuevo: agregar productos a un carrito existente."
