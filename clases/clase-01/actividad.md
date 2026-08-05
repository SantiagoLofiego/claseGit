# Clase 01 - Actividad en clase

## Contexto
- El equipo construye un backend de e-commerce de forma incremental.
- En esta clase todavia no se usa JPA ni base de datos.
- El objetivo es que el grupo implemente la primera vertical completa desde cero.

## Consigna
- Implementar el recurso Product con datos en memoria y separacion por capas.
- Crear desde cero las capas y clases necesarias:
	- model/Product
	- dto/ProductRequestDto
	- dto/ProductResponseDto
	- service/ProductService
	- controller/ProductController
- Crear los endpoints:
	- GET /api/products
	- GET /api/products/{id}
	- POST /api/products
- Si el tiempo alcanza, sumar un endpoint de update de stock.
- Usar DTOs para request y response.
- Agregar una validacion basica manual en service: precio > 0 y stock >= 0.

## Componentes a crear y campos sugeridos
### model/Product
- id: Long
- name: String
- description: String
- price: BigDecimal
- stock: Integer

### dto/ProductRequestDto
- name: String
- description: String
- price: BigDecimal
- stock: Integer

### dto/ProductResponseDto
- id: Long
- name: String
- description: String
- price: BigDecimal
- stock: Integer

### dto/ProductStockUpdateDto
- quantity: Integer  // cantidad a sumar al stock existente
- Nota: el producto se identifica por el {id} en la URL, no en el cuerpo del request.
  Ejemplo de request: PATCH /api/products/3/stock con body { "quantity": 10 }
  Si el stock actual es 15, el resultado sera 25.

### service/ProductService
- Lista interna en memoria de Product.
- Secuencia simple para generar ids.
- Metodos sugeridos:
	- findAll()
	- findById(Long id)
	- create(ProductRequestDto dto)
	- addStock(Long id, Integer quantity)  // producto.setStock(producto.getStock() + quantity)  // busca el producto por id y asigna el nuevo stock

### controller/ProductController
- GET /api/products
- GET /api/products/{id}
- POST /api/products
- PATCH /api/products/{id}/stock (opcional)
  // el {id} del path se recibe con @PathVariable, el stock con @RequestBody ProductStockUpdateDto

## Criterios de aceptacion
- Endpoint(s) funcionando.
- Codigo compila sin errores.
- Se prueba al menos un caso feliz.
- Se prueba al menos un caso invalido (precio negativo o stock negativo).
- Controller sin logica de negocio compleja.

## Pistas
- Mantener lista en memoria dentro del service.
- Generar id incremental simple en service.
- Devolver 201 en alta exitosa.
- Separar el mapeo entre DTO y model en el service o en una clase auxiliar simple.
