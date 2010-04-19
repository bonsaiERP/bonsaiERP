module BonsaiHelper

  class TranslateBlock
    # @param klass
    # @param wrap
    # @param cp content_tag
    def initialize(klass, wrap, ct)
      @klass, @wrap, @ct = klass, wrap, ct
    end

    def translate(*args)
      attribute, options = args.shift, set_options(args.shift)
      @ct.call(@wrap, I18n.t("activerecord.attributes.#{@klass.class.to_s.underscore}.#{attribute}"), options )
    end
    alias t translate

    def set_options(options={})
      options[:style] = "width: #{options.delete(:width)}px;" << options[:style].to_s unless options[:width].nil?
      options
    end
  end


  def bonsai_block(model, wrap, b)
    kontent_tag = lambda{|wrap, text, options| content_tag(wrap, text, options) }
    b.call(TranslateBlock.new(model, "th", kontent_tag) )
  end

  def bonsai_th(model, &b)
    bonsai_block(model, "th", b)
    return
  end

  def bonsai_links(klass, options={})
    ["show", "edit", "destroy"].inject([]) do |t, m|
      t << bonsai_method_path(m, klass)
    end.join(" ")
  end

  def bonsai_method_path(m, klass)
    k = klass.class.to_s.underscore
    case(m)
      when "new" then link_to t("new"), send("new_#{k}_path", klass) 
      when "show" then link_to t("show"), klass
      when "edit" then link_to t("edit"), send("edit_#{k}_path", klass)
      when "destroy" then link_to t("destroy"), klass, :method => :destroy, :confirm => t("confirm_delete") 
      else ""
    end
  end

end
