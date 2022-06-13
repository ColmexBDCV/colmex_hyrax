
class AllCoordinatesController < ApplicationController
    def initialize
        @solr = RSolr.connect :url => ENV["SOLR_URL"] || "http://127.0.0.1:8983/solr/hydra-development"
        # @g_username = Qa::Authorities::Geonames.username
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
        params[:fields] = "id, title_tesim, based_near_tesim, based_near_label_tesim,based_near_coordinates_tesim" unless params.key?("fields")
        params[:fields] += ", based_near_tesim, based_near_label_tesim,based_near_coordinates_tesim" unless params[:fields].include?("based_near_tesim")
        all_docs = []
        (1..@num_pages).each do |page|
            response = @solr.paginate page, 10, 'select', :params => {:q => params[:query], :fl => params[:fields]}
            data = JSON.parse(response.response[:body])
            docs = []
            data["response"]["docs"].each do |doc|
                if doc.key?("based_near_coordinates_tesim") then
                    docs.push(doc)
                end
                
            end
            all_docs.push(*docs)
        end
        return all_docs
    end
end  