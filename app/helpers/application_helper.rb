module ApplicationHelper
  def organisation?
    session[:organisation_id] != nil
  end
end
