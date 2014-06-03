# encoding: utf-8
class Registration < BaseForm
  attr_reader :organisation, :user

  attribute :name     , String
  attribute :email    , String
  attribute :password , String

  validates :name, presence: true, length: {within: 2..100}

  validates :password, presence: true, length: {within: PASSWORD_LENGTH..100}
  validates_email_format_of :email

  delegate :tenant, to: :organisation

  def register
    return false unless valid?

    commit_or_rollback do
      res = create_organisation && create_user

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
        role: 'admin', master_account: true,
        api_token: api_token
      )

      @user.save
    end

    def create_organisation
      @organisation = Organisation.new(name: name, inventory: true)
      @organisation.valid?
      @organisation.save
    end

    def api_token
      SecureRandom.urlsafe_base64(32)
    end

end
