class ValidationsController < ApplicationController
    with_themed_layout 'dashboard'
    def index
        @validation_csvs = ValidationCsv.all
        @user = current_user
        @path = Rails.root
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.validation_csv'), request.path
    end
    skip_before_action :verify_authenticity_token
    def create
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.validation_csv'), request.path
        users = ['rod.youkai@gmail.com',params[:validations][:user]]
        type_work = params[:validations][:type_work]
        path = params[:validations][:file].path
        original_name = params[:validations][:original_name]
        filename = params[:validations][:new_name]
        uploadFileToRoot filename, path

        @validation_csv = ValidationCsv.new(validation_csv_params)
        if @validation_csv.save
            #Manda un correo desde el controlador validations_mailer y se le manda como parametro lo que esta
            #dentro del método with, después se le especifíca qué método del controlador es el tipo de correo o plantilla que se
            #mandará al correo, y finalmente se pone el método que lo manda al instante o puede ser diferente
            users.each do |user|
                ValidationsMailer.with(user: user,user_validate: params[:validations][:user],type_work: type_work, filename: filename, path: path).notificacion_validacion_email.deliver_now
            end
            flash[:notice] = "El archivo '#{original_name}' ha sido guardado y enviado como '#{filename}' al administrador con éxito"
            redirect_to validations_path
        else
            flash[:error] = "Algo salió mal en el guardado del archivo, verifique que no se ha subido antes"
        end
    end

    def destroy
        @validations = ValidationCsv.find(params[:id])
        deleteFileOfRoot @validations.path_file_csv
        @validations.destroy
        flash[:notice] = "Archivo que se quiere borrar #{@validations.new_name}"
        redirect_to validations_path
        
    end

    def uploadFileToRoot filename, path
        content = File.read(path)
        File.write(Rails.root + filename ,content)
    end
    
    def deleteFileOfRoot path
        File.delete(path)
    end
    
    
    private
        def validation_csv_params
            params.require(:validations).permit(:user,:original_name, :new_name, :type_work,:path_file_csv)
        end 
end