require 'rails_helper'

RSpec.describe ConacytStatsController, type: :controller do
    before do
        allow_any_instance_of(ConacytStatsController).to receive(:authenticate).and_return(true)
    end

    describe "GET #padron" do
        it "returns user information with valid credentials" do
            users_double = [double(email: "user@example.com", firstname: "John", phone: "555-1234", paternal_surname: "Doe", maternal_surname: "Smith")]
            allow(User).to receive(:select).and_return(users_double)
            
            get :padron
            
            expect(response).to be_successful
            json_response = JSON.parse(response.body)
            expect(json_response["depositarios"]).to include(hash_including("correo" => "user@example.com"))
        end
    end


    describe "GET #articulos" do
        it "returns articles information" do
            # Aquí debes mockear las llamadas y respuestas específicas para esta acción
            # Este es un ejemplo, ajusta según tu modelo y lógica específica
            get :articulos
            expect(response).to be_successful
            # Verifica el JSON de respuesta como en el test anterior
        end
    end

  # Agrega tests similares para #autores y #descargas aquí

    describe "GET #descargas" do
        it "returns articles information" do
            # Aquí debes mockear las llamadas y respuestas específicas para esta acción
            # Este es un ejemplo, ajusta según tu modelo y lógica específica
            get :descargas
            expect(response).to be_successful
            # Verifica el JSON de respuesta como en el test anterior
        end
    end

    describe "GET #autores" do
        it "returns articles information" do
            # Aquí debes mockear las llamadas y respuestas específicas para esta acción
            # Este es un ejemplo, ajusta según tu modelo y lógica específica
            get :autores
            expect(response).to be_successful
            # Verifica el JSON de respuesta como en el test anterior
        end
    end
end
