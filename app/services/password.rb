# encoding: utf-8
# Manages all related to passwords for User class
class Password
  attr_accessor :password, :old_password, :password_confirmation
  attribute :password, String

  def initialize(usr)
    @user = usr
  end


  def update_password(params)
    return false if change_default_password?

    unless authenticate(params[:old_password])
      self.errors[:old_password] << I18n.t("errors.messages.user.wrong_password")
      return false
    end

    unless params[:password] === params[:password_confirmation]
      self.errors[:password] << I18n.t("errors.messages.user.password_confirmation")
      return false
    end

    self.password = params[:password]

    self.save
  end

  # Updates the password given by the system
  def update_default_password(params)
    pwd, pwd_conf = params[:password], params[:password_confirmation]

    unless pwd == pwd_conf
      self.errors[:password] << I18n.t("errors.messages.user.password_confirmation")
      return false
    end

    PgTools.reset_search_path
    u = User.find_by_id(UserSession.id)
    u.change_default_password = false
    u.password = pwd

    u.save
  end

  def reset_password

  end
end
