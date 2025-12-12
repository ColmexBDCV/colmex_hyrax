# frozen_string_literal: true

# Polyfill para Ruby 2.7 que reemplaza URI.decode (deprecado en Ruby 2.4 y removido en Ruby 3.0)
# con una implementación compatible basada en CGI.unescape

module URI
  class << self
    unless method_defined?(:decode)
      def decode(str)
        require 'cgi'
        CGI.unescape(str)
      end
    end
  end
end
