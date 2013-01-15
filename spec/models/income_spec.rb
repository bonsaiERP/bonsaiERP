require 'spec_helper'

describe Income do
  let(:organisation) { build :organisation, id: 1 }
  let(:contact) { build :contact, id: 10 }

  before(:each) do
    OrganisationSession.set organisation
    Contact.any_instance.stub(save: true)
  end

  let(:valid_attributes) {
    {active: nil, bill_number: "56498797", contact: contact,
      exchange_rate: 1, currency: 'BOB', date: '2011-01-24',
      description: "Esto es una prueba", discount: 3, 
      ref_numbe: 987654"
    }
  }

  it 'check callback' do
    contact.should_receive(:update_attribute).with(:client, true)
    i = Income.new(valid_attributes)

    i.save.should be_true
  end

  it "does not update contact to client" do
    contact.client = true
    contact.should_not_receive(:update_attribute).with(:client, true)
    i = Income.new(valid_attributes)

    i.save.should be_true
  end

  it "sets its state based on the balance" do
    i = Income.new(total: 10, balance: 10)
    i.set_state_by_balance!

    i.state.should eq('draft')


    i = Income.new(total: 10, balance: 5)
    i.set_state_by_balance!

    i.state.should eq('approved')


    i = Income.new(total: 10, balance: 0)
    i.set_state_by_balance!

    i.state.should eq('paid')
  end
end
