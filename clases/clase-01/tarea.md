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
	- El body lleva la cantidad a sumar (@RequestBody ProductStockUpdateDto):

```json
{
	"quantity": 10
}
```

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

```java
addStock(Long id, Integer quantity)
```

- Regla de negocio esperada:

```text
stockActual = stockActual + quantity
```

## Entrega esperada
- Codigo funcional y compilable.
- Estructura por capas completa creada desde cero:
	- model/Product
	- dto/ProductRequestDto
	- dto/ProductResponseDto
	- service/ProductService
	- controller/ProductController
- Endpoints base implementados y probados:
	- GET /api/products
	- GET /api/products/{id}
	- POST /api/products
- Al menos 4 pruebas manuales documentadas para los endpoints base:
	- GET lista (caso feliz).
	- GET por id existente (caso feliz).
	- GET por id inexistente.
	- POST de alta con datos validos.
- Si se implemento PATCH /api/products/{id}/stock, agregar al menos 3 pruebas extra:
	- Caso feliz de agregado de stock.
	- Id inexistente.
	- Quantity invalida (por ejemplo <= 0).

## Opcional (para profundizar)
- Agregar endpoint de busqueda por nombre: GET /api/products/search?name=...
