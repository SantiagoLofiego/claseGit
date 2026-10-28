# Clase 05 - Resumen

## Objetivo de la clase
- Entender por que una API REST necesita manejar errores de forma uniforme.
- Introducir el patron de excepciones de negocio y de validacion.
- Mostrar como `@RestControllerAdvice` centraliza la respuesta de error.
- Dejar claro que la clase no trata solo de "capturar excepciones", sino de construir un contrato de API consistente.

## Conceptos vistos
- Diferencia entre error de validacion, error de negocio y error inesperado.
- Excepciones custom para dominio: `ResourceNotFoundException`, `ConflictException`.
- `@RestControllerAdvice` y `@ExceptionHandler` como punto central de manejo.
- `ApiErrorResponse` como estructura de respuesta uniforme.
- Uso de `@Valid` en DTOs para activar validaciones en la API.
- Importancia de devolver respuestas HTTP semanticas y no stack traces ni textos libres.

## Demo realizada
- Se mostro un ejemplo de `GET /api/products/{id}` con producto inexistente.
- Se definio una estructura JSON de error uniforme para toda la API.
- Se explico como el `service` lanza una excepcion de negocio y el advice la transforma en un 404, 400 o 409.
- Se mostró que el controller no debe tener logica de transformacion de errores; eso debe centralizarse.
- Se reforzó la diferencia entre validar un payload y evaluar una regla del negocio.

## Mini entregable alcanzado
- API con manejo global de errores funcionando en un caso real.
- Respuesta uniforme para distintos escenarios de fallo.
- Base para que la tarea aplique el mismo patron a otros endpoints del proyecto.

## Dudas frecuentes y aclaraciones
- ¿Por que no manejar errors dentro de cada controller? Porque se duplica logica y la API queda inconsistente.
- ¿Quien decide el HTTP status? El `@RestControllerAdvice`, a partir de la excepcion lanzada.
- ¿El advice reemplaza la validacion? No, la complementa; `@Valid` sigue siendo la base de las validaciones de DTO.
- ¿Por que no devolver stack traces? Porque el cliente necesita mensajes claros y seguros, no detalles internos del sistema.

## Guion sugerido para la clase
- "Una API funcional no es suficiente: tambien tiene que responder bien cuando falla."
- "El problema no es solo la excepcion, sino la forma en que la API la comunica."
- "En un proyecto real, el servicio decide que paso; el advice decide como lo devuelve al cliente."
- "La clave no es copiar una excepcion concreta, sino entender el patron: excepcion + advice + contrato de error."
- "La tarea de esta clase es extender este mismo patron a los endpoints restantes del proyecto."
