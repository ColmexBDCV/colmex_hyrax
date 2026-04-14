class StartupCaptchaController < ApplicationController
  skip_before_action :enforce_startup_captcha

  def show
  end

  def verify
    unless turnstile_configured?
      flash.now[:alert] = 'Turnstile no esta configurado en el servidor.'
      return render :show, status: :unprocessable_entity
    end

    unless verify_turnstile_response(params['cf-turnstile-response'])
      flash.now[:alert] = 'Verificacion fallida. Por favor intenta nuevamente.'
      return render :show, status: :unprocessable_entity
    end

    session[:startup_captcha_passed] = true
    redirect_to(session.delete(:startup_captcha_return_to).presence || root_path)
  end
end
