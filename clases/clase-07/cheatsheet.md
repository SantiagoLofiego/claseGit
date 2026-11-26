# Clase 07 - Cheatsheet

## `Pageable`, `Page<T>` y `Sort`
- Vienen de `org.springframework.data.domain` (ya incluido con `spring-boot-starter-data-jpa`, no hace falta agregar dependencias nuevas).
- `Pageable`: describe que pagina pedir (numero de pagina, tamano y orden).
- `Page<T>`: resultado paginado, incluye el contenido y metadatos (`totalElements`, `totalPages`, `number`, etc.).
- `Sort`: describe el orden de la consulta (puede venir incluido dentro del `Pageable`).

## Query method con paginacion
Un query method puede recibir `Pageable` como parametro extra y devolver `Page<T>` en lugar de `List<T>`:

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    Page<Product> findByCategory(String category, Pageable pageable);
}
```

## `Pageable` como parametro de controller
Spring resuelve automaticamente un `Pageable` a partir de los query params `page`, `size` y `sort` si se lo pedis como parametro del metodo:

```java
@GetMapping
public Page<ProductResponseDto> listProducts(Pageable pageable) {
    Page<Product> products = productRepository.findAll(pageable);
    return products.map(ProductMapper::toResponseDto);
}
```

Query params de ejemplo para probar en Postman/Insomnia:
- `GET /api/products?page=0&size=10`
- `GET /api/products?page=0&size=10&sort=price,desc`
- Multiples campos de orden: `?sort=category,asc&sort=price,desc`

## JPQL con `Pageable`
El mismo `@Query` visto en clase 06 puede recibir `Pageable` sin cambiar su forma:

```java
@Query("SELECT p FROM Product p WHERE p.category = :category")
Page<Product> findByCategory(@Param("category") String category, Pageable pageable);
```

## Patron: filtros opcionales combinados en JPQL
Cuando un filtro puede venir o no en la consulta (es opcional), una forma comun de resolverlo en JPQL es comparar el parametro contra `NULL` para "desactivar" esa condicion cuando no se envia:

```java
@Query("""
    SELECT e FROM Entity e
    WHERE (:filtroA IS NULL OR e.campoA = :filtroA)
      AND (:filtroB IS NULL OR e.campoB >= :filtroB)
    """)
Page<Entity> buscarConFiltrosOpcionales(
        @Param("filtroA") String filtroA,
        @Param("filtroB") BigDecimal filtroB,
        Pageable pageable);
```

- Cada condicion se "apaga" sola cuando su parametro llega en `null` desde el controller (por ejemplo, un `@RequestParam(required = false)` que no se envio).
- El mismo patron se puede repetir y encadenar con `AND` para combinar tantos filtros opcionales como haga falta.
- Este es el patron general: adaptalo a los campos y tipos concretos que necesites resolver en tu caso.

## Mapear `Page<Entity>` a `Page<Dto>`
`Page<T>` tiene su propio `.map()`, que transforma el contenido sin perder los metadatos de paginacion:

```java
Page<ProductResponseDto> dtoPage = productPage.map(ProductMapper::toResponseDto);
```

## Recordatorio de query params HTTP
- `page`: numero de pagina, arranca en `0`.
- `size`: cantidad de elementos por pagina.
- `sort`: `campo,asc` o `campo,desc` (se puede repetir para ordenar por mas de un campo).
- Los filtros propios (por ejemplo, `category`, rango de precio, etc.) se agregan como query params adicionales y se resuelven con `@RequestParam(required = false)` en el controller.
