class HistoryPresenter < BasePresenter
  attr_reader :klass

  def changes
    if new_item?
      template.text_green_dark 'creó el registro', nil, 'b'
    else
      present_changes
    end
  end

  def present_changes
    history.map do |k, v|
      "#{translate_attribute k} de #{v[:from]} a #{v[:to]}"
    end.join(', ')
  end

  def klass
    @klass ||= klass_type.underscore
  end

  private

    def translate_attribute(k)
      t("#{klass}.attributes.#{k}") || t("common.#{k}")
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
