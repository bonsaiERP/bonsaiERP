class UpdateDefaultPassword < BaseForm
  attribute :password, String
  attribute :password_confirmation, String

  validates_length_of :password, minimum: PASSWORD_LENGTH, maximum: 32
  validates_confirmation_of :password

  def update_password

  end
end
