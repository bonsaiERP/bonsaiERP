require 'spec_helper'

describe User do

  it { should have_many(:active_links) }
  it { should_not have_many(:links) }

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

  it "define_method check" do
    u = User.new
    link = Link.new
    u.stub(link: link)

    User::ROLES.each do |role|
      link.role = role
      u.should send(:"be_is_#{role}")
    end
  end

  it "validates password when new" do
    u = User.new(email: 'test@mail.com', password: 'Demo12234')
    u.should be_valid
  end

  it "valid password when change" do
    u = User.create!(email: 'test@mail.com', password: 'Demo12234')

    u = User.find(u.id)
    u.update_attributes(password: 'Demo12234', ).should be_true
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

      subject.set_auth_token.should be_true
      subject.auth_token.should_not be_blank
    end

    it "#reset_auth_token" do
      subject.auth_token = "jajjajaja"
      subject.auth_token.should_not be_blank

      subject.reset_auth_token.should be_true
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

  context "Tenant" do
    before(:each) do
      OrganisationSession.organisation = build :organisation, id: 100
    end

    it "creates the methods for each rol" do
      u = User.new {|us| us.id = 10}
      u.stub_chain(:active_links, find_by_organisation_id: Link.new(active:true, user_id: u.id, role:'') )

      u.link_role = 'admin'

      u.should be_is_admin
      u.should_not be_is_group
      u.should_not be_is_other


      u.link_role = 'group'

      u.should be_is_group
      u.should_not be_is_admin
      u.should_not be_is_other


      u.link_role = 'other'

      u.should be_is_other
      u.should_not be_is_admin
      u.should_not be_is_group
    end
  end

end
