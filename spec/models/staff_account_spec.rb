require 'spec_helper'

describe StaffAccount do
  let(:attributes) {
    { name: 'Lucas Estrella', currency:'BOB', amount: 1000,
      email: 'lucacho@facebook.com', address: 'Samaipata, La Paz',
      phone: '555 666 777', mobile: '777 888 999'
    }
  }

  before(:each) do
    OrganisationSession.organisation = build(:organisation, currency: 'BOB')
  end

  context 'Created related and check relationships, validations' do
    subject { StaffAccount.new }


    it { should_not have_valid(:name).when('No', 'E', '', nil) }
    it { should have_valid(:name).when('Juan Perez', 'Luci Luna 23') }

    it { should have_valid(:currency).when('BOB', 'USD') }
    it { should_not have_valid(:currency).when('BOBS', 'JEJE') }

  end

  it "methods" do
    c = Cash.new
    expect(c).to respond_to(:ledgers)
    expect(c).to respond_to(:pendent_ledgers)
  end

  before(:each) do
    UserSession.user = build :user, id: 1
  end

  context 'create' do
    let(:subject) { StaffAccount.create!(attributes) }

    it { subject.amount.should == 1000 }
    it { subject.to_s.should eq('Lucas Estrella BOB') }
    it { subject.address.should eq(attributes.fetch(:address)) }
    it { subject.phone.should eq(attributes.fetch(:phone)) }
    it { subject.mobile.should eq(attributes.fetch(:mobile)) }
  end
end
