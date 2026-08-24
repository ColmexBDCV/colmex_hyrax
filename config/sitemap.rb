sitemap_host = ENV['SEO_HOST'].presence || ENV['URL'].presence || 'https://repositorio.colmex.mx'
normalized_host = sitemap_host.match?(%r{\Ahttps?://}) ? sitemap_host : "https://#{sitemap_host}"

SitemapGenerator::Sitemap.default_host = normalized_host
SitemapGenerator::Sitemap.public_path = 'public/'

SitemapGenerator::Sitemap.create(include_root: false) do
  add_public_documents = lambda do |model_names, path_prefix|
    model_names.each do |model_name|
      escaped_models = "\"#{model_name}\""
      query = "has_model_ssim:(#{escaped_models}) AND visibility_ssi:open"

      start = 0
      batch_size = 500

      loop do
        results = ActiveFedora::SolrService.get(
          query,
          rows: batch_size,
          start: start,
          fl: 'id,system_modified_dtsi'
        )

        docs = results.dig('response', 'docs') || []
        break if docs.empty?

        docs.each do |doc|
          lastmod = doc['system_modified_dtsi'].presence
          add "#{path_prefix.call(model_name)}/#{doc['id']}", changefreq: 'weekly', priority: 0.7, lastmod: lastmod
        end

        start += batch_size
        total = results.dig('response', 'numFound').to_i
        break if start >= total
      end
    end
  end

  work_models = Hyrax.config.curation_concerns.map(&:to_s)
  add_public_documents.call(work_models, ->(model_name) { "/concern/#{model_name.underscore.pluralize}" }) if work_models.present?
end
