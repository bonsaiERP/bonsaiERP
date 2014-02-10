require 'spec_helper'

describe Link do
  it { should belong_to(:organisation) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:role) }
  it { should validate_presence_of(:organisation_id) }
end
