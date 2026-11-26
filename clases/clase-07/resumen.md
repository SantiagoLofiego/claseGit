# Clase 07 - Resumen

## Objetivo
Aprender a exponer listados escalables en una API REST usando paginacion, orden y filtros, en lugar de devolver listas completas sin control de volumen.

## Que vimos
- Devolver un `List<T>` completo funciona con pocos datos, pero no escala cuando el catalogo crece: hay que paginar la respuesta.
- Spring Data ya resuelve esto con `Pageable`, `PageRequest`, `Sort` y `Page<T>`, sin necesidad de calcular nada manualmente.
- Un query method o una consulta JPQL pueden recibir `Pageable` como parametro extra y devolver `Page<T>` en lugar de `List<T>`.
- Si el controller pide un `Pageable` como parametro, Spring lo resuelve automaticamente a partir de los query params HTTP `page`, `size` y `sort`.
- `Page<T>` no solo trae el contenido de la pagina actual: tambien trae metadatos utiles como `totalElements`, `totalPages` y `number`.
- `Page<T>.map()` permite transformar `Page<Entity>` en `Page<Dto>` sin perder esos metadatos, manteniendo la separacion entidad/DTO ya usada en el proyecto.

## Ejemplo visto en clase

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    Page<Product> findByCategory(String category, Pageable pageable);
}
```

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

## Concepto importante
Paginar no es solo "cortar" la lista en pedazos: es un contrato de API que informa cuantos elementos hay en total y en que pagina esta parado el cliente. Combinar esto con filtros (por ejemplo, `category`) permite construir listados que siguen siendo utiles aunque el catalogo crezca mucho.

## Cierre de la clase
La clase 07 deja el patron de paginacion y filtro simple resuelto sobre `Product`. La tarea extiende este mismo patron a un caso con filtros combinables (categoria + rango de precio), preparando el terreno para pensar, mas adelante, en listados con criterios de busqueda cada vez mas ricos.
