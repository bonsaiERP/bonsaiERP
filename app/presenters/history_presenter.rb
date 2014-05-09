class HistoryPresenter < BasePresenter
  attr_reader :klass

  def changes
    if new_item?
      template.text_green_dark 'creó el registro', nil, 'b'
    else
      if (ch = present_changes).present?
        ch.html_safe
      else
        'modificó la fecha de actualización'.html_safe
      end
    end
  end

  def present_changes
    history.except('updated_at').map do |key, val|
      from, to = format_for(val[:from], val[:type]), format_for(val[:to], val[:type])
      "#{attr_text key} de #{code from} a #{code to}"
    end.join(', ')
  end

  def klass
    @klass ||= klass_type.underscore
  end

  private

    def translate_attribute(k)
      t("#{t_klass}.attributes.#{k}") || t("common.#{k}")
    end

    def attr_text(k)
      text_gray(translate_attribute(k), nil, 'b')
    end

    def t_klass
      @t_klass ||= klass.to_s.split('/').join('.')
    end

    def format_for(val, typ)
      case typ
      when 'string', 'text', 'integer', 'float'
        val
      when 'boolean'
        "<i class='icon-#{val}'></i>"
      when 'date', 'datetime', 'time'
        context.lo val
      when 'decimal'
        context.ntc val
      end
    end
end
