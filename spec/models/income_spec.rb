require 'spec_helper'

describe Income do
  let(:organisation) { build :organisation, id: 1 }
  let(:contact) { build :contact, id: 10 }

  before(:each) do
    OrganisationSession.organisation = organisation
    Contact.any_instance.stub(save: true)
  end

  let(:valid_attributes) {
    {active: nil, bill_number: "56498797", contact: contact,
      exchange_rate: 1, currency: 'BOB', date: '2011-01-24',
      description: "Esto es una prueba", discount: 3,
      ref_number: "987654"
    }
  }

  context 'Relationships, Validations' do
    subject { Income.new_income }

    # Relationships
    it { should belong_to(:contact) }
    it { should have_one(:transaction) }
    it { should have_many(:transaction_details) }
  end

  context 'callbacks' do
    it 'check callback' do
      contact.should_receive(:update_attribute).with(:client, true)

      i = Income.new_income(valid_attributes)

      i.save.should be_true
    end


    it "does not update contact to client" do
      contact.client = true
      contact.should_not_receive(:update_attribute).with(:client, true)
      i = Income.new_income(valid_attributes)

      i.save.should be_true
    end
  end

  it "sets the to_s method to :name, :ref_number" do
    i = Income.new(ref_number: 'I-0012')
    i.ref_number.should eq('I-0012')
    i.ref_number.should eq(i.to_s)
  end

  it "gets the latest ref_number" do
    ref_num = Income.get_ref_number
    ref_num.should eq('I-0001')

    Income.stub_chain(:order, :limit, :pluck).and_return(['I-0001'])

    Income.get_ref_number.should eq('I-0002')
  end

  it "sets its state based on the balance" do
    i = Income.new_income(total: 10, balance: 10)
    i.set_state_by_balance!

    i.state.should eq('draft')


    i = Income.new_income(total: 10, balance: 5)
    i.set_state_by_balance!

    i.state.should eq('approved')


    i = Income.new_income(total: 10, balance: 0)
    i.set_state_by_balance!

    i.state.should eq('paid')
  end
end
