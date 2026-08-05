# Material para plataforma e-learning

Esta carpeta contiene los archivos listos para subir a la plataforma.

## Contenido esperado
- cheatsheet.html  (generado desde ../cheatsheet.md)
- tarea.html       (generado desde ../tarea.md)

## Como generar los HTML
Desde la carpeta raiz del proyecto, con Node.js instalado:

    npx markdown-html-converter ../cheatsheet.md -o cheatsheet.html
    npx markdown-html-converter ../tarea.md -o tarea.html

O con cualquier conversor de Markdown a HTML disponible en el entorno.
Los archivos .md de origen NO deben subirse a la plataforma.
