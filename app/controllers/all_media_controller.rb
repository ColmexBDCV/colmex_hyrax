class AllMediaController < ApplicationController

    def get_media
        begin
            file_set = FileSet.find(params[:id])
        # Procesa el file_set, como renderizar un JSON o una vista
        rescue ActiveFedora::ObjectNotFoundError
            render json: { error: "FileSet not found" }, status: :not_found
        end
     end

    private
        def get_all()
            
        end

        def get_derivatives(file_set)

            derivatives = Hyrax::DerivativePath.derivatives_for_reference(file_set) 
                   
            tags = []
            derivatives.each { |d| tags.push d.split(".").first.split("-").last } 
            tags.delete("thumbnail")
            tags.sort!
            tags.reverse! if tags.first == "360p"
            links = []

            tags.each do |tag|
                links.push [hyrax.download_path(file_set, file: tag), tag]
            end

            render :json => links 
        end

end