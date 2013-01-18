require 'spec_helper'

describe IncomeDetail do
  it { should belong_to(:income) }
  it { should validate_presence_of(:income) }
end

