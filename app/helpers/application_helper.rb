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

  # returns the minus image with a size
  def minus_image(size = 16)
    raw "<img src=\"/stylesheets/images/minus.png\" width=\"#{size}\" height=\"#{size}\" alt =\"menos\"/>"
  end

  # Presents income/expense with color
  # @param [Tru, False]
  # @param Hash
  def in_out(val, options = {})
    css, txt = val ? [ "dark_green", "Ingreso" ] : [ "red", "Egreso" ]
    options[:class] = options[:class].blank? ? css : options[:class] << " #{css}"
    content_tag(:span, txt, options)
  end


  # Presents a class with currency
  def with_currency(klass, amount = :amount, options = {})
    options = {:precision => 2}.merge(options)
    "#{ klass.currency_symbol } #{number_to_currency klass.send(amount), options}"
  end

  alias :wcur :with_currency
  
  def organisation_creation_title(local)
    case local
    when :organisation then "Datos organización"
    when :bank         then "Datos cuenta bancaria"
    when :cash_regiser then "Datos cuenta caja"
    when :view         then "Revisar datos"
    end
  end

end
