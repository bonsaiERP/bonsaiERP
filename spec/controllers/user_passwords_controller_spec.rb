require 'spec_helper'

describe UserPasswordsController do
  let(:user) { build :user, id: 1 }

  before(:each) do
    stub_auth
    controller.stub(current_user: user)
  end

  it "checks stubed methods" do
    [:update_password].each do |m|
      User.should be_method_defined(m)
    end
  end

  describe "GET /user_passwords/:id/edit" do
    it "change_default_password" do
      user.stub(change_default_password?: true)

      get :edit, id: 1

      response.should render_template('edit_default')
    end

    it "change_default_password" do
      user.stub(change_default_password?: false)

      get :edit, id: 1

      response.should render_template('edit')
    end
  end

  describe "PUT /user_passwords/:id" do
    # A user that has it's own password
    it "updates" do
      user.stub(update_password: true, change_default_password?: false)

      put :update, user: {password: '1234', password_confirmation: '1234'}

      response.should redirect_to(user_path(10))
    end
  end
end
