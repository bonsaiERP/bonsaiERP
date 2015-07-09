require 'spec_helper'

describe OrganisationsController do

  let(:organisation) { create :organisation }
  let(:user) { create :user }
  let(:link) {
     organisation.links.build(user_id: user.id).create
  }

  before do
    controller.stub(:check_authorization! => true, current_user: user)
    UserSession.user = user
  end

  def mock_organisation(stubs={})
    @mock_organisation ||= Organisation.new
  end

  describe "GET new" do
    it "OK" do
      controller.stub(current_organisation: organisation)

      get :new

      expect(current_organisation.class).to eq(Organisation)
    end
  end

  describe "POST create" do
    before do
      #Qu.stub(enqueue: true)
      ClientAccount.stub(find_by_name: stub(id: 1))
    end

    describe "with valid params" do


      it "assigns a newly created organisation as @organisation" do
        Organisation.stub(:new).with({'these' => 'params'}) { mock_organisation(:save => true) }
        post :create, :organisation => {'these' => 'params'}
        assigns(:organisation).should be(mock_organisation)
      end

      it "redirects to the created organisation" do
        Organisation.stub(:new) { mock_organisation(:save => true) }
        post :create, :organisation => {}
        response.should redirect_to(organisation_url(mock_organisation))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved organisation as @organisation" do
        Organisation.stub(:new).with({'these' => 'params'}) { mock_organisation(:save => false) }
        post :create, :organisation => {'these' => 'params'}
        assigns(:organisation).should be(mock_organisation)
      end

      it "re-renders the 'new' template" do
        Organisation.stub(:new) { mock_organisation(:save => false) }
        post :create, :organisation => {}
        response.should render_template('new')
      end
    end

  end


  describe "GET test_schema" do
    it 'should return if schema has been created' do
      PgTools.stub(schema_exists?: true)
      Organisation.stub(find: mock_model(Organisation,
        id: 1, name: "Test", currency_id: 1, currency_name: "Boliviano",
        currency_symbol: "Bs.", due_date: Time.now
      ))
      get :check_schema, id: "1"
      response.body.should =~ /#{{:success => true, :id => "1"}.to_json}/
    end

    it 'should return false schema' do
      PgTools.stub(schema_exists?: false)
      get :check_schema, id: "1"
      response.body.should =~ /#{{:success => false, :id => "1"}.to_json}/
    end
  end

  describe "GET create_tenant" do
    it 'should render show and wait for schema creation' do
      Qu.stub(enqueue: true)
      Organisation.stub(find: mock_model(Organisation, id: 1))

      get :create_tenant, id: 1
      response.should render_template("show")
    end
  end

end
