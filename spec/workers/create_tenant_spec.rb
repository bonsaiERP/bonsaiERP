require 'spec_helper'

describe CreateTenant do

  let(:user_mock) {
    mock_model(User, 
      id: 1, email: "demo@example.com", confirmed_at: Time.zone.now,
      attributes: {"id" => 1, "email"=> "demo@example.com"}
    )
  }

  before do
    User.stub!(find: user_mock)
    Factory(:currency)
    Factory(:org_country)
    UserSession.current_user = user_mock
  end
  it 'should create a new schema and migrate' do
    org = Organisation.create!(name: "Org1", currency_id: 1, country_id: 1)
    Unit.count.should == 0

    schema_name = PgTools.get_schema_name(org.id)
    PgTools.schema_exists?(schema_name).should be_false
    CreateTenant.perform org.id, user_mock.id

    PgTools.schema_exists?(schema_name).should be_true
    PgTools.add_schema_to_path schema_name
    Unit.count.should > 0
    Organisation.first.name.should == org.name

    PgTools.reset_search_path
    Unit.count.should == 0
  end
end
