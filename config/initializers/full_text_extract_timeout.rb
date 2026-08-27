# frozen_string_literal: true

module FullTextExtractTimeout
  private

    def http_request
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: check_for_ssl,
                      open_timeout: 300,
                      read_timeout: 7200) do |http|
        req = Net::HTTP::Post.new(uri.request_uri, request_headers)
        req.basic_auth uri.user, uri.password unless uri.password.nil?
        req.body = file_content
        http.request req
      end
    end
end

Rails.application.config.to_prepare do
  processor = Hydra::Derivatives::Processors::FullText
  processor.prepend(FullTextExtractTimeout) unless processor.ancestors.include?(FullTextExtractTimeout)
end
