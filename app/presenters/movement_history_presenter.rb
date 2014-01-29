class MovementHistoryPresenter < HistoryPresenter
  def changes
    history_data.map do |k, v|
      "#{translate_attribute k} de #{v[:from]} a #{v[:to]}"
    end.join(', ')
  end
end
