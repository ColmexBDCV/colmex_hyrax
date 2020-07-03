module ApplicationHelper
    def link_to_alma(options={})
        # url_prefix = 'http://colmex-primo.hosted.exlibrisgroup.com/primo_library/libweb/action/dlSearch.do?search_scope=52COLMEX_ALL&institution=52COLMEX&vid=52COLMEX_INST&query=any,contains,'
        #safe_join(options[:value].map { |i| link_to("#{i}", "#{url_prefix}#{i}") }, ", ".html_safe)
        safe_join(options[:value].map { |i| is_in_alma?(i).html_safe }, ", ".html_safe)
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
        url = "https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs?mms_id=#{value}&view=full&expand=p_avail&apikey=l7xx5066e7c1fe3e4d549f87aac7e976440e"
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
end
