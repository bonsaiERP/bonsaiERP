class HistoryPresenter < BasePresenter
  attr_reader :klass

  def changes
    history_data.map do |k, v|
      "#{translate_attribute k} de #{v[:from]} a #{v[:to]}"
    end.join(', ')
  end

  def klass(klass)
    @klass = klass.underscore
  end

  private

    def translate_attribute(k)
      t("#{klass}.attributes.#{k}") || t("common.#{k}")
    end
end
