class ValidationsMailer < ActionMailer::Base
    default from: 'notificationsOfCSV@colmex.com'

    def notificacion_validacion_email
        user= params[:user]
        @user_validate = params[:user_validate]
        @type_work = params[:type_work]
        filename = params[:filename]
        attachments.inline[filename] = File.read(params[:path])
        
        mail(to: user, subject: 'Notificación de un Archivo CSV Aprobado')
    end
    
end