require 'rails_helper'

RSpec.describe "imports/index", type: :view do
  before(:each) do
    assign(:imports, [
      Import.create!(
        name: "Name",
        string: "String",
        depositor: "Depositor",
        storage_size: "Storage Size",
        status: "Status",
        object_ids: "MyText",
        num_records: 2
      ),
      Import.create!(
        name: "Name",
        string: "String",
        depositor: "Depositor",
        storage_size: "Storage Size",
        status: "Status",
        object_ids: "MyText",
        num_records: 2
      )
    ])
  end

  it "renders a list of imports" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "String".to_s, count: 2
    assert_select "tr>td", text: "Depositor".to_s, count: 2
    assert_select "tr>td", text: "Storage Size".to_s, count: 2
    assert_select "tr>td", text: "Status".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
  end
end
