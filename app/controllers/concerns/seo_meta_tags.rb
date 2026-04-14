module SeoMetaTags
  extend ActiveSupport::Concern

  included do
    before_action :set_default_seo_meta_tags
    helper_method :seo_indexable?, :seo_json_ld
  end

  private

  def set_default_seo_meta_tags
    set_meta_tags(
      site: I18n.t('hyrax.product_name'),
      title: seo_page_title,
      reverse: true,
      separator: '|',
      description: seo_description,
      keywords: seo_keywords,
      canonical: seo_canonical_url,
      noindex: !seo_indexable?,
      nofollow: !seo_indexable?,
      og: {
        title: seo_page_title,
        description: seo_description,
        type: seo_og_type,
        url: seo_canonical_url,
        site_name: I18n.t('hyrax.product_name'),
        locale: I18n.locale.to_s
      },
      twitter: {
        card: 'summary_large_image',
        title: seo_page_title,
        description: seo_description
      }
    )
  end

  def seo_page_title
    return seo_document_title if seo_document_title.present?
    return "#{I18n.t('blacklight.search.title')} #{params[:q]}" if controller_name == 'catalog' && action_name == 'index' && params[:q].present?
    return I18n.t('hyrax.product_name') if controller_name == 'homepage' && action_name == 'index'

    "#{controller_name.humanize} #{action_name.humanize}"
  end

  def seo_description
    doc_description = seo_document_description
    return helpers.truncate(doc_description, length: 180) if doc_description.present?

    I18n.t('hyrax.product_name')
  end

  def seo_keywords
    base_keywords = ['repositorio', 'biblioteca digital', I18n.t('hyrax.product_name')]
    return base_keywords.join(', ') unless controller_name == 'catalog' && params[:q].present?

    (base_keywords + [params[:q]]).join(', ')
  end

  def seo_canonical_url
    filtered_params = seo_canonical_query_params
    uri = URI.parse(request.original_url)
    uri.query = filtered_params.to_query.presence
    uri.to_s
  rescue URI::InvalidURIError
    "#{request.base_url}#{request.path}"
  end

  def seo_og_type
    return 'article' if action_name == 'show'

    'website'
  end

  def seo_indexable?
    return false if Rails.env.development? || Rails.env.test?
    return false if catalog_search_noise_page?

    blocked_prefixes = %w[/users /admin /jobs /dashboard /notifications]
    blocked_prefixes.none? { |prefix| request.path.start_with?(prefix) }
  end

  def seo_json_ld
    return nil unless action_name == 'show' && defined?(@presenter)

    title = Array(@presenter.try(:title)).first
    return nil if title.blank?

    description = Array(@presenter.try(:description)).first
    creators = Array(@presenter.try(:creator)).compact
    published_date = Array(@presenter.try(:date_created)).first
    thumbnail = fetch_document_value(@presenter.solr_document, 'thumbnail_path_ss')

    json_ld = {
      '@context' => 'https://schema.org',
      '@type' => 'CreativeWork',
      'name' => title,
      'description' => helpers.truncate(description.to_s, length: 300),
      'url' => seo_canonical_url,
      'inLanguage' => I18n.locale.to_s,
      'isAccessibleForFree' => true,
      'publisher' => {
        '@type' => 'Organization',
        'name' => I18n.t('hyrax.product_name')
      }
    }

    json_ld['author'] = creators.map { |name| { '@type' => 'Person', 'name' => name } } if creators.present?
    json_ld['datePublished'] = published_date if published_date.present?
    json_ld['image'] = absolute_url(thumbnail) if thumbnail.present?
    json_ld
  end

  def seo_document_title
    return unless action_name == 'show'

    if defined?(@presenter) && @presenter.respond_to?(:title)
      Array(@presenter.title).first
    elsif defined?(@document)
      Array(fetch_document_value(@document, 'title_tesim', 'title_ssim', 'title_tsim')).first
    end
  end

  def seo_document_description
    return unless action_name == 'show'

    if defined?(@presenter) && @presenter.respond_to?(:description)
      Array(@presenter.description).first
    elsif defined?(@document)
      Array(fetch_document_value(@document, 'description_tesim', 'description_tsim', 'abstract_tesim')).first
    end
  end

  def fetch_document_value(document, *fields)
    fields.each do |field|
      value = document[field]
      return value if value.present?
    end

    nil
  end

  def seo_canonical_query_params
    if controller_name == 'catalog' && action_name == 'index'
      request.query_parameters.slice('q', 'search_field').except('locale', 'utf8', 'commit')
    else
      request.query_parameters.except('utf8', 'commit', 'locale', 'page').except(:utf8, :commit, :locale, :page)
    end
  end

  def catalog_search_noise_page?
    return false unless controller_name == 'catalog' && action_name == 'index'

    params[:f].present? || params[:sort].present? || params[:per_page].present? || params[:page].to_i > 1
  end

  def absolute_url(path)
    return path if path.to_s.match?(%r{\Ahttps?://})

    URI.join(request.base_url, path.to_s).to_s
  rescue URI::InvalidURIError
    path
  end
end