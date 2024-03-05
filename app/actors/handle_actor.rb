# Definición de la clase HandleActor
class HandleActor < Hyrax::Actors::AbstractActor
    
    # Método para crear un objeto
    def create(env)
        # Solo ejecutar en el entorno de producción y cuando el host es específico
        if en_produccion_y_host_correcto?
            next_actor.create(env).tap do |success|
                if success
                    obj = env.curation_concern
                    # Obtener la URL del objeto
                    url = Rails.application.routes.url_helpers.polymorphic_url(obj, host: "https://repositorio.colmex.mx")
                    # Crear un handle si no existe
                    if obj.handle.nil?
                        handle = HandleService.create(url)
                        if handle["handleDesc"] == "SUCCESS"
                            obj.handle = handle["url"].sub("http", "https")
                            obj.save
                        end
                    end
                end
            end
        else
            next_actor.create(env)
        end
    end
    
    # Método para destruir un objeto
    def destroy(env)
        # Solo ejecutar en el entorno de producción y cuando el host es específico
        if en_produccion_y_host_correcto?
            url = "https://hdl.handle.net/"
            HandleService.delete(env.curation_concern.handle.gsub(url, ""))
        end

        next_actor.destroy(env)
    end

    private

    # Método para verificar si está en producción y el host es el correcto
    def en_produccion_y_host_correcto?
        Rails.env.production? && ENV.fetch('URL', nil) == "https://repositorio.colmex.mx"
    end
end
