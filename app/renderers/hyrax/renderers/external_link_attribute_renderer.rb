module Hyrax
  module Renderers
    class ExternalLinkAttributeRenderer < AttributeRenderer
      require 'uri'

      private

        def remove_uri_segments(url)
          uri = URI.parse(url)
          uri.path = '/'
          uri.query = nil
          uri.fragment = nil
          uri.to_s
        end

        def extract_url(text)
          url_regex = /(https?:\/\/[^\s]+)|(www\.[^\s]+)/
          match = url_regex.match(text)
          if match
            url = match[0]
            rest_text = text.gsub(url, '')
            unless url.include? "https://"
              url = "https://"+url              
            end
            return [url, rest_text.strip]
          else
            return nil
          end
        end

        def li_value(value)
          result = extract_url(value)
          
          return value if result.nil?

          if result && result[1] != ""
            "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{link_to(result[1], result[0], :target => '_blank' ) }"
          else
            auto_link(result[0], :html => { :target => '_blank' }) do |link|
              "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{remove_uri_segments(link)}"
            end
          end
        end
    
    end
  end
end
