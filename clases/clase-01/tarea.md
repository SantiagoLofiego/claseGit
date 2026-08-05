# Clase 01 - Tarea

## Objetivo
- Reforzar sintaxis Java + estructura Spring Boot por capas.
- Practicar la construccion completa de una vertical desde cero.

## Enunciado
- A partir de la consigna trabajada en clase, reconstruir desde cero el modulo Product.
- Crear todos los elementos necesarios:
	- model/Product
	- dto/ProductRequestDto
	- dto/ProductResponseDto
	- service/ProductService
	- controller/ProductController
- Implementar los endpoints:
	- GET /api/products
	- GET /api/products/{id}
	- POST /api/products
- Si llegas con tiempo, agregar PATCH /api/products/{id}/stock.
  - El producto se identifica por el {id} en la URL (@PathVariable).
  - El body lleva la cantidad a sumar: { "quantity": 10 } (@RequestBody ProductStockUpdateDto).
  - El service suma la cantidad al stock existente del producto encontrado.
- Si el id no existe, devolver una respuesta coherente (manejo basico local, sin ControllerAdvice).

## Campos a modelar
### Product
- id: Long
- name: String
- description: String
- price: BigDecimal
- stock: Integer

### ProductRequestDto
- name: String
- description: String
- price: BigDecimal
- stock: Integer

### ProductResponseDto
- id: Long
- name: String
- description: String
- price: BigDecimal
- stock: Integer

### ProductStockUpdateDto
- quantity: Integer  // cantidad a sumar al stock existente
- El producto NO se incluye en este DTO; se pasa por URL con @PathVariable.

### ProductService
- Lista en memoria de Product.
- Generador de ids incremental.
- Metodos minimos para listar, buscar por id, crear y agregar stock.
  addStock(Long id, Integer quantity) -> stockActual = stockActual + quantity

## Entrega esperada
- Codigo funcional y compilable.
- Al menos 3 pruebas manuales documentadas:
	- Caso feliz de actualizacion.
	- Id inexistente.
	- Stock invalido.

## Opcional (para profundizar)
- Agregar endpoint de busqueda por nombre: GET /api/products/search?name=...
