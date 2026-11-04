# Clase 06 - Tarea

## Objetivo
Aplicar query methods y JPQL para resolver búsquedas reales sobre productos en una API REST, siguiendo la misma lógica vista en clase.

## Consigna
En el proyecto actual, extendé la entidad `Product` con un campo `category` tipo `String` para poder practicar consultas por categoria y ordenamiento.

Tu tarea es completar la capa de acceso a datos y los endpoints necesarios para soportar las siguientes búsquedas:

1. Buscar productos por nombre, ignorando mayusculas y minusculas.
2. Buscar productos por categoria exacta.
3. Buscar productos por rango de precios.
4. Buscar productos por categoria y devolverlos ordenados por precio descendente.
5. Buscar productos por nombre usando un patrón con comodines.

## Requisitos

### 1) Repository
En `ProductRepository`, agregar al menos estos métodos:

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByNameContainingIgnoreCase(String name);

    List<Product> findByCategory(String category);

    List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);

    @Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.price DESC")
    List<Product> findByCategoryOrderByPriceDesc(@Param("category") String category);

    @Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<Product> searchByName(@Param("name") String name);
}
```

### 2) Controller
Agregar endpoints para consultar por:

- `GET /api/products/search?name=...`
- `GET /api/products/category?category=...`
- `GET /api/products/price-range?min=...&max=...`

Opcionalmente, podés agregar un endpoint para `GET /api/products/top-by-category?category=...` utilizando el método con `ORDER BY`.

### 3) Respuesta esperada
Los endpoints deben devolver una lista de productos en formato DTO, siguiendo la estructura ya usada en el proyecto.

### 4) Validaciones y prueba
Prueba los endpoints en Postman o Insomnia con datos reales cargados en H2. Verificar que:

- el filtro por nombre funciona aunque se escriba en mayusculas o minusculas
- el filtro por categoria devuelve solo productos de esa categoria
- el filtro por rango de precios respeta el min y max
- la consulta con `ORDER BY` devuelve los precios de mayor a menor
- el patrón con comodines devuelve coincidencias parciales

## Criterios de aceptacion
- El repository tiene al menos 3 query methods y 2 consultas JPQL.
- La clase se apoya en `Product` y sus atributos reales (`name`, `category`, `price`).
- La lógica de consulta no está mezclada en el controller.
- El acceso a datos está encapsulado en el repository.
- Se prueban los endpoints con datos reales y se revisa el orden de la respuesta.

## Desafío adicional
Agregar una consulta para contar cuántos productos hay por categoria:

```java
Long countByCategory(String category);
```

Esto te ayuda a entender que los query methods también sirven para métricas simples de negocio.

## Sugerencia de entrega
Documentá en una breve nota qué método elegiste en cada caso y por qué:
- query method para filtros sencillos
- JPQL para ordenamiento y reglas más complejas
- patrón con comodines para búsquedas de texto libres

Esto te permite demostrar que no estás usando la sintaxis a ciegas, sino que entendés el propósito de cada enfoque.
