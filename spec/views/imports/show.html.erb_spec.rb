require 'rails_helper'

RSpec.describe "imports/show", type: :view do
  before(:each) do
    @import = assign(:import, Import.create!(
      name: "Name",
      string: "String",
      depositor: "Depositor",
      storage_size: "Storage Size",
      status: "Status",
      object_ids: "MyText",
      num_records: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/String/)
    expect(rendered).to match(/Depositor/)
    expect(rendered).to match(/Storage Size/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
