require 'spec_helper'

describe Cash do
  let(:valid_attributes) do
    {currency: 'BOB', name: 'Caja 1', amount: 1000.0, address: 'First way', phone: '777-12345'}
  end

  before(:each) do
    OrganisationSession.organisation = build(:organisation, currency: 'BOB')
  end


  it { should_not have_valid(:name).when('No', 'E', '', nil) }
  it { should have_valid(:name).when('Especial', 'Caja 2') }

  it 'should create an instance' do
    c = Cash.new(valid_attributes)
    c.save.should be_true

    valid_attributes.each do |k, v|
      c.send(k).should eq(v)
    end
  end

  it 'should allow updates' do
    # Does not allow the use of create or create! methods
    c = Cash.new(valid_attributes.merge(amount: 200))
    c.save.should be_true

    c.should be_persisted
    c.money_store.should be_persisted

    c.update_attributes(address: 'Another address', email: 'caja1@mail.com').should be_true

    c = Cash.find(c.id)

    c.address.should eq('Another address')
    c.email.should eq('caja1@mail.com')
  end
end


