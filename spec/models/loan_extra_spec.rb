require 'spec_helper'

describe LoanExtra  do
  it { should validate_presence_of(:due_date) }

  it "$get_columns" do
    expect( LoanExtra.get_columns ).to eq(LoanExtra.column_names.reject { |v| v == 'id' })
  end
end
