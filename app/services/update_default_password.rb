class UpdateDefaultPassword < BaseForm
  attribute :password, String
  attribute :password_confirmation, String
  attribute :user, User

  validates_length_of :password, minimum: PASSWORD_LENGTH, maximum: 32
  validate :valid_password_confimation
  validates_presence_of :user

  def update_password
    return false  unless valid?

    user.change_default_password = false
    user.password = password

    user.save
  end

  private

    def valid_password_confimation
      unless password == password_confirmation
        errors.add(:password, I18n.t('errors.messages.confirmation'))
      end
    end
end
