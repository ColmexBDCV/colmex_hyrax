# Instrucciones del repositorio

## Entorno y comandos

- Ejecutar Ruby, Bundler, Rails, RSpec, Redis, Solr y Fedora mediante Docker Compose; no depender de Ruby ni de las gemas instaladas en el host. La guía completa está en `.opencode/skills/hyrax-docker-development/SKILL.md`.
- El stack usa Ruby 2.7.8/Bundler 2.4.22, Rails 5.2.8.1, Hyrax 3.6.0, SQLite, Solr 7.1.0 y Fedora 4.7.5. `docker-compose.yml` es la fuente de verdad si difiere la documentación antigua.
- Desde la raíz: `docker compose config --quiet` valida Compose; `docker compose up -d app` inicia el entorno; `docker compose ps` comprueba la salud de los servicios.
- El entrypoint ejecuta automáticamente `db:create db:migrate` y prepara el AdminSet/workflows en cada inicio. Usar `SKIP_BOOTSTRAP=1` solo cuando se necesite omitirlo explícitamente.
- Para pruebas, usar `docker compose run --rm app bundle exec rspec spec/ruta/al_spec.rb` para un archivo y `docker compose run --rm app bundle exec rspec` para toda la suite. Para comandos Rails aislados, usar `DISABLE_SPRING=1` si aparece el conflicto de `mutex_m`/Spring.
- Solr debe crearse con la configuración versionada en `solr/config`, nunca con `_default`; si faltan `has_model_ssim` o `visibility_ssi`, recrear con `docker compose up -d --force-recreate solr`.

## Estructura y cambios de metadatos

- La aplicación es un Rails monolítico basado en Hyrax: modelos, formularios, indexadores, presenters y vistas están bajo `app/`; las pruebas RSpec están bajo `spec/`; tareas operativas están en `lib/tasks/`.
- Para agregar o modificar metadatos RDF, leer `.opencode/skills/crear-metadato-rdf/SKILL.md` y `references/CREACION_DE_METADATOS.md` antes de editar. Confirmar primero nombre Ruby/Solr, etiqueta, URI/predicado, alcance, cardinalidad, indexación, formulario, ficha pública, resultados y facetas.
- Para elegir predicados, revisar primero `app/models/vocab/`, luego `rdf-vocab`; crear un vocabulario local solo con aprobación explícita. Un campo compartido debe recorrer Fedora, Solr, formulario, presenter, vista, Blacklight y locales según corresponda.

## Seguridad del trabajo

- Preservar cambios no relacionados del worktree; no restablecer ni sobrescribir archivos modificados por otra tarea.
- No incluir credenciales del `.env` ni datos sensibles en commits o salidas. `.env.example` documenta las variables necesarias; los servicios Compose proporcionan por defecto las URL de Redis, Solr y Fedora.
