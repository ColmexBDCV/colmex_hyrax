class TableContentAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  include ApplicationHelper
  ##
  # Renderiza entradas de contenido con formato "Titulo [pagina]" como enlaces al visor PDF.
  def attribute_value_to_html(value)
    match = /\[(\d+)\]/.match(value)
    if match
      label = ERB::Util.html_escape(value.gsub(match[0], ""))
      %(<a class="table_of_contents" onclick="go_to_page(#{match[1].to_i})">#{label}</a>)
    else
      ERB::Util.html_escape(value).gsub("--", "<br>")
    end
    
  end
  
end
