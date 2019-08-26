class IdentifierAlmaAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  include ApplicationHelper
  ##
  # Special treatment for license/rights.  A URL from the Hyrax gem's config/hyrax.rb is stored in the descMetadata of the
  # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
  def attribute_value_to_html(value)
    is_in_alma?(value)
  end
end
