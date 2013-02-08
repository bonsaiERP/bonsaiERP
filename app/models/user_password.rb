class UserPassword < BaseService

  # Especial method to detect if the update is when the
  # change_default_password? is true
  # @param attrs [Hash]
  def update_password(attrs = {})
    return false unless check_old_password?(attrs)
    self.change_default_password = false
    assign_password_attributes(attrs)

    self.save
  end

private
  def check_old_password?(attrs)
    return true if change_default_password?

    return true if valid_password?(attrs[:old_password])

    assign_password_attributes(attrs)
    valid?
    self.errors.add(:old_password, I18n.t('errors.messages.invalid'))

    false
  end
end
