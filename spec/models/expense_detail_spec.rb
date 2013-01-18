require 'spec_helper'

describe ExpenseDetail do
  it { should belong_to(:expense) }
  it { should validate_presence_of(:expense) }
end
