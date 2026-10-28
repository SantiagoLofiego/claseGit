# Clase 05 - Cheatsheet

## Patron central de la clase

La idea principal es simple:

- el service decide que paso
- la excepcion describe el problema
- el `@RestControllerAdvice` construye la respuesta HTTP

```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleNotFound(ResourceNotFoundException ex, HttpServletRequest request) {
        ApiErrorResponse error = new ApiErrorResponse(
            LocalDateTime.now(),
            404,
            "Not Found",
            ex.getMessage(),
            request.getRequestURI()
        );

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
}
```

## Anotaciones clave para esta clase

| Anotacion | Para que sirve |
|---|---|
| `@RestControllerAdvice` | Centraliza el manejo de errores para toda la API REST. |
| `@ExceptionHandler` | Define que metodo responde ante una excepcion concreta. |
| `@Valid` | Activa validaciones de Bean Validation en DTOs de request. |
| `@RequestBody` | Indica que el payload entra como JSON en el controller. |
| `@PathVariable` | Recupera un valor de la URL como id, cartId, etc. |
| `@RequestMapping` | Define la base del endpoint `/api` si se usa a nivel de controller. |
| `@GetMapping` / `@PostMapping` | Define el metodo HTTP del endpoint. |

## Excepciones custom recomendadas

```java
public class ApiException extends RuntimeException {
    public ApiException(String message) {
        super(message);
    }
}
```

```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

```java
public class ConflictException extends RuntimeException {
    public ConflictException(String message) {
        super(message);
    }
}
```

## DTO de error para toda la API

```java
public record ApiErrorResponse(
    LocalDateTime timestamp,
    int status,
    String error,
    String message,
    String path
) {}
```

## Validaciones comunes reutilizadas

| Anotacion | Para que sirve |
|---|---|
| `@NotBlank` | El texto no puede estar vacio o en blanco. |
| `@NotNull` | El campo no puede ser nulo. |
| `@Positive` | El numero debe ser mayor que cero. |
| `@Min(1)` | El valor numerico debe ser al menos 1. |
| `@Size(min = ..., max = ...)` | Limita largo de cadenas. |

## Casos de respuesta esperados

| Situacion | HTTP | Excepcion sugerida |
|---|---|---|
| Recurso no existe | 404 | `ResourceNotFoundException` |
| Data invalida | 400 | `MethodArgumentNotValidException` |
| Regla de negocio conflictiva | 409 | `ConflictException` |
| Error inesperado | 500 | `Exception` |

## Ejemplo de validacion de DTO

```java
public class ProductRequestDto {

    @NotBlank(message = "El nombre no puede estar vacio")
    private String name;

    @NotNull(message = "El precio es obligatorio")
    @Positive(message = "El precio debe ser mayor a cero")
    private BigDecimal price;
}
```

## Regla de responsabilidad entre capas

- `Controller`: recibe la request y delega
- `Service`: aplica reglas de negocio
- `Exception`: describe el problema
- `Advice`: transforma el problema en respuesta HTTP

Esto es lo que evita que cada endpoint haga su propia logica y genere respuestas inconsistentes.

## Ejemplo de error uniforme

```json
{
  "timestamp": "2026-10-28T10:15:30",
  "status": 404,
  "error": "Not Found",
  "message": "No se encontro el producto solicitado",
  "path": "/api/products/99"
}
```

## Recomendaciones practicas
- No devolver stack traces ni mensajes internos al cliente.
- Mantener los mensajes claros y orientados al negocio.
- Usar `@RestControllerAdvice` para centralizar y no duplicar codigo.
