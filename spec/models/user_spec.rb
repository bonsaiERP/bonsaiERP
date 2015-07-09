require 'spec_helper'

describe User do

  it { should have_many(:links).dependent(:destroy) }
  it { should have_many(:active_links).dependent(:destroy) }
  it { should have_many(:organisations).through(:active_links) }

  let(:valid_attributes)do
    {email: 'demo@example.com', password: 'demo1234'}
  end

  it 'should not create' do
    expect{ User.create!(params)}.to raise_error
  end

  it "#tenat_link" do
    u = build :user

    st = Object.new
    u.should_receive(:active_links).and_return(st)
    st.should_receive(:where).with(tenant: 'bonsai').and_return(double(first: true))
    u.tenant_link('bonsai')
  end

  it "#active_links?" do
    u = User.new
    u.should_receive(:active_links).and_return([true])

    u.should be_active_links
  end


  it "validates password when new" do
    u = User.new(email: 'test@mail.com', password: 'Demo12234')
    u.should be_valid
  end

  it "valid password when change" do
    u = User.create!(email: 'test@mail.com', password: 'Demo12234')

    u = User.find(u.id)
    u.update_attributes(password: 'Demo12234', ).should eq(true)
  end

  it '#set_confirmation_token' do
    u = User.new
    u.confirmation_token.should be_nil

    u.set_confirmation_token

    u.confirmation_token.should_not be_blank
  end

  context "Update methods" do
    subject { User.new }
    before(:each) do
      User.any_instance.stub(save: true)
    end

    it "#set_auth_token" do
      subject.auth_token.should be_nil

      subject.set_auth_token.should eq(true)
      subject.auth_token.should_not be_blank
    end

    it "#reset_auth_token" do
      subject.auth_token = "jajjajaja"
      subject.auth_token.should_not be_blank

      subject.reset_auth_token.should eq(true)
      subject.auth_token.should be_blank
    end
  end

  it "#to_s" do
    u = User.new(email: "test@mail.com")

    u.to_s.should eq("test@mail.com")

    u = User.new(email: "test@mail.com", first_name: "Violeta", last_name: "Barroso")

    u.to_s.should eq('Violeta Barroso')

    u = User.new(email: "test@mail.com", first_name: "Amaru")

    u.to_s.should eq('Amaru')

    u = User.new(email: "test@mail.com", last_name: "Estrella")

    u.to_s.should eq('Estrella')
  end

  it "#confirm_registration" do
    u = create :user
    u.should be_persisted

    u.should_not be_confirmed_at
    u.confirm_registration
    u.confirmed_at.should be_is_a(Time)
  end

  it "store old_emails" do
    u = create :user, email: 'first@mail.com'
    expect(u).to be_persisted
    expect(u.old_emails).to eq([])

    expect(u.update_attributes(email: 'second@mail.com')).to eq(true)
    u = User.find u.id
    expect(u.old_emails).to eq(['first@mail.com'])

    expect(u.update_attributes(email: 'second@mail.com', first_name: 'Juan other')).to eq(true)
    expect(u.update_attributes(email: 'second@mail.com')).to eq(true)
    expect(u.old_emails).to eq(['first@mail.com'])

    expect(u.update_attributes(email: 'third@mail.com', first_name: 'Juan other')).to eq(true)
    u = User.find u.id
    expect(u.old_emails).to eq(%w(second@mail.com first@mail.com))
  end
end
