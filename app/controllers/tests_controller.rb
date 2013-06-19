class TestsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!

  def index
    params[:view] ||= 'email'

    case params[:view]
    when 'email'
      render file: 'tests/email', layout: 'email'
    when 'testemail'
      email = params[:email] || 'boriscyber@gmail.com'
      name = params[:name] || 'Boris Barroso'
      s = (Struct.new(:email, :name)).new(email, name)
      RegistrationMailer.test_email(s).deliver

      render text: "Email send to #{email}"
    end
  end

  # /kitchen
  def kitchen
  end
end
