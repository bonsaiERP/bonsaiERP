class HistoryPresenter < BasePresenter
  attr_reader :klass

  def changes
    history_data.map do |k, v|
      "#{trans_attribute k} de #{v[:from]} a #{v[:to]}"
    end.join(', ')
  end

  def set_klass(klass)
    @klass = klass.underscore
  end

  private
    def trans_attribute(k)
      t("#{klass}.attributes.#{k}") || t("common.#{k}")
    end
end
