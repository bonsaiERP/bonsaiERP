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
    user.stub(links: [stub(active?: true)])
    RegistrationMailer.should_not_receive(:send_registration)
    User.stub(find_by_email: user)

    ses = Session.new(valid_attributes)

    ses.authenticate.should be_true
  end

  it "resend registration email" do
    user.should_receive(:confirmed_registration?).and_return(false)
    user.stub(links: [stub(active?: true)])
    RegistrationMailer.should_receive(:send_registration).and_return(stub(deliver: true))
    User.stub(find_by_email: user)

    ses = Session.new(valid_attributes)

    ses.authenticate.should eq('resend_registration_email')
  end

  it "returns the tenant from organisations" do
    User.should_receive(:find_by_email).and_return(user)
    user.should_receive(:organisations).and_return([stub(tenant: 'bonsai')])
    ses = Session.new
    ses.tenant.should eq('bonsai')
  end

  it "inactive_user" do
    user.should_receive(:links).and_return([stub(active?: false)])
    User.stub(find_by_email: user)

    ses = Session.new(valid_attributes)

    ses.authenticate.should eq('inactive_user')
  end
end
