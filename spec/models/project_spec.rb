require 'spec_helper'

describe Project do
  it { should have_many(:accounts) }
  it { should have_many(:account_ledgers) }
end
