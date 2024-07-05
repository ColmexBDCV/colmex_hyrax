module ApplicationHelper
  def link_to_alma(options={})
      # url_prefix = 'http://colmex-primo.hosted.exlibrisgroup.com/primo_library/libweb/action/dlSearch.do?search_scope=52COLMEX_ALL&institution=52COLMEX&vid=52COLMEX_INST&query=any,contains,'
      #safe_join(options[:value].map { |i| link_to("#{i}", "#{url_prefix}#{i}") }, ", ".html_safe)
      safe_join(options[:value].map { |i| is_in_alma?(i).html_safe }, ", ".html_safe)
  end


  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def get_segment(number)
    request.path.split("/")[number]
  end

  def show_search
    segment = ['dashboard', 'lease', 'admin', 'embargoes', 'content_blocks', 'pages']
    segment.include? get_segment(1)
  end

  def is_in_alma?(value)
    conn = Faraday.new :headers => { :accept => "application/json"}
    begin
      #a = conn.get "action/dlSearch.do?search_scope=52COLMEX_ALL&institution=52COLMEX&vid=52COLMEX_INST&query=any,contains,#{value}"
      url = "https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs?mms_id=#{value}&view=full&expand=p_avail&apikey=l8xx839588162ee7496e8b0e9e6c7fec4a89"
      a = conn.get url
      begin
        data = JSON.parse(a.body.force_encoding('utf-8'))
      rescue
        return value
      end
      if data.key?("bib") then
        %(<a href=http://colmex-primo.hosted.exlibrisgroup.com/primo_library/libweb/action/dlSearch.do?search_scope=52COLMEX_ALL&institution=52COLMEX&vid=52COLMEX_INST&query=any,contains,#{value} target="_blank">#{value}</a>)
      else
        value
      end
    rescue Faraday::ConnectionFailed
      value
    end
  end

  def link_to_parent_works(document)
    ids = document[:document]['parent_work_ids_ssim'] || []
    titles = document[:document]['parent_work_titles_tesim'] || []

    if ids.empty? || titles.empty?
      return 'No parent works available'
    end

    links = ids.zip(titles).map do |id, title|
      link_to title, Rails.application.routes.url_helpers.hyrax_generic_work_path(id)
    end
    safe_join(links, ', ')
  end
end
