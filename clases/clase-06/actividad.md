# Clase 06 - Actividad en clase

## Contexto
- Ya tenemos `Product` persistido con JPA/Hibernate y un conjunto básico de endpoints funcionando.
- Para esta clase, asumimos que el producto incluye un campo `category` como `String` para que la consulta por categoria sea simple y didáctica.
- Hasta ahora conocemos `JpaRepository` y CRUD básico, pero aún no hemos explorado consultas más expresivas o más específicas.
- La necesidad de buscar productos por nombre, categoria o rango de precios aparece naturalmente en un backend de e-commerce.

```java
@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer stock;

    // getters y setters
}
```

> Para esta etapa del curso, `category` se define como `String` para mantener la clase enfocada en query methods y JPQL, sin sumar complejidad adicional de enum o validaciones de dominio.

## Objetivo de la actividad
- Comprender la diferencia entre query methods y JPQL.
- Ver como Spring Data reduce mucho trabajo para consultas simples.
- Entender cuando conviene una consulta derivada y cuando conviene escribir una query explícita.
- Introducir el concepto de que una consulta puede devolver entidades, filtros, ordenamiento y más control sobre la lectura.

## Consigna
1. Revisar el repository actual de `Product`:
   - `ProductRepository extends JpaRepository<Product, Long>`
2. Crear query methods sencillos para:
   - `findByNameContainingIgnoreCase(String name)`
   - `findByCategory(String category)`
   - `findByPriceBetween(BigDecimal min, BigDecimal max)`
3. Agregar una query JPQL con `@Query` para buscar productos por categoria ordenados por precio descendente:

```java
@Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);
```

4. Exponer un endpoint de búsqueda simple en el controller:
   - `GET /api/products/search?name=...`
   - `GET /api/products/category?category=...`
5. Probar los resultados en H2 a través de Postman/Insomnia y revisar que el orden o el filtro se estén aplicando correctamente.

## Preguntas orientadoras para la clase
- ¿Cuándo conviene usar un query method y cuándo conviene un `@Query` JPQL?
- ¿Qué diferencia hay entre `findByNameContainingIgnoreCase` y una query SQL clásica?
- ¿Por qué una consulta de tipo `JPQL` sigue hablando en términos de entidades Java y no de columnas de tabla?
- ¿Qué pasa si el filtro no existe o devuelve cero resultados?
- ¿Cómo se puede agregar ordenamiento a una consulta para hacer listados más útiles?

## Criterios de aceptacion
- Se entiende la diferencia entre `query method` y `JPQL`.
- El repository tiene al menos dos consultas derivadas y una JPQL.
- Se prueba el endpoint con filtros reales por nombre o categoria.
- El resultado se ordena correctamente cuando la consulta lo requiere.
- La clase deja claro que el objetivo no es memorizar una sintaxis, sino entender el patrón de consulta.

## Pistas para la clase
- `findBy...` funciona muy bien para condiciones simples y repetitivas.
- `@Query` es útil cuando la condición no se expresa bien con nombre de método o cuando se necesita más control.
- JPQL trabaja con entidades y propiedades Java (`Product`, `name`, `price`, `category`) y no con nombres de tabla SQL.
- El patrón de repositorio y controller hace que se puedan agregar filtros sin romper el diseño por capas.
