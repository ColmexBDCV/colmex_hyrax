require 'rails_helper'

RSpec.describe "imports/index", type: :view do
  before(:each) do
    assign(:imports, [
      Import.create!(
        name: "Name",
        object_type: "ObjectType", # Asume que este es un string válido para tu aplicación
        depositor: "Depositor",
        date: DateTime.now, # Usa DateTime.now como ejemplo, ajusta según necesidad
        storage_size: "Storage Size",
        status: "Status",
        object_ids: "MyText",
        num_records: 2,
        repnal: "RepnalValue" # Añade valores adicionales como este si son necesarios
      ),
      Import.create!(
        name: "Name",
        object_type: "ObjectType",
        depositor: "Depositor",
        date: DateTime.now,
        storage_size: "Storage Size",
        status: "Status",
        object_ids: "MyText",
        num_records: 2,
        repnal: "RepnalValue"
      )
    ])
  end

  it "renders a list of imports" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "ObjectType".to_s, count: 2 # Asegúrate de que este texto coincida con el valor que asignaste
    assert_select "tr>td", text: "Depositor".to_s, count: 2
    assert_select "tr>td", text: "Storage Size".to_s, count: 2
    assert_select "tr>td", text: "Status".to_s, count: 2
    assert_select "tr>td>button", text: 2.to_s, count: 2
    assert_select "tr>td", text: "RepnalValue", count: 2
    # Agrega aserciones para cualquier otro campo que hayas incluido
  end
end
