require 'spec_helper'

describe Transaction do
  it { should belong_to(:income) }
  it { should belong_to(:expense) }
end
