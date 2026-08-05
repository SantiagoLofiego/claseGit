# Material por clase

Este directorio organiza el contenido didactico clase a clase.

Estructura por carpeta:
- resumen.md
- actividad.md
- tarea.md
- cheatsheet.md

Convencion:
- clase-01, clase-02, ..., clase-12
- Actualizar primero resumen.md al cerrar cada clase.
- Versionar cada mini entregable con commit y PR.
- Todo bloque de codigo en Markdown debe declarar lenguaje explicito: java, json, powershell, text, etc.
- El material pensado para exportar a HTML debe favorecer bloques cortos, legibles y con ejemplos ejecutables.

Comando sugerido para cierre de clase:
- powershell directo: .\cerrar-clase.ps1 -NumeroClase 1
- via npm script: npm run cerrar-clase -- -NumeroClase 1
