require 'spec_helper'

describe Transaction do
  it { should belong_to(:income) }
  it { should belong_to(:expense) }

  it { should belong_to(:creator) }
  it { should belong_to(:approver) }
  it { should belong_to(:nuller) }
end
