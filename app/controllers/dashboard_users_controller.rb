class DashboardUsersController < ApplicationController
  # Opciones permitidas para cantidad de usuarios por pagina.
  PER_PAGE_OPTIONS = [10, 20, 50, 100].freeze

  # Nombre del rol administrativo usado por Hydra::RoleManagement.
  ADMIN_ROLE_NAME = 'admin'.freeze

  with_themed_layout 'dashboard'

  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: [:edit, :update, :destroy]

  # Lista usuarios registrados para administrarlos desde el dashboard.
  def index
    @per_page = PER_PAGE_OPTIONS.include?(params[:per_page].to_i) ? params[:per_page].to_i : 10
    @users = ordered_users.page(params[:page]).per(@per_page)
    add_dashboard_breadcrumbs('Usuarios')
  end

  # Muestra el formulario para registrar usuarios desde el dashboard.
  def new
    @user = User.new
    add_dashboard_breadcrumbs('Registrar usuario')
  end

  # Registra un usuario sin abrir el registro publico de Devise.
  def create
    @user = User.new(user_params)
    add_dashboard_breadcrumbs('Registrar usuario')

    if save_user_with_admin_role(@user)
      redirect_to dashboard_users_path, notice: 'Usuario registrado correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Muestra el formulario de edicion para un usuario registrado.
  def edit
    add_dashboard_breadcrumbs('Editar usuario')
  end

  # Actualiza los datos del usuario y deja la contrasena igual si viene vacia.
  def update
    add_dashboard_breadcrumbs('Editar usuario')

    if update_user_with_admin_role(@user)
      redirect_to dashboard_users_path, notice: 'Usuario actualizado correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Elimina un usuario registrado desde el dashboard.
  def destroy
    if @user.id == current_user.id
      redirect_to dashboard_users_path, alert: 'No puedes eliminar tu propio usuario.'
    else
      @user.destroy
      redirect_to dashboard_users_path, notice: 'Usuario eliminado correctamente.'
    end
  end

  private

    # Busca el usuario que se va a editar o eliminar.
    def set_user
      @user = User.find(params[:id])
    end

    # Rechaza altas hechas por usuarios sin permisos administrativos.
    def require_admin!
      raise Hydra::AccessDenied unless current_user.admin?
    end

    # Ordena primero el usuario actual y despues el resto por correo.
    def ordered_users
      # ponytail: CASE por id basta para destacar el usuario actual; si cambia el motor DB, revisar esta expresion.
      User.order(Arel.sql("CASE WHEN id = #{current_user.id.to_i} THEN 0 ELSE 1 END"))
          .order(created_at: :desc, email: :asc)
    end

    # Guarda el usuario y aplica el rol admin solicitado.
    def save_user_with_admin_role(user)
      User.transaction do
        return false unless user.save

        sync_admin_role(user)
      end
      true
    end

    # Actualiza el usuario y aplica el rol admin solicitado.
    def update_user_with_admin_role(user)
      User.transaction do
        return false unless user.update(user_update_params)

        sync_admin_role(user)
      end
      true
    end

    # Agrega o quita el rol admin segun el formulario.
    def sync_admin_role(user)
      admin_role = Role.find_or_create_by!(name: ADMIN_ROLE_NAME)

      if admin_requested?
        user.roles << admin_role unless user.roles.exists?(admin_role.id)
      elsif user.id != current_user.id
        user.roles.delete(admin_role)
      end
    end

    # Lee el checkbox admin del formulario como booleano.
    def admin_requested?
      ActiveRecord::Type::Boolean.new.cast(params.dig(:user, :admin))
    end

    # Agrega migas consistentes con el resto del dashboard.
    def add_dashboard_breadcrumbs(current_label)
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb current_label, request.path
    end

    # Lista blanca de datos que puede capturar un administrador.
    def user_params
      params.require(:user).permit(
        :email,
        :password,
        :password_confirmation,
        :firstname,
        :paternal_surname,
        :maternal_surname,
        :phone
      )
    end

    # Lista blanca para editar usuarios sin forzar cambio de contrasena.
    def user_update_params
      permitted = user_params
      if permitted[:password].blank?
        permitted.delete(:password)
        permitted.delete(:password_confirmation)
      end
      permitted
    end
end
