module AuthMacros
  def create_user_session
    UserSession.current_user = User.new {|u| u.id = 1}
  end

  def stub_tenant(tenant = 'public')
    controller.stub(current_tenant: tenant)
  end

  def stub_auth_and_tenant(tenant = 'public')
    stub_auth
    stub_tenant(tenant)
  end

  def create_organisation_session
    OrganisationSession.set(:id => 1, :name => 'bonsaierp', :currency_id => 1)
  end

  def stub_auth
    controller.stub(check_authorization!: true)
  end
end
