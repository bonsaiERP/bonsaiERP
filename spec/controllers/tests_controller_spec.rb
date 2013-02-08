# encoding: utf-8
require 'spec_helper'

describe TestsController do
  let(:user) { build(:user, id: 10) }

  before(:each) do
    request.stub(subdomain: 'bonsai')
  end

  context "test current_user" do
    it "redirects when there is no current_user" do
      subject.should_receive(:redirect_to).with(new_session_url(subdomain: false))
      subject.stub(authorized_user?: true)

      subject.send(:check_authorization!)
    end

    it "checks the authorization for current_user" do
      subject.stub(current_user: user)
      subject.should_not_receive(:redirect_to).with(new_session_url(subdomain: false))
      subject.should_receive(:authorized_user?).and_return(true)

      subject.send(:check_authorization!)
    end
  end

  describe "Roles" do
    before(:each) do
      request.stub(referer: 'back')
      subject.stub(current_user: user)
    end

    context "admin" do
      before(:each) do
        user.stub(link_rol: 'admin')
      end
      
      it "allows all actions to admin" do
        subject.should_not_receive(:redirect_to).with(:back)

        subject.send(:admin_hash).each do |k,v|
          subject.stub(controller_name: k.to_s)

          subject.send(:check_authorization!)
        end
      end
    end

    context "group" do
      before(:each) do
        user.stub(link_rol: 'group')
      end
      
      it "check hashed methods" do
        subject.should_not_receive(:redirect_to).with(:back)
        subject.stub(controller_name: 'configurations', action_name: 'index')

        subject.send(:check_authorization!)
      end

      it "allowed action" do
        subject.should_not_receive(:redirect_to).with(:back)
        subject.stub(controller_name: 'admin_users', action_name: 'show')

        subject.send(:check_authorization!)
      end

      it "redirects not allowed action" do
        subject.should_receive(:redirect_to).with(:back)
        subject.stub(controller_name: 'admin_users', action_name: 'new')

        subject.send(:check_authorization!)
      end
    end
  end
end
