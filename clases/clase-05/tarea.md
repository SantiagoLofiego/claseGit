# Clase 05 - Tarea

## Objetivo
- Consolidar el manejo global de errores en una API REST Spring Boot.
- Aplicar el patron visto en clase sobre endpoints reales del proyecto.
- Reforzar la separacion por capas y la utilidad de `@Valid`, `@ExceptionHandler` y `@RestControllerAdvice`.
- Dejar un contrato de error uniforme para toda la API.

## Enunciado
La clase mostro el ejemplo base sobre un endpoint concreto: `GET /api/products/{id}` cuando un producto no existe. Ahora tenes que aplicar el mismo patron al resto de la API para que todos los endpoints respondan con errores consistentes.

### Requisitos
1. Crear la clase `ApiErrorResponse` para serializar errores en JSON.
2. Crear la excepcion `ResourceNotFoundException` para recursos inexistentes.
3. Crear la excepcion `ConflictException` para reglas de negocio conflictivas.
4. Crear la clase `GlobalExceptionHandler` anotada con `@RestControllerAdvice`.
5. Definir handlers con `@ExceptionHandler` para:
   - `ResourceNotFoundException`
   - `ConflictException`
   - `MethodArgumentNotValidException`
   - `Exception`
6. Asegurarte de que los endpoints del proyecto usen las anotaciones adecuadas:
   - `@RestController` en el controller
   - `@RequestMapping("/api")` o prefijo equivalente
   - `@GetMapping`, `@PostMapping`, `@PathVariable`, `@RequestBody`
   - `@Valid` en los DTOs de request
   - `@NotBlank`, `@NotNull`, `@Positive`, `@Min` en los DTOs cuando aplique
7. En los servicios, lanzar excepciones de negocio claras cuando haya un problema real, por ejemplo:
   - producto inexistente
   - carrito inexistente
   - cantidad menor o igual a cero
   - conflicto de negocio por stock insuficiente o duplicado

### Caso de negocio a cubrir
Aplicar el manejo global de errores sobre los siguientes endpoints del proyecto:

- `GET /api/products/{id}`
- `POST /api/products`
- `POST /api/carts/{cartId}/items`

### Ejemplo de estructura sugerida
```java
public record ApiErrorResponse(
    LocalDateTime timestamp,
    int status,
    String error,
    String message,
    String path
) {}
```

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleNotFound(
            ResourceNotFoundException ex,
            HttpServletRequest request) {

        ApiErrorResponse response = new ApiErrorResponse(
                LocalDateTime.now(),
                404,
                "Not Found",
                ex.getMessage(),
                request.getRequestURI()
        );

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
}
```

```java
public class ProductRequestDto {

    @NotBlank(message = "El nombre no puede estar vacio")
    private String name;

    @NotNull(message = "El precio es obligatorio")
    @Positive(message = "El precio debe ser mayor a cero")
    private BigDecimal price;
}
```

## Entrega esperada
- Codigo funcional y compilable.
- `@RestControllerAdvice` centralizando errores de la API.
- `@Valid` activado en los DTOs de request.
- Respuestas HTTP semanticas: 400, 404 y 409 segun el caso.
- JSON uniforme de error para toda la API.
- Al menos tres casos reales de error probados en Postman/Insomnia.

## Criterios de aceptacion
- La API no devuelve errores sin formato.
- Los errores de validacion y de negocio están diferenciados.
- La clase `GlobalExceptionHandler` maneja todos los casos esperados.
- El endpoint de ejemplo de la clase se entiende como demostracion, mientras que la tarea aplica el mismo patron al resto del proyecto.
- El resultado sigue la convencion por capas del curso: controller -> service -> dto -> exception -> advice.


