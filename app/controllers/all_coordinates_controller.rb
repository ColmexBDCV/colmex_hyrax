
class AllCoordinatesController < ApplicationController
    def initialize
        @solr = RSolr.connect :url => ENV["SOLR_URL"]
        @g_username = Qa::Authorities::Geonames.username
    end
  
    def fetch_docs
        @num_pages = get_num_pages
        docs = get_docs
        render :json => docs
       
        
    end
  
    def get_num_pages
       
        response = @solr.paginate 1, 0, 'select', :params => {:q => params[:query], :fl => 'id'}
        data = JSON.parse(response.response[:body])
        num_docs = data["response"]["numFound"]
        return 1 if num_docs <= 10
        num = num_docs/10
        num +=1 if num_docs%10 > 0
        return num

    end

    def get_docs
        params[:fields] = "id, title_tesim, based_near_tesim" unless params.key?("fields")
        params[:fields] += ", based_near_tesim" unless params[:fields].include?("based_near_tesim")
        all_docs = []
        (1..@num_pages).each do |page|
            response = @solr.paginate page, 10, 'select', :params => {:q => params[:query], :fl => params[:fields]}
            data = JSON.parse(response.response[:body])
            docs = []
            data["response"]["docs"].each do |doc|
                if doc.key?("based_near_tesim") then
                    coordinates = []
                    doc["based_near_tesim"].each do |c| 
                        coordinates.push(get_coordinates(c.split("/").last))
                    end
                    doc["coordinates"] = coordinates
                    docs.push(doc)
                end
                
            end
            all_docs.push(*docs)
        end
        return all_docs
    end
   
    def get_coordinates(geonames_id)
        begin    
            conn = Faraday.new :url =>"http://api.geonames.org/getJSON?geonameId=#{geonames_id}&username=#{@g_username}"
            data = JSON.parse(conn.get.body.force_encoding('utf-8'))
        rescue Faraday::ConnectionFailed 
            retry
        end
        return {lat: data["lat"], lng: data["lng"]}
        
    end

end  