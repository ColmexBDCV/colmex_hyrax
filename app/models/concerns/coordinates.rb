module Coordinates
      
    def to_solr(solr_doc={})
        solr_doc = super
        if solr_doc.key?("based_near_tesim") then
            coordinates = []
            solr_doc["based_near_tesim"].each do |c| 
                coordinates.push(get_coordinates(c.split("/").last))
            end
            solr_doc = solr_doc.merge({'based_near_coordinates_tesim' => coordinates})
            
        end
        solr_doc
    end
    

    def get_coordinates(geonames_id)
        g_username = Qa::Authorities::Geonames.username
        begin    
            conn = Faraday.new :url =>"http://api.geonames.org/getJSON?geonameId=#{geonames_id}&username=#{g_username}"
            data = JSON.parse(conn.get.body.force_encoding('utf-8'))
        rescue Faraday::ConnectionFailed 
            retry
        end
        return "#{data["lat"]}|#{data["lng"]}"
        
    end
end