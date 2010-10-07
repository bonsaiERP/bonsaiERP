require 'test_helper'

class ItemCellTest < Cell::TestCase
  test "form_item" do
    invoke :form_item
    assert_select "p"
  end
  

end
