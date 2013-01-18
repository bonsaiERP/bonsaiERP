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
      ref_number: "987654", state: 'draft'
    }
  }

  context 'Relationships, Validations' do
    subject { Income.new_income }

    # Relationships
    it { should belong_to(:contact) }
    it { should belong_to(:project) }
    it { should have_one(:transaction) }
    it { should have_many(:income_details) }

    it { should validate_presence_of(:date) }
    it { should have_valid(:state).when(*Income::STATES) }
    it { should_not have_valid(:state).when(nil, 'ja', 1) }
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

  it "checks the states methods" do
    Income::STATES.each do |state|
      Income.new(state: state).should send(:"be_is_#{state}")
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

  it "returns the subtotal from  details" do
    i = Income.new_income(valid_attributes.merge(
      {income_details_attributes: [
        {item_id: 1, price: 10, quantity: 1},
        {item_id: 2, price: 3.5, quantity: 2}
      ]
    }
    ))

    i.subtotal.should == 17.0
  end

  it "checks the methods approver, nuller, creator" do
    t = Time.now
    d = Date.today
    attrs = {
      balance: 10, bill_number: '123', discount: 2.0,
      gross_total: 10, original_total: 10, balance_inventory: 10,
      payment_date: d, creator_id: 1, approver_id: 2,
      nuller_id: 3, null_reason: 'Null', approver_datetime: t,
      delivered: true, discount: 1.0, devolution: true
    }

    i = Income.new_income(attrs)

    attrs.each do |k, v|
      i.send(k).should eq(v)
    end
  end
end
