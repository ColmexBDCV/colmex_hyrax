class ValidationsMailer < ActionMailer::Base
    default from: 'notificationsOfCSV@colmex.com'

    def notificacion_validacion_email
        @user_aprove = params[:user]
        user_to_sent_email = params[:userAdmin]
        @type_work = params[:type_work]
        filename = params[:filename]
        attachments.inline[filename] = File.read(params[:path])
        mail(to: @user_to_sent_email,cc: @user_aprove, subject: 'Notificación de un Archivo CSV Aprobado')
    end
    
end