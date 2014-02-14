require 'spec_helper'

describe ContactsController do
  before(:each) do
    stub_auth
  end

  def mock_contact(stubs={})
    @mock_contact ||= mock_model(Contact, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all contacts as @contacts" do
      Contacts::Query.any_instance.stub_chain(:index, order: double(page: [mock_contact]))
      get :index

      assigns(:contacts).should eq([mock_contact])
      response.should render_template(:index)
    end

    it "search" do
      s = mock('Search')
      Contacts::Query.any_instance.stub_chain(:index, order: s)
      s.should_receive(:searh).with('h').and_return(double(page: [mock_contact]))

      get :index, search: 'h'
      assigns(:contacts).should eq([mock_contact])
    end
  end

  describe "GET show" do
    it "assigns the requested contact as @contact" do
      Contact.stub(:find).with("37") { mock_contact }
      get :show, :id => "37"
      assigns(:contact).should be(mock_contact)
    end
  end

  describe "GET new" do
    it "assigns a new contact as @contact" do
      Contact.stub(:new) { mock_contact }
      get :new
      assigns(:contact).should be(mock_contact)
    end
  end

  describe "GET edit" do
    it "assigns the requested contact as @contact" do
      Contact.stub(:find).with("37") { mock_contact }
      get :edit, :id => "37"
      assigns(:contact).should be(mock_contact)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created contact as @contact" do
        Contact.stub(:new).with({'these' => 'params'}) { mock_contact(:save => true) }
        post :create, :contact => {'these' => 'params'}
        assigns(:contact).should be(mock_contact)
      end

      it "redirects to the created contact" do
        Contact.stub(:new) { mock_contact(:save => true) }
        post :create, :contact => {}
        response.should redirect_to(contact_url(mock_contact))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved contact as @contact" do
        Contact.stub(:new).with({'these' => 'params'}) { mock_contact(:save => false) }
        post :create, :contact => {'these' => 'params'}
        assigns(:contact).should be(mock_contact)
      end

      it "re-renders the 'new' template" do
        Contact.stub(:new) { mock_contact(:save => false) }
        post :create, :contact => {}
        response.should render_template(:new)
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested contact" do
        Contact.should_receive(:find).with("37") { mock_contact }
        mock_contact.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :contact => {'these' => 'params'}
      end

      it "assigns the requested contact as @contact" do
        Contact.stub(:find) { mock_contact(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:contact).should be(mock_contact)
      end

      it "redirects to the contact" do
        Contact.stub(:find) { mock_contact(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(contact_url(mock_contact))
      end
    end

    describe "with invalid params" do
      it "assigns the contact as @contact" do
        Contact.stub(:find) { mock_contact(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:contact).should be(mock_contact)
      end

      it "re-renders the 'edit' template" do
        Contact.stub(:find) { mock_contact(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template(:edit)
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested contact" do
      Contact.should_receive(:find).with("37") { mock_contact }
      mock_contact.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the contacts list" do
      Contact.stub(:find) { mock_contact(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(contacts_url)
    end
  end

end
