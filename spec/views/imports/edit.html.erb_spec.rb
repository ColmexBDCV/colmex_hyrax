require 'rails_helper'

RSpec.describe "imports/edit", type: :view do
  before(:each) do
    @import = assign(:import, Import.create!(
      name: "MyString",
      string: "MyString",
      depositor: "MyString",
      storage_size: "MyString",
      status: "MyString",
      object_ids: "MyText",
      num_records: 1
    ))
  end

  it "renders the edit import form" do
    render

    assert_select "form[action=?][method=?]", import_path(@import), "post" do

      assert_select "input[name=?]", "import[name]"

      assert_select "input[name=?]", "import[string]"

      assert_select "input[name=?]", "import[depositor]"

      assert_select "input[name=?]", "import[storage_size]"

      assert_select "input[name=?]", "import[status]"

      assert_select "textarea[name=?]", "import[object_ids]"

      assert_select "input[name=?]", "import[num_records]"
    end
  end
end
