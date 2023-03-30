class TableContentAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  include ApplicationHelper
  ##
  # Special treatment for license/rights.  A URL from the Hyrax gem's config/hyrax.rb is stored in the descMetadata of the
  # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
  def attribute_value_to_html(value)
    match = /\[(\d+)\]/.match(value)
    if match
      number = match[1].to_i
      %(<a class="table_of_contents" href="" onclick="go_to_page(#{match[1]})">#{value.gsub(match[0], "")}</a>)
    else
      value.gsub("--", "<br>")
    end
    
  end
  
end
