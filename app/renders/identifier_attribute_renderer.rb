module Hyrax
  module Renderers
    # This is used by PresentsAttributes to show licenses
    #   e.g.: presenter.attribute_to_html(:rights_statement, render_as: :rights_statement)
    class IdentifierAttributeRenderer < AttributeRenderer
      private

        ##
        # Special treatment for license/rights.  A URL from the Hyrax gem's config/hyrax.rb is stored in the descMetadata of the
        # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
        def attribute_value_to_html(value)
            %(<a href=http://colmex-primo.hosted.exlibrisgroup.com/primo_library/libweb/action/dlSearch.do?search_scope=52COLMEX_ALL&institution=52COLMEX&vid=52COLMEX_INST&query=any,contains,#{value} target="_blank">#{value}</a>)
        end
    end
  end
end
