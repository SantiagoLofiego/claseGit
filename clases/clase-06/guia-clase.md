# Clase 06 - Guia base para explicar la clase

## Objetivo de la clase
- Introducir consultas de datos en Spring Data JPA.
- Mostrar la diferencia entre query methods y consultas JPQL.
- Entender que la capa de repositorio puede encapsular la mayor parte de la lógica de lectura sin mezclar SQL en el servicio.
- Dejar preparado el terreno para la clase 07, donde se verá paginación, sorting y filtros avanzados.

## Agenda sugerida
1. Recordatorio breve de la clase 05
2. Qué es un repository y qué puede hacer por nosotros
3. Query methods: `findBy...`, `Containing`, `IgnoreCase`, `Between`
4. JPQL con `@Query`
5. Demo en vivo con `ProductRepository`
6. Endpoint de búsqueda simple
7. Cierre y dudas

## 1) Recordatorio de la clase anterior
- La clase 05 se centró en manejar errores y respuestas uniformes.
- La API ya no solo responde con éxito; ahora también sabe fallar de forma consistente.
- El siguiente paso es hacer que la lectura de datos también sea más expresiva y más útil para el dominio del negocio.

Frase guia para la clase:

> "La clase 05 nos enseñó a fallar bien. La clase 06 nos enseña a consultar bien."

## 2) ¿Por qué aparecen las consultas ahora?
Hasta la clase 05, el proyecto estaba centrado en CRUD básico y validaciones. Eso sirve para empezar, pero no alcanza para un e-commerce real.

Necesitamos preguntarle a la base cosas como:
- ¿qué productos tienen este nombre?
- ¿qué productos pertenecen a esta categoria?
- ¿qué productos tienen precio entre dos valores?

Para esta clase, asumimos que `Product` incluye `category` como `String`, de forma simple y clara para explicar consultas y filtros. Si en una etapa posterior se vuelve un catálogo controlado, ese campo puede evolucionar a `enum`.

Eso exige una capa de consultas más flexible que `findAll()` y `findById()`.

## 3) Query methods
Spring Data JPA permite crear consultas derivadas a partir del nombre del método. Eso reduce mucho código y hace que la intención quede muy clara.

### Ejemplo sencillo
```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByNameContainingIgnoreCase(String name);

    List<Product> findByCategory(String category);

    List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);

    List<Product> findByCategoryOrderByPriceDesc(String category);

    List<Product> findByNameLike(String pattern);
}
```

### Qué están haciendo estas consultas
- `findByNameContainingIgnoreCase`: busca productos cuyos nombres contienen texto, sin distinguir mayusculas/minusculas.
- `findByCategory`: trae todos los productos de una categoria exacta.
- `findByPriceBetween`: trae productos dentro de un rango de precios.
- `findByCategoryOrderByPriceDesc`: primero filtra por categoria y luego ordena por precio descendente.
- `findByNameLike`: busca por coincidencias con comodines tipo SQL, por ejemplo `%mac%`, `mac%` o `%mac`.

### Orden de la sintaxis de query methods
La estructura general suele ser:

```java
findBy<Property>(...)
findBy<Property>And<Property>(...)
findBy<Property>Or<Property>(...)
findBy<Property>Between(...)
findBy<Property>LessThan(...)
findBy<Property>GreaterThan(...)
findBy<Property>Like(...)
findBy<Property>OrderBy<Property>Asc/Desc(...)
```

Ejemplo con orden:

```java
List<Product> findByCategoryOrderByPriceDesc(String category);
List<Product> findByPriceBetweenOrderByNameAsc(BigDecimal min, BigDecimal max);
```

La idea es que Spring interpreta la frase como una condicion y, si se agrega `OrderBy`, aplica un orden final al resultado.

### Ejemplo con like y wildcards
`Like` es útil cuando queremos buscar con comodines.

```java
List<Product> findByNameLike(String pattern);
```

Al invocar el método, normalmente usamos patrones con `%`:

```java
List<Product> products = productRepository.findByNameLike("%mac%")
```

Esto devuelve productos cuyo nombre contiene "mac" en cualquier parte.

Otros ejemplos comunes:

```java
List<Product> findByNameStartingWith(String prefix);   // "mac%"
List<Product> findByNameEndingWith(String suffix);     // "%mac"
List<Product> findByNameContaining(String text);        // "%text%"
```

> En la practica, `Containing` suele ser mas legible que `Like` para consultas de texto de negocio, pero `Like` es importante porque permite entender el concepto de wildcard y la sintaxis con `%`.

### Panorama general de palabras clave frecuentes
Algunas de las palabras clave más útiles de Spring Data JPA son:

- `And`, `Or`: combinar condiciones
- `Between`: rango
- `LessThan`, `GreaterThan`: comparaciones numericas
- `Like`, `Containing`, `StartingWith`, `EndingWith`: texto y wildcard
- `IgnoreCase`: comparar sin distinguir mayusculas/minusculas
- `In`: lista de valores
- `OrderBy`: ordenar resultados
- `Null`, `NotNull`: campos con valor nulo o no nulo
- `Not`: negacion de un criterio
- `Count`: contar resultados

Ejemplos:

```java
List<Product> findByCategoryAndPriceLessThan(String category, BigDecimal price);
List<Product> findByCategoryOrNameContaining(String category, String text);
List<Product> findByStockGreaterThan(Integer stock);
List<Product> findByNameContainingIgnoreCase(String name);
List<Product> findByCategoryIn(List<String> categories);
List<Product> findByCategoryIsNull();
List<Product> findByCategoryIsNotNull();
List<Product> findByStockNot(Integer stock);
Long countByCategory(String category);
```

### Qué significan estos ejemplos
- `findByCategoryIsNull()`: trae los productos cuya categoria no tiene valor asignado.
- `findByCategoryIsNotNull()`: trae productos que sí tienen categoria.
- `findByStockNot(Integer stock)`: busca productos cuyo stock no sea exactamente ese valor.
- `countByCategory(String category)`: devuelve cuántos productos hay en una categoría determinada.

### Cuándo conviene usarlos
Cuando la consulta es simple y el nombre del método refleja claramente la intención del negocio. Es una excelente opcion para filtros basicos y legibles.

## 4) JPQL con `@Query`
Cuando la consulta es más compleja o cuando se necesita mayor control, aparece `@Query` con JPQL.

### Ejemplo básico
```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
    List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);
}
```

### Qué significa esto
- `SELECT p FROM Product p`: se selecciona la entidad `Product`, no una columna SQL.
- `WHERE p.category = :category`: filtra por una propiedad de la entidad.
- `ORDER BY p.price DESC`: ordena los resultados por precio.

### Parametros por nombre y parametros posicionales
En JPQL, normalmente se usan parametros con nombre:

```java
@Query("SELECT p FROM Product p WHERE p.category = :category")
List<Product> findByCategory(@Param("category") String category);
```

Pero también es posible usar parametros posicionales con `?1`, `?2`, etc., sin `@Param`:

```java
@Query("SELECT p FROM Product p WHERE p.category = ?1 AND p.price >= ?2 ORDER BY p.price DESC")
List<Product> findByCategoryAndPriceGreaterThanEqual(String category, BigDecimal minPrice);
```

Esto permite ver otra sintaxis valida y ayuda a entender que hay varias maneras de pasar argumentos, aunque la version con nombre suele ser más legible y mantenible.

### Diferencia clave con SQL nativo
JPQL habla en términos de clases y propiedades Java, no en nombres de tabla físicos. Por ejemplo:
- `Product` en lugar de `products`
- `p.category` en lugar de `category`
- `p.price` en lugar de `price`

Esto hace que la consulta se mantenga más cercana al dominio y más portable.

### Ejemplos de JPQL comparados con query methods

#### 1. Búsqueda por nombre
Query method:
```java
List<Product> findByNameContainingIgnoreCase(String name);
```

JPQL equivalente:
```java
@Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :name, '%'))")
List<Product> searchByName(@Param("name") String name);
```

SQL nativo equivalente:
```sql
SELECT *
FROM products
WHERE LOWER(name) LIKE LOWER(CONCAT('%', :name, '%'));
```

#### 2. Búsqueda por categoria ordenada
Query method:
```java
List<Product> findByCategoryOrderByPriceDesc(String category);
```

JPQL equivalente:
```java
@Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);
```

SQL nativo equivalente:
```sql
SELECT *
FROM products
WHERE category = :category
ORDER BY price DESC;
```

#### 3. Rango de precios
Query method:
```java
List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);
```

JPQL equivalente:
```java
@Query("SELECT p FROM Product p WHERE p.price BETWEEN :min AND :max")
List<Product> findProductsByPriceRange(@Param("min") BigDecimal min, @Param("max") BigDecimal max);
```

SQL nativo equivalente:
```sql
SELECT *
FROM products
WHERE price BETWEEN :min AND :max;
```

### Observación clave para la clase
- En query methods, Spring escribe la consulta por nosotros a partir del nombre del método.
- En JPQL, nosotros decimos explícitamente qué queremos traer con `SELECT ... FROM Product ... WHERE ...`.
- En SQL nativo, hablamos directamente con la tabla y las columnas reales de la base (`products`, `name`, `price`).

## 5) Query methods vs JPQL

### Query method
```java
List<Product> findByNameContainingIgnoreCase(String name);
```

Ventajas:
- muy corto
- muy legible
- ideal para condiciones simples

Limitaciones:
- no sirve para consultas muy complejas
- a veces se vuelve difícil de leer si la lógica es grande

### JPQL
```java
@Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);
```

Ventajas:
- más control
- útil para ordenamiento, joins y filtros más específicos
- muy claro para condiciones complejas

Limitaciones:
- requiere escribir la consulta explícitamente
- exige entender mejor el lenguaje JPQL

## 6) Integracion con el controller
Una vez que el repository expone la consulta, el controller solo expone la request y delega al service.

### Ejemplo de controller
```java
@GetMapping("/products/search")
public ResponseEntity<List<ProductResponseDto>> searchProducts(@RequestParam(required = false) String name) {
    List<Product> products = productRepository.findByNameContainingIgnoreCase(name);
    return ResponseEntity.ok(productService.mapToDto(products));
}
```

### Ejemplo de categoria
```java
@GetMapping("/products/category")
public ResponseEntity<List<ProductResponseDto>> getByCategory(@RequestParam String category) {
    List<Product> products = productRepository.findByCategoryOrderByPriceDesc(category);
    return ResponseEntity.ok(productService.mapToDto(products));
}
```

## 7) Buenas prácticas en esta etapa
- Usar query methods para consultas simples y claras.
- Usar JPQL cuando la consulta necesita más control o ordenamiento.
- Mantener el repository como la capa de acceso a datos.
- No meter lógica SQL en el controller ni en el service.
- Mantener la separación por capas aunque la consulta se haga en una sola línea.

## 8) Demo en vivo sugerida
1. Mostrar el repository con `findByNameContainingIgnoreCase`.
2. Mostrar `findByCategory` y `findByPriceBetween`.
3. Mostrar una query JPQL con `ORDER BY`.
4. Invocar los endpoints desde Postman.
5. Explicar por qué cada método se usa según la complejidad de la consulta.
6. Cerrar con: "con Spring Data, la consulta sigue siendo parte del dominio, no de la infraestructura."

## 9) Cierre y dudas
Frase final sugerida:

> "No hace falta escribir SQL a mano para empezar a consultar bien. Spring Data nos permite expresar la intención de la consulta en el idioma del dominio, y JPQL nos da más control cuando la consulta ya no es trivial."

Dudas comunes:
- ¿Query method o JPQL? Si la consulta sale de una palabra clave clara, query method. Si requiere orden, joins o mayor control, JPQL.
- ¿Qué pasa si el nombre del método no expresa bien la consulta? Entonces conviene usar `@Query`.
- ¿JPQL reemplaza SQL? No, es una capa orientada a entidades; es más expresiva para Java y JPA.
- ¿Se puede combinar todo? Sí, y lo normal es hacerlo: métodos simples con query methods, consultas complejas con JPQL.
