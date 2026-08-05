---
description: "Cierra una clase de la capacitacion: valida materiales, actualiza referencias y prepara salida HTML"
name: "Cerrar Clase"
argument-hint: "Numero de clase (ejemplo: 01)"
agent: "agent"
---

Quiero cerrar una clase de la capacitacion.

Usa el argumento de este comando como numero de clase (ejemplo: `01`).
Si no se informo el numero, pedilo antes de continuar.

## Flujo obligatorio
1. Normalizar el numero a dos digitos (`01`, `02`, ..., `12`) y trabajar sobre `clases/clase-XX`.
2. Revisar y, si hace falta, actualizar:
- `clases/clase-XX/resumen.md`
- `clases/clase-XX/actividad.md`
- `clases/clase-XX/tarea.md`
- `clases/clase-XX/cheatsheet.md`
3. Verificar checklist de cierre en `.github/copilot-instructions.md` y reflejar ajustes en:
- `programa-capacitacion-springboot.md`
- `.github/copilot-instructions.md`
4. Regenerar HTML de plataforma para esa clase (solo esa clase):
- `powershell -ExecutionPolicy Bypass -File .\cerrar-clase.ps1 -NumeroClase XX`
5. Validar resultado y entregar:
- resumen de cambios
- checklist de cierre cumplido
- propuesta de mensaje de commit

## Criterios de calidad
- No tocar clases que no sean la indicada.
- Mantener bloques Markdown con lenguaje explicito (`java`, `json`, `powershell`, `text`).
- Mantener consistencia pedagogica con el nivel de la clase.
