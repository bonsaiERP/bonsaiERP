require 'spec_helper'

describe DashboardController do
  #before(:each) do
  #  stub_auth
  #end

  #describe 'GET /dashboard' do
  #  it "correct" do
  #    get :index

  #    response.should be_ok
  #    flash[:error].should be_blank
  #  end

  #  it "presents flash error" do
  #    get :index, date_start: ''

  #    response.should be_ok
  #    flash[:error].should_not be_blank
  #  end
  #end

  describe 'Authotization' do
    it "session" do
      controller.stub(current_user: User.new, set_tenant: true, set_user_session: true)

      get :index

      expect(response).to render_template('index')
    end

    it "no session" do
      controller.stub(set_tenant: true, set_user_session: true)

      get :index

      expect(response).to redirect_to(logout_path)
    end
  end
end
