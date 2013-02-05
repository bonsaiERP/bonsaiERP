class TestsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!

  def index
    params[:view] ||= 'email'

    case params[:view]
    when 'email'
      render file: 'tests/email', layout: 'email'
    end
  end
end
