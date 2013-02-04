require 'spec_helper'

describe Link do
  it { should belong_to(:organisation) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:rol) }
  it { should validate_presence_of(:user) }

end
