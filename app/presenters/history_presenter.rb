class HistoryPresenter < BasePresenter
  attr_reader :klass

  def changes
    if new_item?
      template.text_green_dark 'creó el registro', nil, 'b'
    else
      if (ch = present_changes).present?
        "modificó: <br/>#{ch}".html_safe
      else
        'modificó la fecha de actualización'.html_safe
      end
    end
  end

  def present_changes
    history.map do |k, v|
      from, to = get_format(v[:from], v[:type]), get_format(v[:to], v[:type])
      "#{attr_text k} de #{code from} a #{code to}"
    end.join(', ')
  end

  def klass
    @klass ||= klass_type.underscore
  end

  private

    def get_format(v, type)
      case type
      when 'boolean'
        "<i class='icon-#{v}'></i>"
      when 'decimal', 'float'
        context.ntc v
      else
        v
      end
    end

    def translate_attribute(k)
      t("#{klass}.attributes.#{k}") || t("common.#{k}")
    end

    def attr_text(k)
      text_gray(translate_attribute(k), nil, 'b')
    end

    def code(txt)
      "<code class='gray'>#{txt}</code>"
    end

    def format_for(val, typ)
      case typ
      when 'string', 'integer', 'boolean', 'float'
        val
      when 'date', 'datetime', 'time'
        template.l val
      when 'decimal'
        template.ntc val
      end
    end
end
