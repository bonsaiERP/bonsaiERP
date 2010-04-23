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
    ["show", "edit", "destroy"].inject([]) do |t, m|
      t << bonsai_method_path(m, klass)
    end.join(" ")
  end

  # Set the method and link for  new, edit, destroy, show
  def bonsai_method_path(m, klass)
    k = klass.class.to_s.underscore
    case(m)
      when "new" then link_to t("new"), send("new_#{k}_path", klass) 
      when "show" then link_to t("show"), klass, :class => "show_icon", :title => t("show")
      when "edit" then link_to t("edit"), send("edit_#{k}_path", klass), :class => "edit_icon", :title => t("edit")
      when "destroy" then link_to t("destroy"), klass, :method => :destroy, :confirm => t("confirm_delete"), :class => "destroy_icon", :title => t("destroy")
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
      html = "<h2>#{ t("errors_in_form", :count => f.object.errors.size) }</h2>"
      unless f.object.errors[:base].empty?
        html << "<ul>" + f.object.errors[:base].inject("") { |t, v|  t << "<li>#{v}</li>" } + "</ul>"
      end
      "<div class='errorExplanation'>#{ html }</div>"
    end
  end

  def bonsai?(val)
    val == true ? t("yes") : t("no")
  end
end
