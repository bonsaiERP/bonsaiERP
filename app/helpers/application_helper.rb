# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module ApplicationHelper
  # Checks if is set the organisation session
  # @return [True, False]
  def organisation?
    session[:organisation] and session[:organisation].size > 0
  end


  # Presens the logo of an organisation based on the session
  # @return [String]
  def organisation_logo
    session[:organisation][:name]
  end

  def verdad?(val)
    val ? "Si": "No"
  end

  # Presents number to currency
  def ntc(val = nil)
    val ||= 0
    number_to_currency(val)
  end

  def nwd(val)
    val ||= 0
    number_with_delimiter(val)
  end

  # Format addres to present on the
  def nl2br(val)
    unless val.blank?
      val.gsub!("\n", "<br/>")
      val.html_safe
    end
  end

  # Changes the <br/> for a \n
  def br2nl(val)
    val.to_s.gsub!("<br/>", "\n") unless val.blank?
  end

  # Used for localization
  def lo(val)
    localize(val) unless val.nil?
  end

  # Links for presenting filtered data
  # @param String
  # @param String
  # @param String
  # @param Hash
  # @return String
  def link_tab(text, uri, option, options = {})
    params[:option] = 'all' if params[:option].nil?
    active = (params[:option] == option) ? "active" : ""
    link_to text, "#{uri}?option=#{option}", options.merge(:class => active)
  end
end
