# Clase 05 - Actividad en clase

## Contexto
- `Product`, `Customer` y `Cart` ya existen como entidades persistidas y ya tienen endpoints funcionales.
- El sistema responde a la mayoria de requests, pero un error de negocio o una validacion invalida puede devolver respuestas poco claras, inconsistentes o incompletas.
- En esta clase se introduce un principio clave de APIs REST profesionales: no alcanza con "que funcione"; debe fallar de forma uniforme y predecible.

## Objetivo de la actividad
- Comprender la diferencia entre validacion, error de dominio y error inesperado.
- Centralizar el manejo de errores con `@RestControllerAdvice`.
- Definir una estructura de respuesta comun para toda la API.
- Aplicar el patron a casos reales del ecommerce: recurso inexistente, conflicto de negocio y validacion de DTO.

## Consigna
1. Crear la clase `ApiErrorResponse` con estos campos:
   - `timestamp`
   - `status`
   - `error`
   - `message`
   - `path`
2. Crear la excepcion `ResourceNotFoundException`.
3. Crear la excepcion `ConflictException`.
4. Crear la clase `GlobalExceptionHandler` con `@RestControllerAdvice`.
5. Definir handlers para:
   - `ResourceNotFoundException` -> HTTP 404
   - `ConflictException` -> HTTP 409
   - `MethodArgumentNotValidException` -> HTTP 400
   - `Exception` -> HTTP 500
6. Ajustar un par de endpoints para que lancen estas excepciones cuando corresponde:
   - buscar un producto que no existe
   - intentar crear un producto con campos invalidos
   - intentar una regla de negocio conflictiva (por ejemplo, cantidad menor o igual a cero)
7. Probar los endpoints con Postman/Insomnia y validar que el JSON de error sea consistente en todos los casos.

## Preguntas orientadoras para la clase
- ¿Por que no conviene manejar errores dentro de cada controller?
- ¿Cual es la diferencia entre un error de validacion y un conflicto de negocio?
- ¿Por que el tipo de respuesta HTTP importa tanto como el mensaje?
- ¿Que ventajas tiene devolver un JSON estructurado en lugar de un texto libre?
- ¿Cuanto de la logica del negocio debe vivir en el service y cuanto en el advice?

## Criterios de aceptacion
- La API cuenta con un manejo global de errores.
- Hay un formato uniforme para todos los errores de la API.
- Al menos dos casos de negocio quedan cubiertos: recurso no encontrado y conflicto.
- Las validaciones del DTO se traducen en respuesta HTTP 400.
- La respuesta no expone stack traces ni detalles internos del sistema al cliente.

## Pistas para la clase
- `@RestControllerAdvice` es la herramienta de Spring para centralizar errores REST. Es la opcion mas clara para una API.
- `@Valid` en un DTO dispara `MethodArgumentNotValidException` cuando los datos no cumplen la validacion.
- El `service` lanza excepciones de negocio; el `advice` decide el HTTP status y la forma del JSON.
- Un `fallback` con `Exception` ayuda a evitar respuestas no estructuradas.
- Lo importante no es la clase exacta de error, sino el patron: excepcion + advice + respuesta uniforme.
