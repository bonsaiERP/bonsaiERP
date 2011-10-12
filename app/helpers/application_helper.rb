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

  # Presents the organisation due date
  def present_due_date
    if session[:organisation]
      if session[:organisation][:due_date] < Date.today
        "<span class='red'>Vencio el #{lo session[:organisation][:due_date]}</span>".html_safe
      else
        "Vence el #{lo session[:organisation][:due_date]}"
      end
    end
  end

  def verdad?(val)
    val ? "Si": "No"
  end

  def active?(val)
    val ? "Activo" : "Inactivo"
  end

  # Creates an otion link
  # @param String text
  # @param String url
  # @param String option
  def link_option(text, option, options = {})
    options[:class] = "#{ options[:class] } #{( params[:option] === option ? 'active' : '' )}"
    url_hash = params.merge(:option => option)
    link_to text, url_for(url_hash), options
  end

  # Creates the url for the link_option
  def create_options_url(url, option)
    opts = params.merge(:option => option)
    [:controller, :action].each {|v| opts.delete(v) }
    opts.delete(:id) if url =~ /^.+\/\d+$/
    first = true

    opts.inject(url) do |s,(k,v)|
      sym = first ? "?" : "&"
      first = false
      s << "#{sym}#{k}=#{v}"
    end
  end

  # Presents number to currency
  def ntc(val = nil, options = {})
    number_to_currency(val.to_f, options)
  end

  def nwd(val)
    val ||= 0
    number_with_delimiter(val)
  end

  # Format addres to present on the
  def nl2br(val)
    unless val.blank?
      t = val.gsub("\n", "<br/>")
      t.html_safe
    end
  end

  # Changes the <br/> for a \n
  def br2nl(val)
    val.to_s.gsub!("<br/>", "\n") unless val.blank?
  end

  # Used for localization
  def lo(val, options = {})
    localize(val, options) unless val.nil?
  end

  # Links for presenting filtered data
  # @param String
  # @param String
  # @param String
  # @param Hash
  # @return String
  def link_tab(url, option, options = {})
    params[:option] = 'all' if params[:option].nil?

    active = (params[:option] == option) ? "active" : ""
    url = "#{url}?option=#{option}" << create_options_link

    link_to text, url, options.merge(:class => active)
  end

  def tab_url(url)
    url << create_options_link
  end

  def create_options_link
    opts = params
    opts.delete(:controller)
    opts.delete(:action)
    opts.inject("") do |s,(k,v)|
      sym = s.blank? ? "?" : "&"
      s << "#{sym}#{k}=#{v}"
    end
  end

  def jquery_tabs(text, url)
    params[:tab]
  end

  def jqueryui_ul
    content_tag(:ul, :class => 'ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all') do
      yield
    end
  end

  def jquery_tabs(options = {}, &bl)
    id = options[:tab_id] || "tab"

    content_tag(:div, :id => id, :class => "ui-tabs ui-widget ui-widget-content ui-corner-all") do
      yield
    end
  end

  def tab(text, url, type)
    css = "ui-tabs ui-tabs-nav"
    css << " ui-tabs-selected li ui-state-active ui-corner-top" if type === params[:tab]
    content_tag(:li, link_to(text, url), :class => css)
  end

  # returns the minus image with a size
  def minus_image(size = 16)
    raw "<img src=\"/assets/images/minus.png\" width=\"#{size}\" height=\"#{size}\" alt =\"menos\"/>"
  end

  # Presents income/expense with color
  # @param [Tru, False]
  # @param Hash
  def in_out(val, options = {})
    css, txt = val > 0 ? [ "dark_green", "Ingreso" ] : [ "red", "Egreso" ]
    options[:class] = options[:class].blank? ? css : options[:class] << " #{css}"
    content_tag(:span, txt, options)
  end

  def in_out_tag(val)
    if val > 0
      content_tag(:span, ntc(val))
    else
      content_tag(:span, ntc(val), :class => 'red')
    end
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

  def show_if_search
    "display:block" if params[:search] or params[:search_div_id]
  end

  # Gets the path for inventory_operations depending if it's related to a sale
  # @param InventoryOperation
  # @return String : path
  def get_inventory_operation_path(klass)
    if klass.transaction_id.present? and klass.transaction.type == "Income"
      create_sale_inventory_operations_path
    else
      inventory_operations_path
    end
  end

  def selected_menu(page)
    "selected" if page == params[:page]
  end

  def inventory_operation_operation(io)
    if io.operation === "in"
      content_tag(:span, "ingreso", :class => "dark_green")
    else
      content_tag(:span, "egreso", :class => "red")
    end
  end

  # For presenter logic
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end
