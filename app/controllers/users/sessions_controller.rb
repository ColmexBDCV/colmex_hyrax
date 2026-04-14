class Users::SessionsController < Devise::SessionsController
  # Cuando el usuario visita la página de login manualmente (sin ser redirigido
  # por authenticate_user!), Devise no guarda la URL anterior. Este override lo
  # hace explícitamente usando el Referer HTTP.
  def new
    if request.referer.present?
      referer_uri = URI.parse(request.referer)
      # Solo guardar si el referer es de la misma app y no es otra página de sesión
      if referer_uri.host == request.host && !referer_uri.path.start_with?('/users/')
        store_location_for(:user, request.referer)
      end
    end
    super
  rescue URI::InvalidURIError
    super
  end
end
