# Clase 02 - Actividad en clase

## Contexto
- Partimos del modulo Product creado en clase 01 con datos en memoria.
- En esta clase no se usa JPA ni `@ControllerAdvice`.
- El foco es mejorar la calidad del contrato API con DTOs y validaciones.
- En la clase se puede mostrar un ejemplo concreto de validacion de `ProductRequestDto`, pero no se debe convertir en la solucion final del ejercicio; la tarea exige reaplicar ese mismo criterio a un DTO nuevo del proyecto.

## Consigna
- Revisar `ProductRequestDto` como ejemplo en vivo y detectar que campos del dominio requieren reglas de negocio antes de aceptar la entrada.
- Observar por que `@Valid` en el controller es clave para que las validaciones del DTO se ejecuten.
- Analizar la diferencia entre:
  - error de negocio,
  - error de entrada invalida,
  - error de formato/validacion del payload.
- A partir de ese ejemplo, en la tarea deben crear o validar un nuevo DTO del proyecto y aplicar la misma logica de validacion con criterio propio.
- Mantener responsabilidades por capa:
  - controller: recibe request y delega.
  - service: logica de negocio.
- Agregar o ajustar busqueda por nombre:
  - `GET /api/products/search?name=...`
  - comparacion case-insensitive en service.

## Criterios de aceptacion
- Se entiende el concepto de DTO + validacion y el papel de `@Valid`.
- Se identifica al menos un campo que requiere validacion con regla de negocio.
- Se prueba al menos un caso feliz.
- Se observa la diferencia entre un request valido e invalido.
- El estudiante aplica el patron explicado en clase a un DTO nuevo del dominio, no solo repite la validacion de Product.
- No se introduce persistencia ni manejo global de errores.

## Pistas para la clase
- Sin `@Valid` en el controller, las anotaciones del DTO no se ejecutan.
- Las validaciones van en el DTO, no en el modelo de dominio ni en la capa controller.
- El ejemplo de `Product` sirve como guia conceptual; la tarea debe exigir criterio y decision propia.
- Para busqueda por nombre, transformar ambos valores a minuscula antes de comparar.
