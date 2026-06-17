require 'rails_helper'

RSpec.describe DashboardUsersController, type: :controller do
  let(:admin) { instance_double('User', id: 999, admin?: true, persisted?: true) }

  let(:valid_params) do
    {
      user: {
        email: 'nuevo@colmex.mx',
        password: 'password123',
        password_confirmation: 'password123',
        firstname: 'Nuevo'
      }
    }
  end

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
  end

  describe 'GET #index' do
    it 'responde correctamente para administradores' do
      User.create!(valid_params[:user])

      get :index

      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@users)).not_to be_empty
    end

    it 'usa per_page permitido cuando se envia' do
      User.create!(valid_params[:user])

      get :index, params: { per_page: 20 }

      expect(controller.instance_variable_get(:@per_page)).to eq(20)
      expect(controller.instance_variable_get(:@users).limit_value).to eq(20)
    end

    it 'usa 10 cuando per_page no es permitido' do
      User.create!(valid_params[:user])

      get :index, params: { per_page: 15 }

      expect(controller.instance_variable_get(:@per_page)).to eq(10)
      expect(controller.instance_variable_get(:@users).limit_value).to eq(10)
    end

    it 'muestra primero el usuario actual' do
      current_admin = User.create!(valid_params[:user].merge(email: 'z-admin@colmex.mx'))
      User.create!(valid_params[:user].merge(email: 'a-user@colmex.mx'))
      allow(current_admin).to receive(:admin?).and_return(true)
      allow(controller).to receive(:current_user).and_return(current_admin)

      get :index

      expect(controller.instance_variable_get(:@users).first).to eq(current_admin)
    end

    it 'muestra primero los usuarios mas recientes despues del usuario actual' do
      current_admin = User.create!(valid_params[:user].merge(email: 'admin@colmex.mx'))
      old_user = User.create!(valid_params[:user].merge(email: 'old@colmex.mx', created_at: 2.days.ago))
      new_user = User.create!(valid_params[:user].merge(email: 'new@colmex.mx', created_at: 1.day.ago))
      allow(current_admin).to receive(:admin?).and_return(true)
      allow(controller).to receive(:current_user).and_return(current_admin)

      get :index

      expect(controller.instance_variable_get(:@users).to_a).to eq([current_admin, new_user, old_user])
    end

    it 'genera enlaces de acciones con id numerico' do
      user = User.create!(valid_params[:user].merge(email: 'rod.youkai@gmail.com'))

      expect(edit_dashboard_user_path(id: user.id)).to include("/dashboard/users/#{user.id}/edit")
      expect(dashboard_user_path(id: user.id)).to include("/dashboard/users/#{user.id}")
    end
  end

  describe 'GET #new' do
    it 'responde correctamente para administradores' do
      get :new

      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    it 'crea el usuario' do
      expect { post :create, params: valid_params }.to change(User, :count).by(1)

      expect(response).to redirect_to(dashboard_users_path)
      expect(User.last.email).to eq('nuevo@colmex.mx')
    end

    it 'crea usuarios administradores cuando se solicita' do
      post :create, params: { user: valid_params[:user].merge(admin: '1') }

      expect(User.last).to be_admin
    end

    it 'rechaza parametros invalidos' do
      expect {
        post :create, params: { user: valid_params[:user].merge(email: '') }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'requiere nombre' do
      expect {
        post :create, params: { user: valid_params[:user].merge(firstname: '') }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'requiere confirmacion de contrasena' do
      expect {
        post :create, params: { user: valid_params[:user].merge(password_confirmation: '') }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET #edit' do
    it 'responde correctamente para administradores' do
      user = User.create!(valid_params[:user])

      get :edit, params: { id: user.id }

      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@user)).to eq(user)
    end
  end

  describe 'PATCH #update' do
    it 'actualiza datos sin cambiar contrasena' do
      user = User.create!(valid_params[:user])

      patch :update, params: { id: user.id, user: { email: user.email, firstname: 'Actualizado', password: '', password_confirmation: '' } }

      expect(response).to redirect_to(dashboard_users_path)
      expect(user.reload.firstname).to eq('Actualizado')
    end

    it 'requiere confirmacion cuando cambia contrasena' do
      user = User.create!(valid_params[:user])

      patch :update, params: { id: user.id, user: { email: user.email, firstname: user.firstname, password: 'nueva123', password_confirmation: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'promueve usuarios a admin' do
      user = User.create!(valid_params[:user])

      patch :update, params: { id: user.id, user: { email: user.email, firstname: user.firstname, password: '', password_confirmation: '', admin: '1' } }

      expect(user.reload).to be_admin
    end

    it 'quita admin a otros usuarios' do
      user = User.create!(valid_params[:user])
      user.roles << Role.find_or_create_by!(name: 'admin')

      patch :update, params: { id: user.id, user: { email: user.email, firstname: user.firstname, password: '', password_confirmation: '', admin: '0' } }

      expect(user.reload).not_to be_admin
    end

    it 'no permite quitar admin al usuario actual' do
      user = User.create!(valid_params[:user])
      user.roles << Role.find_or_create_by!(name: 'admin')
      allow(user).to receive(:admin?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      patch :update, params: { id: user.id, user: { email: user.email, firstname: user.firstname, password: '', password_confirmation: '', admin: '0' } }

      expect(user.reload).to be_admin
    end
  end

  describe 'DELETE #destroy' do
    it 'elimina usuarios' do
      user = User.create!(valid_params[:user])

      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(dashboard_users_path)
    end

    it 'no permite que el usuario actual se elimine a si mismo' do
      user = User.create!(valid_params[:user])
      allow(controller).to receive(:current_user).and_return(instance_double('User', id: user.id, admin?: true, persisted?: true))

      expect {
        delete :destroy, params: { id: user.id }
      }.not_to change(User, :count)

      expect(response).to redirect_to(dashboard_users_path)
    end
  end

  describe 'permisos' do
    let(:admin) { instance_double('User', id: 999, admin?: false, persisted?: true) }

    it 'bloquea usuarios no administradores' do
      get :new

      expect(response).not_to have_http_status(:ok)
    end
  end
end
