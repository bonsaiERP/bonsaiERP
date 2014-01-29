class MovementHistoryPresenter < HistoryPresenter
  def changes
    history_data.map do |k, v|
      if k == :state
        "#{translate_attribute k} de #{state_trans v[:from]} a #{state_trans v[:to]}"
      elsif k == :error_messages
      elsif v.present?
        "#{translate_attribute k} de #{format_for(v[:from], v[:type])} a #{format_for v[:to], v[:type]}"
      else
        nil
      end
    end.compact.join(', ')
  end

  def state_trans(st)
    case st
    when 'draft' then 'Borrador'
    when 'due' then 'Atrasado'
    when 'approved' then 'Aprobado'
    when 'nulled' then 'Aprobado'
    end
  end

end
