require 'spec_helper'

describe Session do
  let(:valid_attributes) {
    {email: 'test@mail.com', password: 'demo1234'}
  }
  let(:user) { build :user, id: 77 }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it "Authenticates" do
    user.should_receive(:valid_password?).with('demo1234').and_return(true)
    user.should_receive(:confirmed_registration?).and_return(true)
    user.stub(active_links?: true)

    User.stub_chain(:active, find_by_email: user)

    ses = Session.new(valid_attributes)

    ses.should be_authenticate
  end

  it "resend registration email" do
    user.should_receive(:confirmed_registration?).and_return(false)
    user.stub(active_links?: true)
    User.stub(find_by_email: user)

    ses = Session.new(valid_attributes)

    ses.should_not be_authenticate
    ses.status.should eq('resend_registration')
  end

  it "returns the tenant from organisations" do
    User.should_receive(:find_by_email).and_return(user)
    user.should_receive(:organisations).and_return([stub(tenant: 'bonsai')])
    ses = Session.new
    ses.tenant.should eq('bonsai')
  end
end
