sitemap_host = ENV['SEO_HOST'].presence || ENV['URL'].presence || 'example.com'
normalized_host = sitemap_host.match?(%r{\Ahttps?://}) ? sitemap_host : "https://#{sitemap_host}"

SitemapGenerator::Sitemap.default_host = normalized_host
SitemapGenerator::Sitemap.public_path = 'public/'

SitemapGenerator::Sitemap.create do
  add_public_documents = lambda do |model_names|
    escaped_models = model_names.map { |name| "\"#{name}\"" }.join(' OR ')
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
        add "/catalog/#{doc['id']}", changefreq: 'weekly', priority: 0.7, lastmod: lastmod
      end

      start += batch_size
      total = results.dig('response', 'numFound').to_i
      break if start >= total
    end
  end

  add '/', changefreq: 'daily', priority: 1.0
  add '/catalog', changefreq: 'daily', priority: 0.8
  add '/iiif/collection', changefreq: 'weekly', priority: 0.6
  add '/subject_cloud', changefreq: 'weekly', priority: 0.5
  add '/timeline_map', changefreq: 'weekly', priority: 0.5
  add '/descargas', changefreq: 'weekly', priority: 0.4

  work_models = Hyrax.config.curation_concerns.map(&:to_s)
  add_public_documents.call(work_models) if work_models.present?
  add_public_documents.call(['Collection'])
end
