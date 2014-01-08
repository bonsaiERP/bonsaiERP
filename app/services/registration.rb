# encoding: utf-8
class Registration < BaseForm
  attr_reader :organisation, :user

  attribute :name     , String
  attribute :tenant   , String
  attribute :email    , String
  attribute :password , String

  validates :name, presence: true, length: {within: 2..100}

  validates :tenant, presence: true, length: {within: 2..50}, format: {with: /\A[a-z0-9]+\z/}
  validate :valid_unique_tenant

  validates :password, presence: true, length: {within: PASSWORD_LENGTH..100}
  validates_email_format_of :email

  def register
    return false unless valid?

    commit_or_rollback do
      res = create_organisation
      res = create_user && res

      set_errors(organisation, user) unless res
      res
    end
  end

  private

    def create_user
      @user = User.new(email: email, password: password)
      @user.set_confirmation_token

      @user.active_links.build(
        organisation_id: organisation.id, tenant: organisation.tenant,
        rol: 'admin', master_account: true
      )

      @user.save
    end

    def create_organisation
      @organisation = Organisation.new(name: name, tenant: tenant, inventory_active: true)
      @organisation.save
    end

    def valid_unique_tenant
      if Organisation.where(tenant: tenant.to_s).any?
        self.errors[:tenant] << I18n.t('errors.messages.registration.unique_tenant')
      end
    end
end
