# Clase 04 - Cheatsheet


## Anotaciones de relacion: cuando usar cada una

| Anotacion | Cardinalidad | Fetch por defecto | Quien suele ser el dueno |
|---|---|---|---|
| `@OneToMany` | "Uno" visto desde el lado que tiene la coleccion | `LAZY` | No es el dueno (se usa `mappedBy`) |
| `@ManyToOne` | "Muchos" visto desde el lado que tiene la FK | `EAGER` | Si (tiene el `@JoinColumn`) |
| `@OneToOne` | Uno a uno | `EAGER` | El lado que declara `@JoinColumn` (con `unique = true`) |
| `@ManyToMany` | Muchos a muchos | `LAZY` | No se usa en este curso (ver nota abajo) |

> Nota: en este curso evitamos `@ManyToMany` directo y preferimos una entidad intermedia explicita (como `CartItem`), para poder agregarle atributos propios a la relacion (`quantity`, por ejemplo).

## Opciones de `@OneToMany`

| Opcion | Para que sirve |
|---|---|
| `mappedBy = "campo"` | Indica que este lado NO es el dueno: la relacion ya esta gestionada por el campo indicado del otro lado (ese campo tiene el `@JoinColumn`). No genera ninguna columna ni tabla propia. |
| `cascade = CascadeType.X` | Propaga operaciones del ciclo de vida (ver tabla de `CascadeType` mas abajo) desde esta entidad hacia las entidades relacionadas. |
| `orphanRemoval = true/false` | Si un elemento se saca de la coleccion, se borra de la base de datos (no queda "huerfano" sin padre). |
| `fetch = FetchType.X` | Redundante en `@OneToMany` salvo que se quiera dejarlo explicito: el default ya es `LAZY`. |

## Opciones de `@ManyToOne` / `@OneToOne`

| Opcion | Para que sirve |
|---|---|
| `fetch = FetchType.LAZY` | Fuerza carga diferida; se recomienda siempre, porque el default de estas dos anotaciones es `EAGER`. |
| `optional = true/false` | Indica si la relacion puede ser nula (`true` por defecto). Alternativa/complemento a `nullable` en `@JoinColumn`. |

## Opciones de `@JoinColumn`

| Opcion | Para que sirve |
|---|---|
| `name = "columna"` | Nombre de la columna FK fisica en la tabla de este lado. |
| `nullable = true/false` | Si la columna admite nulos. En relaciones obligatorias (como `CartItem -> Cart`) se usa `false`. |
| `unique = true/false` | Agrega una constraint de unicidad sobre la columna FK. Es la opcion clave que distingue un `@OneToOne` real de un `@ManyToOne` (sin `unique = true`, varias filas podrian compartir la misma FK). |

## `CascadeType`: valores disponibles

| Valor | Que propaga |
|---|---|
| `PERSIST` | Al guardar la entidad padre, tambien guarda las entidades relacionadas nuevas. |
| `MERGE` | Al actualizar la entidad padre, tambien actualiza las entidades relacionadas. |
| `REMOVE` | Al borrar la entidad padre, tambien borra las entidades relacionadas. |
| `REFRESH` | Al refrescar la entidad padre desde la base, tambien refresca las relacionadas. |
| `DETACH` | Al desvincular la entidad padre del contexto de persistencia, tambien desvincula las relacionadas. |
| `ALL` | Aplica los cinco anteriores. Es la que usamos en `Cart.items`. |

## `FetchType`: valores disponibles

| Valor | Comportamiento |
|---|---|
| `LAZY` | Hibernate no trae la entidad/coleccion relacionada hasta que se accede explicitamente a ella (usa un proxy). |
| `EAGER` | Hibernate trae la entidad/coleccion relacionada inmediatamente, en la misma consulta o en una adicional automatica. |

## Patron ya resuelto en clase: metodo helper para relaciones bidireccionales

Cuando la relacion es bidireccional (como `Cart` <-> `CartItem`), hay que sincronizar ambos lados manualmente. El patron general (ya aplicado a `Cart` en la actividad) es:

```java
public void addItem(CartItem item) {
    items.add(item);      // lado de navegacion (coleccion, mappedBy)
    item.setCart(this);   // lado dueno (el que realmente define la FK en la base)
}
```

Usar siempre este tipo de metodo al agregar un elemento a una coleccion `@OneToMany`, en vez de manipular la lista directamente con `getItems().add(...)`.

## Bean Validation (repaso de clase 02) para el DTO de entrada

| Anotacion | Para que sirve |
|---|---|
| `@NotNull` | El campo no puede ser nulo. Util para `productId`. |
| `@Positive` / `@Min(1)` | El valor numerico debe ser mayor a cero. Util para `quantity`. |
| `@Valid` | Se coloca en el parametro del controller para que Spring dispare las validaciones del DTO antes de llegar al service. |

## Repositorios disponibles (de la actividad, no hay que crear nada nuevo)

- `CartRepository extends JpaRepository<Cart, Long>` -> `findById(Long id)`.
- `ProductRepository` (ya existente desde la clase 03) -> `findById(Long id)`.

No hace falta crear un `CartItemRepository`: el guardado de `CartItem` se resuelve siempre a traves de `cartRepository.save(cart)`, gracias al `cascade = CascadeType.ALL` ya configurado en `Cart.items`.
