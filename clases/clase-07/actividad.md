# Clase 07 - Actividad en clase

## Contexto
- Hoy `GET /api/products` devuelve una `List<Product>` completa. Funciona con pocos datos, pero no escala: a medida que crece el catalogo, devolver todo en una sola respuesta se vuelve lento e inutil para el cliente que consume la API.
- Spring Data ya tiene soporte nativo para paginacion y orden a traves de `Pageable`, `PageRequest`, `Page<T>` y `Sort`, sin necesidad de reinventar nada.
- Esta clase retoma el patron de consultas visto en clase 06 (query methods y JPQL), pero agregando paginacion y orden como parte de la consulta.

## Objetivo de la actividad
- Entender por que un listado sin paginar no escala en una API real.
- Aprender a exponer un endpoint paginado usando `Pageable` y `Page<T>`.
- Aprender a combinar paginacion con un filtro simple (`category`).
- Entender como se traduce `page`, `size` y `sort` desde query params HTTP hacia `Pageable`.

## Consigna
1. Revisar el repository actual de `Product` y agregar un metodo que reciba `Pageable`:

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    Page<Product> findByCategory(String category, Pageable pageable);
}
```

2. Modificar el controller para que `GET /api/products` acepte un `Pageable` resuelto automaticamente por Spring a partir de los query params `page`, `size` y `sort`:

```java
@GetMapping
public Page<ProductResponseDto> listProducts(
        @RequestParam(required = false) String category,
        Pageable pageable) {

    Page<Product> products = (category != null)
            ? productRepository.findByCategory(category, pageable)
            : productRepository.findAll(pageable);

    return products.map(ProductMapper::toResponseDto);
}
```

3. Probar en Postman/Insomnia distintas combinaciones:
   - `GET /api/products?page=0&size=5`
   - `GET /api/products?page=0&size=5&sort=price,desc`
   - `GET /api/products?category=electronica&page=0&size=5&sort=price,asc`

4. Observar la estructura de la respuesta `Page<T>` y revisar en clase los campos:
   - `content`: los elementos de la pagina actual.
   - `totalElements`: cantidad total de elementos en toda la consulta.
   - `totalPages`: cantidad total de paginas.
   - `number`: numero de pagina actual (0-indexed).

## Preguntas orientadoras para la clase
- ¿Que problema practico resuelve la paginacion que no resuelve un `List<T>` comun?
- ¿Como traduce Spring los query params `page`, `size` y `sort` en un objeto `Pageable`?
- ¿Que pasa si se pide una pagina que no existe (por ejemplo, `page=50` con pocos datos)?
- ¿Por que conviene devolver `Page<ProductResponseDto>` y no `Page<Product>` directamente?

## Criterios de aceptacion
- El endpoint `GET /api/products` responde con un `Page<ProductResponseDto>`, no con una lista plana.
- La paginacion funciona correctamente con distintos valores de `page` y `size`.
- El orden (`sort`) se aplica correctamente sobre al menos un campo (por ejemplo, `price`).
- El filtro por `category` sigue funcionando en conjunto con la paginacion.
- Se entiende que el objetivo es el patron (Pageable + Page + Sort), no memorizar la sintaxis de memoria.

## Pistas para la clase
- `Pageable` como parametro de un metodo de controller es resuelto automaticamente por Spring si no se usan tipos custom.
- `Page<T>` ya incluye el mapeo de metadatos de paginacion, no hace falta calcularlos a mano.
- `Page<T>.map()` permite transformar `Page<Product>` en `Page<ProductResponseDto>` sin perder los metadatos de paginacion.
- El orden por multiples campos se expresa como `sort=campo1,direccion&sort=campo2,direccion`.
