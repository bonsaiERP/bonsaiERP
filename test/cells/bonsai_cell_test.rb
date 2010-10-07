require 'test_helper'

class BonsaiCellTest < Cell::TestCase
  test "form_error" do
    invoke :form_error
    assert_select "p"
  end
  

end
