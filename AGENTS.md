# Instrucciones del proyecto

## Metadatos RDF/Hyrax

Cuando se solicite agregar o modificar un campo de metadatos, consultar antes
de editar:

- `.opencode/skills/crear-metadato-rdf/SKILL.md`
- `.opencode/skills/crear-metadato-rdf/references/CREACION_DE_METADATOS.md`

No modificar archivos hasta confirmar la definición del campo y su predicado.
La confirmación debe incluir, como mínimo: nombre Ruby/Solr exacto, etiqueta
en español, predicado y URI completo, alcance, cardinalidad, indexación Solr,
formulario, ficha pública, resultados y facetas.

Para descubrir el predicado, revisar en este orden:

1. Vocabularios locales en `app/models/vocab/`.
2. Términos disponibles en `rdf-vocab`.
3. Un término local nuevo únicamente con aprobación explícita.

Un campo compartido debe seguir el flujo completo de Fedora, Solr, formulario,
presentador, vista, Blacklight y locales según corresponda. No agregar capas
que no hayan sido confirmadas. Respetar la posición final de
`Hyrax::BasicMetadata` en los modelos.

Preservar cambios ajenos. No inventar ni corregir silenciosamente nombres de
términos RDF. No ejecutar RSpec ni crear registros de prueba salvo petición
explícita.

La validación mínima de cambios es:

- `ruby -c` para cada Ruby modificado.
- Parseo con Ruby/Psych para cada YAML modificado.
- `git diff --check`.

Para Rails, Ruby, Bundler, Solr, Fedora y Redis usar Docker Compose según
`.opencode/skills/hyrax-docker-development/SKILL.md`.
