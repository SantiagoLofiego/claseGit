# Material para plataforma e-learning

Esta carpeta contiene los archivos listos para subir a la plataforma.

## Contenido esperado
- cheatsheet.html  (generado desde ../cheatsheet.md)
- tarea.html       (generado desde ../tarea.md)

## Como generar los HTML
Desde la carpeta raiz del proyecto, con Node.js instalado:

    .\generar-html.ps1 -Clase clase-04

O bien:

    npm run generar -- -Clase clase-04

Los archivos .md de origen NO deben subirse a la plataforma.
