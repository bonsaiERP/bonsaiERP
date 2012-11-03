# encoding: utf-8
module Controllers
  class LoginVerification
    attr_reader :controller

    def initialize(cont)
      raise 'Incorrect param controller' unless cont.is_a?(ActionController::Base)
      @controller = cont
    end

    def login(user, pass)
      case
      when user.confirmed_and_valid_password?(pass)

      else
      end
    end

    def logged_in
      controller.current_user
    end

    def params
      controller.params
    end

  end
end
