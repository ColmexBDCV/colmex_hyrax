# Creación de metadatos RDA

## Alcance

En este repositorio, crear un campo de metadatos no consiste solo en añadir un `property` al modelo. Para que el campo sea útil debe quedar definido con su URI RDF, persistirse en Fedora, exponerse en el formulario, indexarse en Solr, mostrarse en la ficha y tener una etiqueta localizada.

Los vocabularios RDA usados por la aplicación no están disponibles como clases listas para usar en la gema `rdf-vocab`. Por ello se declaran manualmente en `app/models/vocab/` y se consumen mediante `Vocab::...`.

## Flujo completo

Para un campo nuevo, revisar y modificar según aplique:

| Capa | Archivo o ubicación | Propósito |
| --- | --- | --- |
| Vocabulario | `app/models/vocab/*.rb` | Declara el término RDA y, por tanto, el URI RDF que se guardará en Fedora. |
| Modelo o concern | `app/models/*.rb` o `app/models/concerns/*.rb` | Declara la propiedad ActiveFedora y su cardinalidad. |
| Índice | Bloque de la propiedad o `app/indexers/hyrax/basic_metadata_indexer.rb` | Envía el valor a campos Solr. |
| Documento Solr | `app/models/solr_document.rb` | Expone el campo indexado como método para presentadores y vistas. |
| Formulario | `app/forms/hyrax/*_form.rb` o `app/forms/hyrax/forms/work_form.rb` | Permite capturar y actualizar el valor. |
| Presentador | `app/presenters/hyrax/*_presenter.rb` o `work_show_presenter.rb` | Hace disponible el valor indexado para la ficha. |
| Vista | `app/views/hyrax/base/*_attribute_rows.html.erb` | Renderiza el valor en la ficha, si debe mostrarse. |
| Configuración Blacklight | `app/controllers/catalog_controller.rb` y `app/controllers/hyrax/my/works_controller.rb` | Registra facetas, campos de resultados y campos de ficha. |
| Locale | `config/locales/colmex.es.yml`, `config/locales/hyrax.es.yml` y `config/locales/hyrax.en.yml` | Proporciona etiquetas para formulario, ficha y campos Solr según el idioma y la capa de la interfaz. |

No todos los campos son compartidos. Los campos comunes a las obras se definen en `Hyrax::BasicMetadata`; los propios de un tipo de obra se definen en el modelo de ese tipo, como `Thesis`, `Photography` o `Map`.

## 1. Declarar o ampliar el vocabulario RDA

Los vocabularios locales siguen este patrón:

```ruby
# app/models/vocab/rdam.rb
module Vocab
  class RDAM < RDF::Vocabulary('http://www.rdaregistry.info/Elements/m/#')
    term :detailsOfGenerationOfDigitalResource
  end
end
```

Cada llamada a `term` añade un término al espacio de nombres de esa clase. Después se usa como `::Vocab::RDAM.detailsOfGenerationOfDigitalResource`.

Los espacios de nombres existentes incluyen, entre otros:

| Clase | Base URI |
| --- | --- |
| `Vocab::RDAA` | `http://www.rdaregistry.info/Elements/a/#` |
| `Vocab::RDAE` | `http://www.rdaregistry.info/Elements/e/#` |
| `Vocab::RDAI` | `http://www.rdaregistry.info/Elements/i/#` |
| `Vocab::RDAM` | `http://www.rdaregistry.info/Elements/m/#` |
| `Vocab::RDAN` | `http://www.rdaregistry.info/Elements/n/#` |
| `Vocab::RDAT` | `http://www.rdaregistry.info/Elements/t/#` |
| `Vocab::RDAU` | `http://www.rdaregistry.info/Elements/u/#` |
| `Vocab::RDAW` | `http://www.rdaregistry.info/Elements/w/#` |
| `Vocab::RDAZ` | `http://www.rdaregistry.info/Elements/z/#` |

Procedimiento:

1. Consultar el RDA Registry y elegir el elemento y el espacio de nombres correctos para la entidad descrita.
2. Revisar primero los archivos de `app/models/vocab/` para no duplicar un término ya declarado.
3. Añadir `term :NombreExactoDelTermino` a la clase correspondiente.
4. Usar el mismo nombre exacto, incluyendo mayúsculas, al invocarlo desde el modelo.

No sustituir un término RDA por un símbolo inventado para abreviar. `RDF::Vocabulary` formará el URI directamente a partir del nombre del término; una errata crea un URI RDF diferente y deja datos semánticamente incorrectos en Fedora.

## 2. Declarar la propiedad ActiveFedora

Para un campo exclusivo de un tipo de obra, añadirlo antes de `include ::Hyrax::BasicMetadata`:

```ruby
# app/models/photography.rb
property :dimensions_of_still_image,
         predicate: ::Vocab::RDAM.dimensionsOfStillImage,
         multiple: true do |index|
  index.type :text
  index.as :stored_searchable, :facetable
end

# Debe permanecer al final: finaliza el esquema de metadatos.
include ::Hyrax::BasicMetadata
```

La posición es importante: en los modelos de Hyrax, `Hyrax::BasicMetadata` debe incluirse al final porque finaliza el esquema y añade los atributos anidados que usa el formulario.

Elegir la cardinalidad de acuerdo con la semántica:

| Opción | Uso |
| --- | --- |
| `multiple: true` | Valores repetibles; ActiveFedora los maneja como arreglo. |
| `multiple: false` | Un único valor; usarlo solo cuando no deba repetirse. |

El bloque de índice usado en los campos específicos genera campos Solr buscables, almacenados y facetables. Para texto normal, seguir el patrón existente `index.type :text` e `index.as :stored_searchable, :facetable`.

### Campo compartido por todas las obras

Si el campo debe estar disponible para los tipos que incluyen `Hyrax::BasicMetadata`, declararlo en `app/models/concerns/hyrax/basic_metadata.rb`:

```ruby
property :nuevo_campo,
         predicate: ::Vocab::RDAM.nombreDelElemento,
         multiple: true
```

En este caso también hay que añadir `:nuevo_campo` a la configuración correspondiente de `app/indexers/hyrax/basic_metadata_indexer.rb`. Ese indexador define explícitamente los campos compartidos que se envían a Solr. Elegir una de estas colecciones:

| Colección | Resultado esperado |
| --- | --- |
| `stored_and_facetable_fields` | El campo es recuperable, buscable y usable como faceta. |
| `stored_fields` | El campo es recuperable y buscable, sin faceta. |
| `symbol_fields` | Caso especial para datos que requieren la indexación simbólica definida por el proyecto. |

Omitir este paso deja el valor persistido en Fedora, pero puede impedir que se consulte, se presente o se use en búsqueda a través de Solr.

## 3. Exponer el campo desde el documento Solr

Los presentadores de esta aplicación leen los metadatos desde `SolrDocument`. Para un campo indexado, añadir un método que devuelva el campo `*_tesim` correspondiente:

```ruby
# app/models/solr_document.rb
def nuevo_campo
  self['nuevo_campo_tesim']
end
```

El nombre del campo debe coincidir con el atributo indexado. Sin este método, la delegación del presentador puede no encontrar el valor aunque Fedora y Solr lo contengan.

## 4. Exponer el campo en el formulario

Para un campo específico, agregarlo a `self.terms` del formulario del tipo de obra:

```ruby
# app/forms/hyrax/photography_form.rb
self.terms += [:resource_type, :photographer_corporate_body_of_work,
               :dimensions_of_still_image, :nuevo_campo]
```

Para un campo compartido, agregarlo a `self.terms` de `app/forms/hyrax/forms/work_form.rb`.

Los `terms` permiten que HydraEditor construya el control del formulario y que el campo pase por el formulario al modelo. Declarar una propiedad sin añadirla a los `terms` permite usarla desde consola o importador, pero no la muestra ni permite editarla desde la interfaz estándar.

## 5. Hacerlo visible en la ficha

Los presentadores reciben los valores desde el documento Solr, no directamente desde Fedora. Para un campo específico, delegarlo en el presentador del tipo:

```ruby
# app/presenters/hyrax/photography_presenter.rb
delegate :photographer_corporate_body_of_work, :dimensions_of_still_image,
         :nuevo_campo, to: :solr_document
```

Para un campo compartido, agregar la delegación a `Hyrax::WorkShowPresenter`.

Después añadir la fila a la vista correspondiente. Los campos generales están en `app/views/hyrax/base/_attribute_rows.html.erb`; los campos particulares normalmente están en `app/views/hyrax/base/_<tipo>_attribute_rows.html.erb`.

Ejemplo para un campo de texto:

```erb
<%= presenter.attribute_to_html(:nuevo_campo,
      label: t('hyrax.base.show.nuevo_campo'), html_dl: true) %>
```

Usar `render_as: :faceted` únicamente si el campo se indexó como facetable y debe generar enlaces de faceta en la ficha.

## 6. Agregar las etiquetas de locale

Cada metadato nuevo debe tener al menos su etiqueta de formulario/ficha en el locale específico de la aplicación, normalmente `config/locales/colmex.es.yml`:

```yaml
es:
  hyrax:
    base:
      show:
        nuevo_campo: Etiqueta visible en español
```

Este proyecto también mantiene etiquetas para campos Solr. Añadirlas cuando el campo se muestre en resultados, listados, búsqueda avanzada o facetas:

```yaml
es:
  blacklight:
    search:
      fields:
        index:
          nuevo_campo_tesim: Etiqueta visible en resultados
        facet:
          nuevo_campo_sim: Etiqueta visible en facetas
```

La convención usada por el proyecto es `*_tesim` para los campos de texto almacenado/buscable y `*_sim` para los facetables. Confirmar el nombre final en Solr antes de añadir una etiqueta. Añadir una clave de locale no crea el campo Solr ni activa una faceta.

Las claves `*_tesim` y `*_sim` se usan solo para las etiquetas de campos Solr de Blacklight. Las etiquetas de ficha y formulario usan el nombre del atributo sin esos sufijos, por ejemplo `is_graduate_of`. En este repositorio, las etiquetas base en español se mantienen en `config/locales/hyrax.es.yml`, las traducciones inglesas en `config/locales/hyrax.en.yml` y las personalizaciones de la aplicación en `config/locales/colmex.es.yml`.

Si la aplicación debe funcionar también en inglés, añadir el equivalente en `config/locales/hyrax.en.yml`. No duplicar una clave YAML: YAML conservará solo la última aparición y puede ocultar una traducción previa.

## 7. Registrar campos y facetas en Blacklight

`add_index_field` controla los campos que aparecen en resultados de búsqueda. Si el campo debe mostrarse allí, registrarlo con su variante `:stored_searchable` y, cuando corresponda, enlazarlo a su faceta:

```ruby
# app/controllers/catalog_controller.rb
config.add_index_field solr_name('nuevo_campo', :stored_searchable),
                       itemprop: 'nuevo_campo',
                       link_to_search: solr_name('nuevo_campo', :facetable)
```

Para mostrarlo en la vista individual, registrarlo también como campo de ficha:

```ruby
config.add_show_field solr_name('nuevo_campo', :stored_searchable)
```

Si el campo es facetable y debe aparecer como filtro, registrarlo tanto en el catálogo público como en el panel de obras:

```ruby
# app/controllers/catalog_controller.rb
config.add_facet_field solr_name('nuevo_campo', :facetable), limit: 5

# app/controllers/hyrax/my/works_controller.rb
config.add_facet_field 'nuevo_campo_sim', limit: 5
```

No agregar una faceta para un campo de cardinalidad alta o texto libre sin valorar primero su utilidad y costo en Solr.

## Checklist de implementación

1. Validar en RDA Registry el URI y la semántica del elemento.
2. Declarar el término faltante en `app/models/vocab/<vocabulario>.rb`.
3. Declarar la propiedad en el modelo o concern, antes de incluir `Hyrax::BasicMetadata` cuando corresponda.
4. Definir indexación: bloque `index` para campos propios o `BasicMetadataIndexer` para campos compartidos.
5. Añadir el método correspondiente en `app/models/solr_document.rb`.
6. Añadir el campo al formulario correcto.
7. Añadir la delegación al presentador y la fila de vista si debe mostrarse públicamente.
8. Añadir las claves en `config/locales/colmex.es.yml`; incluir claves `*_tesim` y `*_sim` si aparecen en Solr/UI.
9. Registrar `add_index_field`, `add_show_field` y las facetas requeridas en los controladores Blacklight.
10. Crear una obra de prueba, guardar un valor, verificarlo en Fedora y confirmar el documento Solr.
11. Probar creación, edición, ficha pública, búsqueda y faceta con `RAILS_ENV=test` o desarrollo antes de desplegar.

## Verificación después del cambio

La comprobación mínima es que el valor persista, se indexe y tenga etiqueta:

```bash
ID='identificador-de-prueba' RAILS_ENV=development bin/rails runner 'work = ActiveFedora::Base.find(ENV.fetch("ID")); pp work.nuevo_campo; pp ActiveFedora::SolrService.query("id:#{work.id}", rows: 1).first'
```

El comando se debe adaptar al nombre real del campo. Si el valor existe en Fedora pero no aparece en el documento Solr, revisar el bloque de indexación y reindexar el objeto tras corregirlo:

```bash
ID='identificador-de-prueba' RAILS_ENV=development bin/rails runner 'work = ActiveFedora::Base.find(ENV.fetch("ID")); work.update_index'
```

Consultar también `docs/ACTIVEFEDORA_FCREPO_SOLR.md` para el diagnóstico de problemas entre Fedora y Solr.
