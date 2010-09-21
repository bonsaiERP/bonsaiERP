# Especial methods created to make easier the development
module BonsaiHelper

  # Class that helps to translate and creates a block
  class TranslateBlock
    # @param klass
    # @param wrap
    # @param cp content_tag
    def initialize(klass, wrap, ct)
      @klass, @wrap, @ct = klass, wrap, ct
    end

    def translate(*args)
      attribute, options = args.shift, set_options(args.shift)
      @ct.call(@wrap, I18n.t("activerecord.attributes.#{@klass}.#{attribute}"), options )
    end
    alias t translate

    def set_options(options={})
      options ||= {}
      options[:style] = "width: #{options.delete(:width)}px;" << options[:style].to_s unless options[:width].nil?
      options
    end
  end


  def bonsai_block(model, wrap, b)
    kontent_tag = lambda{ |wrap, text, options| content_tag(wrap, text, options) }
    model = model.class == String ? model : model.class.to_s.underscore
    b.call(TranslateBlock.new(model, "th", kontent_tag) )
  end

  def bonsai_th(model, &b)
    bonsai_block(model, "th", b)
    return
  end

  # Creates the links show, edit, destroy
  def bonsai_links(klass, options={})
    ["edit", "destroy"].inject([]) do |t, m|
      t << bonsai_method_path(m, klass)
    end.join(" ").html_safe
  end

  # Set the method and link for  new, edit, destroy, show
  def bonsai_method_path(m, klass)
    k = klass.class.to_s.underscore
    case(m)
      when "new" then link_to "nuevo", send("new_#{k}_path", klass) 
      when "show" then link_to "ver", klass, :class => "show_icon", :title => "Ver"
      when "edit" then link_to "editar", send("edit_#{k}_path", klass), :class => "edit_icon", :title => "Editar"
      when "destroy" then link_to "borrar", klass, :method => :delete, :confirm => "Esta seguro?", :class => "destroy_icon", :title => "Borrar", :remote => true
      else ""
    end
  end

  #
  def bonsai_title()
    if params[:action] == "index"
      t("controllers.#{ params[:controller] }.other")
    elsif params[:action] == "show"
      t("controllers.#{ params[:controller] }.one")
    else
      t(params[:action]) + ' ' + t("controllers.#{params[:controller]}.one").downcase
    end
  end

  # Shows the base errors
  # @param [FormBuilder]
  def bonsai_form_error(f)
    unless f.object.errors.empty?
      html = content_tag('h2', 'Exiten errores en el formulario')
      unless f.object.errors[:base].empty?
        html << "<ul>" + f.object.errors[:base].inject("") { |t, v|  t << "<li>#{v}</li>" } + "</ul>"
      end
      "<div class='errorExplanation'>#{ html }</div>".html_safe
    end
  end

  def bonsai?(val)
    #val == true ? t("yes") : t("no")
    val ? "Si" : "No"
  end
end
