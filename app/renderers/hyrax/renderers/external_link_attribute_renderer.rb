module Hyrax
  module Renderers
    class ExternalLinkAttributeRenderer < AttributeRenderer
      private
      
        def extract_url(text)
          url_regex = /(https?:\/\/[^\s]+)/
          match = url_regex.match(text)
          if match
            url = match[1]
            rest_text = text.gsub(url, '')
            return [url, rest_text.strip]
          else
            return nil
          end
        end

        def li_value(value)
          result = extract_url(value)

          if result
            "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{link_to(result[1], result[0], :target => '_blank' ) }"
          else
            auto_link(value, :html => { :target => '_blank' }) do |link|
              "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{link}"
            end
          end
        end
    
    end
  end
end
