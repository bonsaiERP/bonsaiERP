require 'spec_helper'

describe Cash do
  let(:valid_attributes) do
    {currency: 'BOB', name: 'Caja 1', amount: 1000.0, address: 'First way', phone: '777-12345'}
  end

  before(:each) do
    OrganisationSession.organisation = build(:organisation, currency: 'BOB')
  end

  context 'Created related and check relationships, validations' do
    subject { Cash.new_cash }

    it { should have_one(:money_store) }

    it { should_not have_valid(:name).when('No', 'E', '', nil) }
    it { should have_valid(:name).when('Especial', 'Caja 2') }
  end

  it "returns to_s method" do
    c = Cash.new name: 'Cash 1', currency: 'USD'

    c.to_s.should  eq(c.name)
  end

  it 'create an instance' do
    c = Cash.new_cash(valid_attributes)
    c.save.should be_true

    valid_attributes.each do |k, v|
      c.send(k).should eq(v)
    end
  end

  it 'allow updates' do
    # Does not allow the use of create or create! methods
    c = Cash.new_cash(valid_attributes.merge(amount: 200))
    c.save.should be_true

    c.should be_persisted
    c.money_store.should be_persisted

    c.update_attributes(address: 'Another address', email: 'caja1@mail.com').should be_true

    c = Cash.find(c.id)

    c.address.should eq('Another address')
    c.email.should eq('caja1@mail.com')
  end
end


