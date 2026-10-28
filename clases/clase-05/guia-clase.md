# Clase 05 - Guia base para explicar la clase

## Objetivo de la clase
- Introducir la idea de que una API no solo debe responder con exito, sino tambien con errores claros y consistentes.
- Mostrar como centralizar la gestion de errores sin repetir codigo en cada controller.
- Explicar la diferencia entre excepcion de validacion, excepcion de negocio y excepcion inesperada.
- Conservar la separacion de responsabilidades: service decide el problema, advice define la respuesta HTTP.

## Agenda sugerida
1. Recordatorio breve de la clase 04
2. Problema real: errores inconsistentes en la API
3. Excepciones de negocio y validacion
4. `ApiErrorResponse` como contrato de error
5. `@RestControllerAdvice` y `@ExceptionHandler`
6. Demo en vivo de errores reales
7. Cierre y dudas

## 1) Recordatorio de la clase anterior
- La clase 04 mostró como modelar relaciones entre entidades con `Cart`, `CartItem` y `Product`.
- Ya hay una API funcional con persistencia real en H2.
- El siguiente problema que aparece en un proyecto real es: ¿como responder cuando falla una validacion o un recurso no existe?

Frase guia para la clase:

> "Una API que solo responde con exito es una API incompleta. Lo que distingue una API profesional es cómo responde cuando algo falla."

## 2) ¿Por que necesitamos manejo global de errores?
Hasta ahora, cada endpoint puede hacer cualquier cosa cuando algo falla:
- devolver `null`
- lanzar una exception sin formato
- responder con un 500 poco informativo
- mezclar mensajes internos con mensajes de negocio

Eso hace que la API sea dificil de consumir para frontend, QA y otros equipos. Para una API REST, la convención es clara:
- 400: entrada invalida
- 404: recurso no encontrado
- 409: conflicto de negocio
- 500: error inesperado del servidor

El manejo global de errores centraliza este comportamiento y evita duplicar logica.

## 3) Error de validacion vs error de negocio

### Error de validacion
Es un problema en la informacion que llega a la API.

Ejemplo:
- nombre vacio
- stock negativo
- quantity nula

Esto suele dispararse con `@Valid` + DTO y termina en `MethodArgumentNotValidException`.

### Error de negocio
Es un problema que ocurre dentro de la regla del negocio, aunque el request sea sintacticamente valido.

Ejemplo:
- producto no encontrado
- carrito inexistente
- cantidad menor o igual a cero
- stock insuficiente para una venta

Estos casos suelen resolverse con excepciones custom como `ResourceNotFoundException` o `ConflictException`.

### Error inesperado
Es cualquier excepcion no prevista por el sistema.

Ejemplo:
- NullPointerException no controlado
- error de infraestructura
- problema de base de datos

En ese caso, la API debe responder con 500 pero manteniendo un formato estructurado.

## 4) Excepciones custom a crear
Antes de entrar al advice, conviene mostrar las excepciones del dominio que van a representar errores de negocio. En esta clase se recomienda crear estas tres clases:

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

### Para que sirve cada una
- `ApiException`: base general para errores de la API si se quiere un tipo mas generico.
- `ResourceNotFoundException`: cuando un recurso no existe, por ejemplo `Product`, `Cart` o `Customer` inexistente.
- `ConflictException`: cuando existe un conflicto de negocio, por ejemplo `quantity <= 0`, `stock insuficiente` o un producto duplicado en un carrito.

### Recomendacion didactica
En un curso inicial, la clase puede presentar solo dos excepciones concretas (`ResourceNotFoundException` y `ConflictException`), y dejar `ApiException` como opcional o como base para futuras extensiones. Eso mantiene el ejemplo claro y evita sobre-complejidad para la etapa actual.

## 5) DTO de error
La forma recomendada para una API REST es devolver un JSON estandar.

```java
public record ApiErrorResponse(
    LocalDateTime timestamp,
    int status,
    String error,
    String message,
    String path
) {}
```

Ejemplo de respuesta:

```json
{
  "timestamp": "2026-10-28T10:15:30",
  "status": 404,
  "error": "Not Found",
  "message": "No se encontro el producto solicitado",
  "path": "/api/products/99"
}
```

Esto hace que frontend y pruebas puedan manejar errores sin depender de textos libres o stack traces.

## 6) `@RestControllerAdvice`
La idea central es que el advice capture excepciones y transforme cada una en una respuesta HTTP clara.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleNotFound(ResourceNotFoundException ex, HttpServletRequest request) {
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

### Regla de responsabilidad
- `service`: decide que paso y lanza la excepcion
- `controller`: delega la request
- `advice`: construye la respuesta HTTP final

Esto evita duplicar logica en cada endpoint y mantiene la API consistente.

## 7) Caso de ejemplo para la clase (endpoint de demo)
Para no mezclar la demostracion con la tarea, en la clase se va a trabajar sobre un caso concreto y acotado:

- `GET /api/products/{id}` cuando el producto no existe -> responde 404

Esto permite mostrar el patron completo sin abarcar todo el sistema a la vez.

La tarea no va a repetir este mismo endpoint como ejercicio principal, sino que va a exigir aplicar el mismo manejo a los endpoints restantes del proyecto, especialmente los que pueden fallar por:
- recurso inexistente
- conflicto de negocio
- validacion de DTO

Los casos de ejemplo que se pueden mostrar en clase son:

- `GET /api/products/{id}` con id inexistente -> 404
- `POST /api/products` con `name` vacio -> 400
- `POST /api/carts/{cartId}/items` con `quantity = 0` -> 409
- error inesperado -> 500 con formato uniforme

Esto permite que la clase quede muy conectada con el dominio y no sea solo una explicacion abstracta.

## 8) Demo en vivo sugerida
1. Mostrar un request invalido con `@Valid` a un DTO.
2. Ver la exception levantada por Spring.
3. Explicar como el `advice` la convierte en 400 con JSON estructurado.
4. Mostrar el ejemplo principal de la clase: `GET /api/products/{id}` con un producto inexistente.
5. Mostrar una regla de negocio conflictiva y su respuesta 409.
6. Cerrar con: "el sistema no solo funciona; falla bien".

## 9) Cierre y dudas
Frase final sugerida:

> "La API puede tener muchos casos felices, pero la cosa se vuelve profesional cuando todos los casos de error siguen un mismo contrato."

Dudas comunes:
- ¿Por que no manejarlo en cada controller? Porque se duplica y se vuelve inconsistente.
- ¿Por que `@RestControllerAdvice` y no `@ControllerAdvice`? Porque aqui la respuesta es JSON de API REST.
- ¿Por que no devolver el error tal cual? Porque el cliente necesita una estructura fiable y legible.
- ¿El advice reemplaza a validaciones? No, las complementa.
- ¿Los services deben lanzar excepciones? Si, porque ahi vive la regla de negocio.
