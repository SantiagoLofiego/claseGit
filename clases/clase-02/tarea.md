# Clase 02 - Tarea

## Objetivo
- Consolidar validaciones con DTOs en una API REST sin base de datos.
- Practicar `@Valid` y respuestas HTTP semanticas en casos validos e invalidos.
- Reforzar separacion por capas (controller/service/dto/model).
- Aplicar el ejemplo visto en clase a un nuevo DTO del proyecto, usando criterio propio y las mismas herramientas de validacion.

## Enunciado
- La clase mostro un ejemplo concreto de validacion de `ProductRequestDto`. Ahora, a partir de ese mismo patron, crear un DTO nuevo para el proyecto y validarlo siguiendo reglas de negocio coherentes.
- Crear `CustomerRequestDto` para registrar un cliente nuevo.
- Definir validaciones para campos como:
	- `firstName`: obligatorio, minimo 2 caracteres.
	- `lastName`: obligatorio, minimo 2 caracteres.
	- `email`: obligatorio, formato de email valido.
	- `phone`: opcional, pero si se envia debe tener al menos 8 digitos.
- Agregar la dependencia de validaciones en `pom.xml`:

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

- Asegurar que el endpoint `POST /api/customers` use `@Valid` en `@RequestBody`.


## Entrega esperada
- Codigo funcional y compilable.
- `pom.xml` actualizado con `spring-boot-starter-validation`.
- Endpoints funcionando:
	- `GET /api/products`
	- `GET /api/products/{id}`
	- `POST /api/products`
	- `PATCH /api/products/{id}/stock`
	- `POST /api/customers`
	- `GET /api/customers/{id}`

## Opcional (para profundizar)
- Crear `Customer` (el modelo) en memoria con DTO validado y servicio CustomerService con los metods necesarios para responder en los endpoints

