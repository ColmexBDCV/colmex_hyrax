class AllMediaController < ApplicationController

    def get_media
        file_set = FileSet.find params[:id]
        
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