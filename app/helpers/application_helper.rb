# encoding: utf-8 # author: Boris Barroso
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

  def active?(val)
    val ? 'Activo' : 'Inactivo'
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

  # Presents number to currency
  def ntc(val = nil, options = {})
    #number_to_currency(val.to_f, options)
    number_with_delimiter(val.to_f, t("number.format").merge(options))
  end

  # Format addres to present on the
  def nl2br(val)
    unless val.blank?
      t = val.gsub("\n", '<br/>')
      t.html_safe
    end
  end

  # Used for localization
  def lo(val, options = {})
    localize(val, options) unless val.nil?
  end

  def create_options_link
    opts = params
    opts.delete(:controller)
    opts.delete(:action)
    opts.inject("") do |s,(k,v)|
      sym = s.blank? ? '?' : '&'
      s << "#{sym}#{k}=#{v}"
    end
  end

  def jquery_tabs(text, url)
    params[:tab]
  end

  def jqueryui_ul
    content_tag(:ul, class: 'ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all') do
      yield
    end
  end

  def jquery_tabs(options = {}, &bl)
    id = options[:tab_id] || "tab"

    content_tag(:div, id: id, class: 'ui-tabs ui-widget ui-widget-content ui-corner-all') do
      yield
    end
  end

  def tab(text, url, type)
    css = 'ui-state-default ui-corner-top'
    css << ' ui-tabs-selected ui-state-active' if type === params[:tab]
    content_tag(:li, link_to(text, url), :class => css)
  end

  def tab_panel
    content_tag(:div, class: 'ui-tabs-panel ui-widget-content ui-corner-bottom') do
      yield
    end
  end

  # Presents a class with currency
  def with_currency(klass, amount = :amount, options = {})
    options = {:precision => 2}.merge(options)
    "#{number_to_currency klass.send(amount), options} <span class='labelz' title='#{klass.currency_name}'>#{klass.currency_code}</span>".html_safe
  end

  alias :wcur :with_currency


  def show_if_search
    if params[:search] || params[:search_div_id]
      'display:block'
    else
      'display:none'
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

  # Get file with exchange_rates
  def set_exchange_rates
    file1 = Rails.root.join('public', 'exchange_rates.json')
    file2 = Rails.root.join('public', 'backup_rates.json')

    if not(File.exists?(file1)) || (File.ctime(file1) < Time.now - 4.hours)
      begin
        resp = ''
        Timeout.timeout(4) { resp = %x[curl http://openexchangerates.org/api/latest.json?app_id=e406e4769281493797fcfd45047773d5] }
        r = ActiveSupport::JSON.decode(resp)
        if r['rates'].present?
          f = File.new(file2, "w+")
          f.write(resp)
          f.close

          f = File.new(file1, "w+")
          f.write(resp)
          f.close
        else
          File.read(file2)
        end
      rescue Exception => e
        logger.warn "\n#Timeout::Error getting exchange_rates.json\n"  if e.is_a?(Timeout::Error)

        f = File.new(file1, 'w+')
        txt = File.read(file2)
        f.write txt
        f.close
        txt
      end
    else
      File.read(file2)
    end
  end

  def flash_class(fla)
    case fla.to_s
    when 'error'   then 'alert alert-error'
    when 'alert', :warning then 'alert alert-warning'
    when 'notice'  then 'alert alert-success'
    end
  end

  def true_false(val)
    if val
      'icon-ok text-success'
    else
      'icon-remove text-error'
    end
  end

  def true_false_color(val)
    if val
      'icon-ok text-success'
    else
      'icon-remove text-error'
    end
  end

  def render_if(val, &block)
    content_tag(:span) { block.call } if val.present?
  end

  def bold_if(val)
    "b"  if val == true
  end

  def params_bold(val)
    params[val].present? ? 'b' : ''
  end

  def param_bold_for(key, val)
    params[key] == val ? 'b' : ''
  end

  def present_date_range(date_range)
    "del <i>#{I18n.l(date_range.date_start)}</i> al <i>#{I18n.l(date_range.date_end)}</i>".html_safe
  end

  # present search formated
  def search_tag
    if params[:search].present?
      content_tag(:span, params[:search], class: 'well pad2') do
        content_tag(:span, 'busqueda: ', class: 'muted') +
        content_tag(:strong, params[:search])
      end
    end
  end

  # Sets the path for search
  def set_search_path
    render 'layouts/set_search_path'
  end
end
