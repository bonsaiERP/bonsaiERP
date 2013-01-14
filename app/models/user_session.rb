# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to access the authenticated user in the models
class UserSession
  class << self
    attr_reader :user
    delegate :id, :email, to: :user
    # Stores using de application_controller the current_user for devise
    def user=(usr)
      raise 'You must pass a User class' unless usr.is_a?(User)
      @user = usr
    end

    def user_id
      user.id
    end

    def destroy
      @user = nil
    end
  end

end
