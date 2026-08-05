// convertir.js
// Uso: node convertir.js <archivo.md> <salida.html> [titulo]
// Convierte un archivo Markdown a HTML standalone con estilos basicos.

const fs = require('fs');
const path = require('path');
const { marked } = require('marked');
const { markedHighlight } = require('marked-highlight');
const hljs = require('highlight.js');

const [,, entrada, salida, titulo = ''] = process.argv;

if (!entrada || !salida) {
  console.error('Uso: node convertir.js <entrada.md> <salida.html> [titulo]');
  process.exit(1);
}

marked.use(markedHighlight({
  emptyLangClass: 'hljs',
  langPrefix: 'hljs language-',
  highlight(code, language) {
    if (language && hljs.getLanguage(language)) {
      return hljs.highlight(code, { language }).value;
    }

    return hljs.highlight(code, { language: 'plaintext' }).value;
  }
}));

const markdown = fs.readFileSync(entrada, 'utf8').replace(/^\uFEFF/, '');
const cuerpo = marked(markdown);

const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${titulo}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 860px;
      margin: 40px auto;
      padding: 0 24px;
      color: #d4d4d4;
      background: #1e1e1e;
      line-height: 1.6;
    }
    h1, h2, h3 { color: #4fc1ff; border-bottom: 1px solid #3c3c3c; padding-bottom: 6px; }
    code {
      background: #252526;
      border-radius: 4px;
      padding: 2px 6px;
      font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
      font-size: 0.9em;
      color: #ce9178;
    }
    pre {
      background: #1e1e1e;
      border: 1px solid #3c3c3c;
      border-left: 4px solid #569cd6;
      border-radius: 4px;
      padding: 16px;
      overflow-x: auto;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
    }
    pre code { background: none; padding: 0; }
    .hljs {
      color: #d4d4d4;
      background: transparent;
    }
    .hljs-comment,
    .hljs-quote {
      color: #6a9955;
      font-style: italic;
    }
    .hljs-keyword,
    .hljs-selector-tag,
    .hljs-subst {
      color: #569cd6;
      font-weight: 600;
    }
    .hljs-number,
    .hljs-literal,
    .hljs-variable,
    .hljs-template-variable,
    .hljs-tag .hljs-attr {
      color: #b5cea8;
    }
    .hljs-string,
    .hljs-doctag {
      color: #ce9178;
    }
    .hljs-title,
    .hljs-section,
    .hljs-selector-id {
      color: #dcdcaa;
      font-weight: 600;
    }
    .hljs-type,
    .hljs-class .hljs-title {
      color: #4ec9b0;
      font-weight: 600;
    }
    .hljs-attribute,
    .hljs-name,
    .hljs-tag {
      color: #9cdcfe;
    }
    .hljs-built_in,
    .hljs-builtin-name {
      color: #4ec9b0;
    }
    .hljs-params {
      color: #9cdcfe;
    }
    .hljs-function .hljs-title,
    .hljs-title.function_ {
      color: #dcdcaa;
    }
    .language-json .hljs-attr {
      color: #9cdcfe;
      font-weight: 600;
    }
    .language-json .hljs-string {
      color: #ce9178;
    }
    .language-json .hljs-number {
      color: #b5cea8;
      font-weight: 600;
    }
    .language-json .hljs-literal {
      color: #569cd6;
      font-weight: 600;
    }
    .language-json .hljs-punctuation {
      color: #d4d4d4;
    }
    p, li, td, th {
      color: #d4d4d4;
    }
    a {
      color: #4fc1ff;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 16px 0;
    }
    th, td {
      border: 1px solid #3c3c3c;
      padding: 8px 12px;
      text-align: left;
    }
    th { background: #252526; font-weight: 600; }
    blockquote {
      border-left: 4px solid #569cd6;
      margin: 0;
      padding: 8px 16px;
      color: #9cdcfe;
      background: #252526;
    }
    hr { border: none; border-top: 1px solid #3c3c3c; margin: 24px 0; }
  </style>
</head>
<body>
${cuerpo}
</body>
</html>`;

fs.mkdirSync(path.dirname(salida), { recursive: true });
fs.writeFileSync(salida, html, 'utf8');
