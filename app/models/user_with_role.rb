class UserWithRole
  attr_reader :user, :organisation

  delegate :role, :master_account?, to: :link
  delegate :email, :id, to: :user

  def initialize(user, organisation)
    @user = user
    raise StandardError, 'The user must be type User'  unless @user.is_a?(User)
    @organisation = organisation
    raise StandardError, 'The organisation must be type Organisation'  unless @organisation.is_a?(Organisation)
  end

  def link
    @link ||= user.links.org_links(organisation.id).first
  end

  ########################################
  # Methods
  User::ROLES.each do |_role|
    define_method :"is_#{_role}?" do
      link.role == _role
    end
  end
end
