require 'spec_helper'

describe Session do
  let(:valid_attributes) {
    {email: 'test@mail.com', password: 'DEMO1234'}
  }
  let(:user) { build :user, id: 77, password: 'DEMO1234' }
  let(:organisation) { build :organisation, id: 77, tenant: 'demo' }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it "respond to stub methods" do
    User.should respond_to(:active)
    User.should respond_to(:order)
    User.should respond_to(:find_by)
    User.should be_method_defined(:active_links?)
    User.should be_method_defined(:organisations)
  end

  it "Authenticates" do
    User.stub_chain(:active, find_by: user)
    r = double(order: [organisation])
    User.any_instance.stub(active_links?: true, organisations: r)

    ses = Session.new(valid_attributes)

    ses.should be_authenticate

    ses.tenant.should eq('demo')
  end

  it "invalid" do
    User.stub_chain(:active, find_by: user)
    User.any_instance.stub(active_links?: false)

    ses = Session.new(valid_attributes)

    ses.should_not be_authenticate
  end

end
