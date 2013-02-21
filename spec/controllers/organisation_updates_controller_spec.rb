# encoding: utf-8
require 'spec_helper'

describe OrganisationUpdatesController do
  let(:organisation) { build :organisation, id: 1 }
  before(:each) do
    stub_auth
    controller.stub(current_organisation: organisation)
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get :edit, id: 1

      response.should render_template('edit')
    end
  end

  describe "PUT 'update'" do
    it "success" do
      organisation.stub(update_attributes: true)

      put :update, id: 1, organisation: {name: 'New name'}
      response.should redirect_to configurations_path(anchor: 'organisation')
      flash[:notice].should eq('Se actualizo correctamente los datos de su empresa.')
    end

    it "error" do
      organisation.stub(update_attributes: false)

      put :update, id: 1, organisation: {name: 'New name'}
      response.should render_template('edit')
    end
  end

end
