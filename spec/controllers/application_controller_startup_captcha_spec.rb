require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'ok'
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
    allow(controller).to receive(:startup_captcha_enabled?).and_return(true)
    allow(controller).to receive(:controller_name).and_return('anonymous')
    allow(controller).to receive(:startup_captcha_skip_path?).and_return(false)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('STARTUP_CAPTCHA_SKIP_PATHS', '').and_return('')
  end

  describe 'startup_captcha_skip_ip?' do
    it 'omite gatekeeper cuando la IP cae en un CIDR permitido' do
      allow(ENV).to receive(:fetch).with('STARTUP_CAPTCHA_SKIP_IPS', '').and_return('172.16.0.0/16')
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('172.16.4.20')

      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'redirige al captcha cuando la IP no cae en el CIDR permitido' do
      allow(ENV).to receive(:fetch).with('STARTUP_CAPTCHA_SKIP_IPS', '').and_return('172.16.0.0/16')
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('200.10.10.5')

      get :index

      expect(response).to redirect_to('/startup_captcha')
    end

    it 'no rompe flujo cuando el CIDR esta mal configurado' do
      allow(ENV).to receive(:fetch).with('STARTUP_CAPTCHA_SKIP_IPS', '').and_return('valor_invalido')
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('172.16.4.20')

      get :index

      expect(response).to redirect_to('/startup_captcha')
    end
  end
end
