class AllCoordinatesController < ApplicationController
    def fetch_docs
      @num_pages = get_num_pages
      docs = get_docs
      render json: docs
    end
  
    private
  
    def solr
      @solr ||= RSolr.connect(url: ENV["SOLR_URL"] || "http://127.0.0.1:8983/solr/hydra-development")
    end
  
    def get_num_pages
      response = solr.paginate 1, 0, 'select', params: {q: params[:query], fl: 'id'}
      data = JSON.parse(response.response[:body])
      num_docs = data["response"]["numFound"]
      num_docs <= 10 ? 1 : (num_docs / 10.0).ceil
    end
  
    def get_docs
      params[:fields] = "id, title_tesim, based_near_tesim, based_near_label_tesim,based_near_coordinates_tesim" unless params.key?("fields")
      params[:fields] += ", based_near_tesim, based_near_label_tesim,based_near_coordinates_tesim" unless params[:fields].include?("based_near_tesim")
      all_docs = []
      (1..@num_pages).each do |page|
        response = solr.paginate page, 10, 'select', params: {q: params[:query], fl: params[:fields]}
        data = JSON.parse(response.response[:body])
        docs = data["response"]["docs"].select { |doc| doc.key?("based_near_coordinates_tesim") }
        all_docs.concat(docs)
      end
      all_docs
    end
  end
  