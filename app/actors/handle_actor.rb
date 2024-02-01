class HandleActor < Hyrax::Actors::AbstractActor
    
    def create(env)
        begin
            host = ENV.fetch('URL')
        rescue => e
            host = nil
        end

        if Rails.env.production? && host == "https://repositorio.colmex.mx"

            next_actor.create(env).tap do |success|
                if success
                    obj = env.curation_concern
                    url =Rails.application.routes.url_helpers.polymorphic_url(obj, host: "https://repositorio.colmex.mx")  # Obtener la URL de la vista del objeto creado
                    if obj.handle.nil?
                        handle = HandleService.create url
                        if handle["handleDesc"] == "SUCCESS"
                            obj.handle = handle["url"].sub("http","https")
                            obj.save
                        end
                    end
                end
            end  
        else
            next_actor.create(env)
        end


    end
    
    def destroy(env)
        begin
            host = ENV.fetch('URL')
        rescue => e
            host = nil
        end

        if Rails.env.production? && host == "https://repositorio.colmex.mx"
            url = "https://hdl.handle.net/"
            
            HandleService.delete(env.curation_concern.handle.gsub(url,""))
        end

        next_actor.destroy(env)
    end

end
   