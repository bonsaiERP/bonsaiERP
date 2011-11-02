require 'spec_helper'

describe TransactionDetail do
  before do
    OrganisationSession.set id: 1
  end
  it{ should have_valid(:quantity).when(0.1, 1)}
  it{ should_not have_valid(:quantity).when(0)}

  it{ should have_valid(:item_id).when(1)}
  it{ should_not have_valid(:item_id).when(nil, " ")}

end
