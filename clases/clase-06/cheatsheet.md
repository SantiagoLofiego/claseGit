# Clase 06 - Cheatsheet

## 1) Patron general de un query method

La sintaxis mas frecuente es:

```java
List<Product> findByCampoCondicion(...);
```

Ejemplos:

```java
List<Product> findByCategory(String category);
List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);
List<Product> findByNameContainingIgnoreCase(String name);
List<Product> findByCategoryOrderByPriceDesc(String category);
```

La idea es que Spring Data toma el nombre del método y lo convierte en una consulta JPQL.

## 2) Palabras clave comunes en query methods

A continuacion, una referencia rápida de las mas usadas.

| Keyword | Ejemplo | Significado |
|---|---|---|
| `And` | `findByCategoryAndPriceLessThan(...)` | Combina dos condiciones. |
| `Or` | `findByCategoryOrNameContaining(...)` | Evalúa una u otra condición. |
| `Is` / `Equals` | `findByCategoryIs(...)` o `findByCategoryEquals(...)` | Igualdad exacta. |
| `Not` | `findByStockNot(...)` | Negación de una condición. |
| `Between` | `findByPriceBetween(...)` | Busca dentro de un rango. |
| `LessThan` | `findByPriceLessThan(...)` | Menor que un valor. |
| `LessThanEqual` | `findByPriceLessThanEqual(...)` | Menor o igual que un valor. |
| `GreaterThan` | `findByStockGreaterThan(...)` | Mayor que un valor. |
| `GreaterThanEqual` | `findByStockGreaterThanEqual(...)` | Mayor o igual que un valor. |
| `Like` | `findByNameLike(...)` | Busca con wildcard. |
| `Containing` | `findByNameContaining(...)` | Contiene texto. |
| `StartingWith` | `findByNameStartingWith(...)` | Empieza con texto. |
| `EndingWith` | `findByNameEndingWith(...)` | Termina con texto. |
| `IgnoreCase` | `findByNameContainingIgnoreCase(...)` | Ignora mayusculas/minusculas. |
| `In` | `findByCategoryIn(...)` | Busca dentro de una lista de valores. |
| `NotIn` | `findByCategoryNotIn(...)` | Excluye una lista de valores. |
| `IsNull` | `findByCategoryIsNull()` | El campo es nulo. |
| `IsNotNull` | `findByCategoryIsNotNull()` | El campo tiene valor. |
| `True` | `findByActiveTrue()` | Campo booleano con valor `true`. |
| `False` | `findByActiveFalse()` | Campo booleano con valor `false`. |
| `OrderBy` | `findByCategoryOrderByPriceDesc(...)` | Ordena el resultado. |
| `Asc` | `findByCategoryOrderByPriceAsc(...)` | Orden ascendente. |
| `Desc` | `findByCategoryOrderByPriceDesc(...)` | Orden descendente. |
| `Count` | `countByCategory(...)` | Cuenta registros. |
| `Exists` | `existsByName(...)` | Verifica si existe al menos un registro. |
| `Distinct` | `findDistinctByCategory(...)` | Elimina duplicados. |
| `First` / `Top` | `findFirstByCategoryOrderByPriceDesc(...)` | Trae solo el primero o los primeros. |

## 3) Ejemplos practicos con Product

### a) Comparacion por nombre
```java
List<Product> findByNameContainingIgnoreCase(String name);
```

```java
@Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :name, '%'))")
List<Product> searchByName(@Param("name") String name);
```

### b) Filtro por categoria y orden
```java
List<Product> findByCategoryOrderByPriceDesc(String category);
```

```java
@Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);
```

### c) Filtro por rango de precios
```java
List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);
```

```java
@Query("SELECT p FROM Product p WHERE p.price BETWEEN :min AND :max")
List<Product> findProductsByPriceRange(@Param("min") BigDecimal min, @Param("max") BigDecimal max);
```

### d) Wildcards con `Like`
```java
List<Product> findByNameLike(String pattern);
```

Uso comun:

```java
List<Product> products = productRepository.findByNameLike("%mac%");
```

Esto devuelve productos cuyo nombre contiene `mac` en cualquier lugar.

### e) `Count` y metricas simples
```java
Long countByCategory(String category);
```

Ejemplo de uso:

```java
Long total = productRepository.countByCategory("electronics");
```

## 4) Query methods que conviene recordar por nombre

Estas son algunas de las mas usadas en backend y e-commerce:

```java
List<Product> findByName(String name);
List<Product> findByNameContaining(String text);
List<Product> findByNameStartingWith(String prefix);
List<Product> findByNameEndingWith(String suffix);
List<Product> findByCategory(String category);
List<Product> findByCategoryAndPriceLessThan(String category, BigDecimal price);
List<Product> findByCategoryOrNameContaining(String category, String text);
List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);
List<Product> findByStockGreaterThan(Integer stock);
List<Product> findByStockLessThanEqual(Integer stock);
List<Product> findByCategoryIn(List<String> categories);
List<Product> findByCategoryIsNull();
List<Product> findByCategoryIsNotNull();
List<Product> findByStockNot(Integer stock);
Long countByCategory(String category);
```

## 5) Diferencia clave: query methods vs JPQL vs SQL nativo

### Query method
```java
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

### Entonces ...
- Query method = Spring deduce la consulta por el nombre del metodo.
- JPQL = nosotros escribimos la consulta usando entidades y propiedades Java.
- SQL nativo = escribimos la consulta sobre la tabla real y columnas de la base.

## 6) Regla de oro 
- Si la condicion es simple, usa query methods.
- Si necesitas orden, joins, condiciones mas complejas o mas control, usa JPQL.
- Solo usa SQL nativo cuando realmente necesitas algo especifico de la base o no existe una buena alternativa con JPQL.

## 7) Ejemplo de combinacion recomendada

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByNameContainingIgnoreCase(String name);
    List<Product> findByCategory(String category);
    List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);
    List<Product> findByCategoryOrderByPriceDesc(String category);
    List<Product> findByCategoryIsNotNull();
    Long countByCategory(String category);

    @Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
    List<Product> findByCategoryOrderByPriceDescQuery(@Param("category") String category);
}
```

Esto deja muy claro que en una API real se mezclan ambos enfoques: query methods para lo simple, JPQL para lo que necesita mayor control.


