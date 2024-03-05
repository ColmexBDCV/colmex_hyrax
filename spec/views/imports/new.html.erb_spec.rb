require 'rails_helper'

RSpec.describe "imports/new", type: :view do
  before(:each) do
    # Simula la asignación de variables como se esperaría en el controlador
    assign(:sips, [
      { sip: "SIP1", size: "100MB" },
      { sip: "SIP2", size: "200MB" }
    ])
  end

  it "muestra los paquetes por procesar" do
    render

    # Verifica la presencia de textos específicos o estructuras
    expect(rendered).to match /Paquetes por procesar/
    expect(rendered).to match /SIP1/
    expect(rendered).to match /100MB/
    expect(rendered).to match /SIP2/
    expect(rendered).to match /200MB/
  end
end