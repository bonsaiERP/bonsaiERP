require 'spec_helper'

describe LoanExtra  do
  it { should validate_presence_of(:due_date) }
  it { should validate_presence_of(:total) }

  it { should have_valid(:total).when(0.1, 100) }
  it { should_not have_valid(:total).when(0, -1) }

  it "$get_columns" do
    expect( LoanExtra.get_columns ).to eq(LoanExtra.column_names.reject { |v| v == 'id' })
  end
end
