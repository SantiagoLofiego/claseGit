# Clase 07 - Tarea

## Objetivo
- Aplicar el patron de paginacion, orden y filtro visto en clase (sobre `Product` filtrado por `category`) a un escenario mas cercano a un catalogo de e-commerce real: combinar varios filtros a la vez.
- Practicar la decision de como resolver filtros opcionales que pueden venir solos o combinados en la misma consulta.
- Reforzar que la paginacion y el filtrado no deben romper la separacion entidad/DTO ya establecida en el proyecto.

## Enunciado
En la actividad de clase se filtro el catalogo solo por `category`. Ahora tenes que extender `GET /api/products` para que soporte un catalogo de busqueda mas realista, combinando filtros.

### Requisitos
1. Extender `GET /api/products` para aceptar, ademas de `page`, `size` y `sort`, los siguientes query params opcionales:
   - `category` (opcional)
   - `minPrice` (opcional)
   - `maxPrice` (opcional)

   Ejemplo de uso:
   ```text
   GET /api/products?category=electronica&minPrice=1000&maxPrice=5000&page=0&size=10&sort=price,asc
   ```

2. Los filtros deben poder usarse solos o combinados. Casos a cubrir:
   - Sin ningun filtro (solo paginacion y orden).
   - Solo `category`.
   - Solo rango de precio (`minPrice`/`maxPrice`).
   - `category` + rango de precio juntos.

3. Resolver la consulta en `ProductRepository` usando JPQL con condiciones opcionales, siempre que:
   - La consulta siga recibiendo `Pageable` y devolviendo `Page<Product>`.
   - El filtrado no quede resuelto "a mano" dentro del controller (la logica de consulta pertenece al repository/service).

4. Mapear el resultado a `Page<ProductResponseDto>`, manteniendo la separacion entidad/DTO ya usada en el resto del proyecto.

## Entrega esperada
- Endpoint funcional y compilable, probado contra datos reales cargados en H2.
- Se prueban los 4 casos de filtro descriptos arriba (ninguno, solo categoria, solo rango de precio, ambos combinados).
- Se prueba ademas el orden ascendente y descendente por precio en al menos uno de los casos.

## Criterios de aceptacion
- Los filtros son combinables: funcionan solos o juntos, sin que uno rompa al otro.
- La paginacion y el orden siguen funcionando correctamente en conjunto con los filtros.
- La respuesta expone metadatos de pagina (`content`, `totalElements`, `totalPages`, `number`) sin exponer la entidad `Product` directamente.
- Se respeta la convencion por capas del curso: controller -> service -> dto -> repository.
