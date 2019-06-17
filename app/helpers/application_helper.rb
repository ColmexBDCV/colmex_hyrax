module ApplicationHelper
    def link_to_alma(options={})
        url_prefix = 'http://colmex-primo.hosted.exlibrisgroup.com/primo_library/libweb/action/dlSearch.do?search_scope=52COLMEX_ALL&institution=52COLMEX&vid=52COLMEX_INST&query=any,contains,'
        safe_join(options[:value].map { |i| link_to("#{i}", "#{url_prefix}#{i}") }, ", ".html_safe)
    end
end
