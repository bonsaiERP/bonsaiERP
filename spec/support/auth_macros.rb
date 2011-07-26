module AuthMacros
  def create_user_session
    UserSession.current_user = User.new {|u| u.id = 1}
  end

  def create_organisation_session
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
  end

  def stub_auth
    controller.stubs(:check_authorization! => true)
  end
end
