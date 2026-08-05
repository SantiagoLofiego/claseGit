# Contexto del proyecto de capacitacion

## Objetivo
Este repositorio se usa para una capacitacion incremental de Java + Spring Boot orientada a un caso real de consultoria: una API REST de e-commerce que crece clase a clase.

## Perfil de alumnos
- Grupo mixto: perfiles con experiencia en legacy (mainframe/COBOL) y perfiles junior con foco frontend.
- Ya conocen sintaxis Java.
- Se prioriza comprension conceptual + practica aplicada.

## Parametros operativos confirmados
- Duracion por clase: entre 1:30 y 2:00 horas.
- Version de Java: Java 21.
- Base de datos por etapas: comenzar con H2 y migrar luego a PostgreSQL o SQL Server si el entorno lo permite.
- Restriccion de entorno: los equipos de capacitacion pueden tener permisos limitados por politicas de clientes.
- Uso de Git obligatorio como parte de la dinamica del curso.
- Modalidad de avance: mini entregables incrementales por clase.

## Enfoque didactico
- Avance por iteraciones pequenas con entregables funcionales por clase.
- Priorizar claridad de arquitectura por capas desde el inicio.
- Evitar complejidad temprana innecesaria.

## Orden pedagogico esperado
1. REST basico con datos en memoria.
2. DTOs y validaciones.
3. JPA/Hibernate y persistencia.
4. Relaciones entre entidades.
5. Manejo global de errores.
6. Testing.
7. Seguridad.
8. Observabilidad y documentacion.

## Criterios tecnicos para cambios en este repo
- Mantener estructura por capas: controller, service, dto, model, repository.
- Evitar mezclar entidades de persistencia con DTOs de API.
- Mantener nombres claros y consistentes en espanol o ingles, sin mezcla arbitraria.
- Incluir ejemplos de request/response cuando se agreguen endpoints.
- Favorecer cambios incrementales y faciles de explicar en clase.

## Restricciones didacticas actuales
- En etapas iniciales no introducir JPA, ORM, ni manejo global de errores si la clase aun no lo cubre.
- Cada aporte de codigo debe ser compatible con el nivel de la clase actual.

## Convenciones sugeridas
- Paquete base: com.capacitacion.ecommerce (ajustable).
- Prefijo API: /api.
- Respuestas HTTP semanticas.
- Validaciones con mensajes claros para alumnos.

## Modo de trabajo esperado
- Cada cambio debe poder mostrarse en una demo corta de clase.
- Incluir ejercicios sugeridos al final de cada incremento.
- Registrar decisiones pedagogicas cuando cambie el alcance.

## Estructura de materiales por clase
Crear y mantener una carpeta por clase con los siguientes archivos:
- resumen.md
- actividad.md
- tarea.md
- cheatsheet.md

Estos materiales deben mantenerse alineados con el estado real del proyecto y con el alcance pedagogico de cada clase.

## Convenciones de formato para materiales
- Todo bloque de codigo en Markdown debe declarar lenguaje explicito en el fence (por ejemplo: java, json, powershell, text).
- Evitar bloques sin lenguaje para que la conversion a HTML conserve resaltado correcto.
- El material exportado a HTML para la plataforma debe priorizar tema oscuro con buen contraste y syntax highlighting legible.

## Definicion de listo por clase
- Endpoints funcionando.
- Caso de uso demostrable.
- Explicacion de por que se implemento asi.
- Mini desafio para practica autonoma.
