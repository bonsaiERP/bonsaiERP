class HistoryPresenter < BasePresenter
  attr_reader :klass

  def changes
    history_data.map do |k, v|
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
