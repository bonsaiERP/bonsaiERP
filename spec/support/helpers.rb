module Helpers
  def stub_authorization
    controller.stub(set_tenant: true, check_authorization!:true)
  end
  alias_method :stub_auth, :stub_authorization
end
