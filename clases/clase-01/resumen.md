# Clase 01 - Resumen

## Objetivo de la clase
- Construir una primera API REST funcional con Spring Boot usando datos en memoria.
- Entender el flujo completo request -> controller -> service -> response.
- Que el grupo pueda armar desde cero la primera vertical completa del proyecto.

## Conceptos vistos
- Estructura por capas: controller, service, dto, model.
- Diferencia entre DTO de entrada/salida y modelo interno.
- Endpoints REST basicos (GET lista, GET por id, POST alta).
- Respuestas HTTP semanticas (200 y 201 en casos felices).
- Inyeccion de dependencias basica con Spring.
- Construccion incremental de una funcionalidad real de negocio.

## Demo realizada
- Se creo el modulo Product en memoria.
- Se expusieron endpoints bajo prefijo /api.
- Se probo la API con cliente HTTP (Postman/Insomnia).
- Se mostro como se conectan model, dto, service y controller.

## Mini entregable alcanzado
- API de productos operativa con:
	- GET /api/products
	- GET /api/products/{id}
	- POST /api/products
- Base lista para que cada alumno replique la implementacion completa por su cuenta.

## Dudas frecuentes y aclaraciones
- Por que usar DTO si todavia no hay BD: para desacoplar contrato API del modelo interno desde el inicio.
- Donde va la logica: en service, no en controller.
- Por que arrancar en memoria: permite enfocarse en REST y capas sin sumar complejidad de persistencia.
