require 'rails_helper'

RSpec.describe "imports/new", type: :view do
  before(:each) do
    assign(:import, Import.new(
      name: "MyString",
      string: "MyString",
      depositor: "MyString",
      storage_size: "MyString",
      status: "MyString",
      object_ids: "MyText",
      num_records: 1
    ))
  end

  it "renders new import form" do
    render

    assert_select "form[action=?][method=?]", imports_path, "post" do

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
