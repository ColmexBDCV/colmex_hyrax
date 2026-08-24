---
name: crear-metadato-rdf
description: Use when adding a metadata field, RDF predicate, RDA term, rdf-vocab term, or locale to this Hyrax repository. Collect and confirm all metadata details before editing code.
---

# Crear Metadato RDF

Use this skill to add a metadata field completely to this repository. Do not
edit files until the metadata definition and predicate have been confirmed by
the user.

## Required Context

Before asking questions or proposing files, inspect:

- `.opencode/skills/crear-metadato-rdf/references/CREACION_DE_METADATOS.md`
- `app/models/vocab/`
- `app/models/concerns/hyrax/basic_metadata.rb`
- `app/indexers/hyrax/basic_metadata_indexer.rb`
- `app/models/solr_document.rb`
- `app/forms/hyrax/forms/work_form.rb`
- `app/presenters/hyrax/work_show_presenter.rb`
- `app/controllers/catalog_controller.rb`
- `app/controllers/hyrax/my/works_controller.rb`
- Relevant model, presenter, form, view, and locale files for comparable fields

Preserve unrelated worktree changes. Do not revert or reformat files that are
not part of the requested metadata change.

## Information Intake

Ask for every missing item. Do not infer an ambiguous value silently.

Required information:

- Human-readable label in Spanish.
- Exact Ruby/Solr attribute name, without assuming that a leading underscore is
  meaningful. If the user supplies one, ask whether it is part of the name.
- Predicate or semantic relationship.
- Whether the field is shared by all works or belongs to a specific work type.
- Cardinality: single value or multiple values.
- Datatype, when it is not plain text.
- Whether the field must be stored/searchable and facetable in Solr.
- Whether it must appear in the create/edit form.
- Whether it must appear on the public work page.
- Whether it must appear in search results.
- Whether it must be registered as a public or dashboard facet.
- English label, if the application supports English for the affected layer.

If the user has not specified a value, present a recommended default based on
nearby fields and explicitly ask for confirmation. For shared descriptive
metadata, the usual default is `multiple: true` and stored, searchable,
facetable indexing, but do not apply it without confirmation when the meaning
could be ambiguous.

## Predicate Discovery

Predicates are not limited to RDA. Search in this order:

1. Existing local vocabularies in `app/models/vocab/`.
2. Terms exposed by the installed `rdf-vocab` gem under `RDF::Vocab`.
3. A new local vocabulary term, only after the user approves it.

For each plausible candidate, show:

- Vocabulary class and term name.
- Complete URI.
- Why it matches or does not match the requested meaning.

Use the repository's runtime or installed gem metadata to inspect `rdf-vocab`
when available. Do not invent a `RDF::Vocab` constant or term. If runtime
dependencies are unavailable, state that limitation and use source files or
the user's supplied URI instead.

When a local term already exists, reuse it. Do not create a duplicate term
under another vocabulary class.

When no existing term is semantically correct, tell the user that a new RDA
or local RDF term can be generated. Ask for confirmation of all of these:

- Vocabulary namespace and base URI.
- Exact term spelling and capitalization.
- Complete resulting URI.
- Local vocabulary class/file where the term will be declared.

An RDA typo changes the RDF URI and makes persisted data semantically wrong.
Never normalize, correct, or change the capitalization of a confirmed term
without telling the user.

## Confirmation Gate

Before editing, present one compact summary:

```text
Campo: <ruby_attribute>
Etiqueta ES: <label>
Etiqueta EN: <label or not requested>
Predicado: <vocabulary>.<term>
URI: <complete URI>
Alcance: compartido / <work type>
Cardinalidad: única / múltiple
Solr: stored_searchable / facetable / symbol
Formulario: sí/no
Ficha pública: sí/no
Resultados: sí/no
Facetas: catálogo / panel / ninguna
Archivos previstos: <list>
```

Ask the user to confirm this summary. Do not make code changes before
confirmation. If the user supplied all values unambiguously and explicitly
requested implementation, the confirmation can be a concise final check,
but still call out any inferred defaults.

## Implementation Matrix

For a shared field, update only the layers that the confirmed behavior
requires, normally:

1. Add or extend the selected vocabulary in `app/models/vocab/*.rb`.
2. Add the ActiveFedora property to `Hyrax::BasicMetadata` before its schema
   finalization behavior takes effect.
3. Add the attribute to the appropriate collection in
   `app/indexers/hyrax/basic_metadata_indexer.rb`.
4. Add the attribute to `self.terms` in
   `app/forms/hyrax/forms/work_form.rb` when it belongs in the general form.
5. Add a method to `app/models/solr_document.rb` returning the matching
   `*_tesim` field when the field is exposed from Solr.
6. Delegate the field in `app/presenters/hyrax/work_show_presenter.rb` when it
   is shown publicly.
7. Add the row to `app/views/hyrax/base/_attribute_rows.html.erb` when it is
   shown publicly. Use `render_as: :faceted` only for a facetable field.
8. Add `add_facet_field` to `catalog_controller.rb` only when a public facet
   was confirmed.
9. Add the matching dashboard facet to
   `hyrax/my/works_controller.rb` only when confirmed.
10. Add `add_index_field` when the field belongs in search results.
11. Add `add_show_field` when the field belongs in the individual result view.
12. Add locale labels in the applicable Spanish and English files.

For a type-specific field, use that type's model, form, presenter, view, and
locale files instead of the shared layers. Keep the same Solr and locale
conventions.

## Locale Rules

Use the actual project locale files:

- `config/locales/colmex.es.yml`: application-specific Spanish labels,
  including form and public UI overrides.
- `config/locales/hyrax.es.yml`: base Spanish Blacklight and Hyrax labels.
- `config/locales/hyrax.en.yml`: English Blacklight and Hyrax labels.

Use Solr suffixes only for Blacklight field keys:

- `field_sim` for facetable fields.
- `field_tesim` for stored/searchable text fields.

Use the plain attribute name for form and public-view labels, such as
`is_graduate_of`. Do not add a locale key merely to create a Solr field.
Ensure every added YAML key is unique within its mapping.

## Verification

Run only validations relevant to the change unless the user explicitly asks
for tests:

- Parse every modified YAML locale with Ruby/Psych.
- Run `ruby -c` on every modified Ruby file.
- Run `git diff --check` for intended files.
- If dependencies are available, inspect the generated predicate URI with the
  project's runtime.
- If a test suite or RSpec run was explicitly requested, run that command and
  report dependency failures without hiding them.

Do not run RSpec by default. Do not create or update data records unless the
user explicitly requests an integration check.

Finish by reporting:

- The selected predicate and complete URI.
- The layers and files changed.
- Validation commands and outcomes.
- Any unresolved ambiguity or unavailable dependency.
