require 'nokogiri'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include Hyrax::WorkFormHelper
  include Hyrax::WorkflowsHelper
  
  def build_citation(presenter)
    if presenter.resource_type.include? "Tesis" then
      "#{build_authors(presenter)} (#{presenter.date_created.first}), #{presenter} (#{presenter.resource_type.first}), El Colegio de México, México"
    end
  end

  def build_authors(presenter)
    s = ""
    presenter.creator.each do |a|
      n = a.split(', ')
      s = s + [ n[0], n[1][0] ].join(" ")+"., "
    end

    presenter.contributor.each do |a|
      n = a.split(', ')
      s = s + [ n[0], n[1][0] ].join(" ")+"., "
    end
    
    return s.chomp(", ")
  end
  

  #apply locale config to sort_fields
  def translate_sort_fields(sort_fields)
    tsf = []
    sort_fields.each do |f|
      tsf.push( [t('blacklight.search.sort.'+f[0]), f[1]])
    end
    return tsf
  end

  def metadata_dl_to_table(definition_list_html, presenter:)
    fragment = Nokogiri::HTML::DocumentFragment.parse("<wrapper>#{definition_list_html}</wrapper>")
    rows = fragment.css('dt').map do |dt|
      dd = dt.xpath('following-sibling::dd').first
      next unless dd

      content_tag(:tr) do
        content_tag(:th,
                    dt.inner_html.html_safe,
                    scope: 'row',
                    class: 'metadata-label text-nowrap',
                    style: 'width: 1%; white-space: nowrap; border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6; border-left: 0; border-right: 0;') +
          content_tag(:td,
                      dd.inner_html.html_safe,
                      style: 'border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6; border-left: 0; border-right: 0;')
      end
    end.compact

    header = content_tag(:thead) do
      content_tag(:tr) do
        content_tag(:th,
                    t('hyrax.base.metadata_table.headers.attribute', default: 'Attribute'),
                    scope: 'col',
                    class: 'metadata-label text-nowrap',
                    style: 'width: 1%; white-space: nowrap; border-top: 0; border-bottom: 2px solid #dee2e6; border-left: 0; border-right: 0;') +
          content_tag(:th,
                      t('hyrax.base.metadata_table.headers.value', default: 'Value'),
                      scope: 'col',
                      class: 'metadata-value-header',
                      style: 'border-top: 0; border-bottom: 2px solid #dee2e6; border-left: 0; border-right: 0;')
      end
    end

    table_classes = ["table", "table-striped", "metadata-table", "work-show", dom_class(presenter)].uniq.join(' ')
    raw_attrs = presenter.microdata_type_to_html
    table_attributes = raw_attrs.present? ? raw_attrs : ''

    metadata_attrs = metadata_table_attributes(table_attributes)
    table_style = 'border: 1px solid #dee2e6; border-collapse: separate; border-spacing: 0;'
    metadata_attrs[:style] = [metadata_attrs[:style], table_style].compact.join(' ')

    content_tag(:table, { class: table_classes }.merge(metadata_attrs)) do
      safe_join([
        header,
        content_tag(:tbody, safe_join(rows))
      ])
    end
  end

  def readme_file_set_presenter(presenter)
    presenter.member_presenters_for(presenter.ordered_ids).find do |member|
      next unless member.model_name.name == 'FileSet'

      title = member.try(:first_title).to_s
      File.extname(title).casecmp('.txt').zero?
    end
  end

  def readme_content_for(presenter)
    readme_presenter = readme_file_set_presenter(presenter)
    return unless readme_presenter

    return unless can?(:read, readme_presenter.id)

    file_set = ::FileSet.find(readme_presenter.id)
    original_file = file_set&.original_file
    raw_content = original_file&.content
    content = if raw_content.respond_to?(:read)
                raw_content.read
              else
                raw_content.to_s
              end

    content = content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    content
  rescue StandardError => e
    Rails.logger.warn("Unable to load README for presenter #{presenter.id}: #{e.message}")
    nil
  end

  private

  def metadata_table_attributes(raw_attributes)
    return {} if raw_attributes.blank?

    Nokogiri::HTML::DocumentFragment.parse("<table #{raw_attributes}></table>").children.first.attributes.each_with_object({}) do |(name, attribute), memo|
      value = attribute.value.presence || name
      memo[name.to_sym] = value
    end
  end
end
