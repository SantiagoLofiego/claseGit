# Clase 06 - Resumen

## Objetivo
Aprender a consultar datos con Spring Data JPA usando query methods, JPQL y un criterio para decidir cuándo conviene cada enfoque.

## Qué vimos
- `JpaRepository` ya nos da CRUD básico, pero no resuelve consultas del negocio.
- Los query methods permiten expresar condiciones simples y legibles con el nombre del método.
- `@Query` con JPQL permite consultas más expresivas y con mayor control sobre ordenamiento, filtros y composición.
- El concepto clave es que JPQL habla en términos de entidades Java (`Product`, `p.name`, `p.price`), no en tablas SQL.
- La diferencia entre query method y JPQL es principalmente de complejidad y claridad: para condiciones simples conviene query method; para control y orden, JPQL.
- SQL nativo existe como alternativa cuando el problema requiere algo muy específico de la base o una consulta que no se expresa bien de otra forma.

## Ejemplos vistos

### Query method
```java
List<Product> findByNameContainingIgnoreCase(String name);
List<Product> findByCategory(String category);
List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);
List<Product> findByCategoryOrderByPriceDesc(String category);
```

### JPQL
```java
@Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);
```

### SQL nativo
```sql
SELECT *
FROM products
WHERE category = :category
ORDER BY price DESC;
```

## Concepto importante
Cuando el filtro es claro y directo, el nombre del método es suficiente. Cuando la consulta requiere más control o más lógica, la consulta explícita con JPQL es más clara y más mantenible.

## Cierre de la clase
La clase 06 deja preparado el camino para la clase 07, donde se profundiza en paginación, sorting y filtros avanzados, pero con el mismo patrón de diseño: repository para lectura, controller como acceso HTTP y servicios encapsulando la lógica de negocio.
