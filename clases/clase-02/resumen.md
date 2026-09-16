# Clase 02 - Resumen

## Objetivo de la clase
- Entender por que los DTOs son clave para proteger la API.
- Introducir validaciones con Bean Validation en Spring Boot.
- Mostrar un ejemplo concreto de validacion de `ProductRequestDto` y explicar el papel de `@Valid`.
- Dejar claro que la clase enseña el patron, mientras que la tarea exige aplicarlo a un DTO nuevo del proyecto.

## Conceptos vistos
- Diferencia entre modelo de dominio y DTO de entrada.
- Uso de anotaciones de validacion: `@NotBlank`, `@NotNull`, `@Size`, `@Positive`, `@PositiveOrZero`, `@Email`.
- Activacion de validaciones con `@Valid` en el controller.
- La respuesta HTTP 400 como indicador de error de entrada invalida.
- Separacion de responsabilidades: controller recibe, service resuelve, DTO valida.
- Búsqueda case-insensitive por nombre en servicio.

## Demo realizada
- Se reviso el modulo `Product` de clase 01.
- Se mostro un ejemplo de validacion de `ProductRequestDto` en vivo.
- Se explico que la validacion se define en el DTO, no en la entidad ni en el controller.
- Se mostro como la clase genera un error cuando el payload es invalido.
- Se reforzo la idea de que el objetivo no es copiar la validacion exacta, sino comprender el patron y reutilizarlo.

## Mini entregable alcanzado
- Comprension inicial del flujo: DTO -> validacion -> controller -> service -> respuesta.
- Evidencia de que un request invalido no pasa al negocio.
- Base para que cada alumno complete una validacion similar sobre un DTO nuevo del proyecto.

## Dudas frecuentes y aclaraciones
- Por que no validamos en la entidad: porque la entidad puede representar el negocio, pero el DTO describe el contrato de entrada del endpoint.
- Que pasa si no usamos `@Valid`: las anotaciones del DTO no se ejecutan y la request puede entrar al servicio con datos inconsistentes.
- Por que no resolver la tarea completa en clase: porque la mejor practica es dejar un ejercicio que aplique el mismo patron a un caso nuevo y distinto.

## Guion sugerido para la clase
- "En la clase 01 armamos un `Product` y sus endpoints. Ahora necesitamos cuidar la calidad de la entrada."
- "Si un cliente manda un nombre vacio, un precio negativo o un stock inexistente, la API no debe seguir con la logica de negocio."
- "Ese es el punto de los DTOs: definir reglas antes de entrar al servicio."
- "Vamos a ver un ejemplo concreto con `ProductRequestDto` y la anotacion `@Valid`."
- "La clave no es que se copien exactamente estas reglas, sino que entiendan el patron y lo apliquen a otro DTO del proyecto."
- "En la tarea, ustedes van a decidir cuales campos del nuevo DTO requieren validacion y como expresarlo con las anotaciones apropiadas."
