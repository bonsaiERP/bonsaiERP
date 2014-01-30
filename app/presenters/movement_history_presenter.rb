class MovementHistoryPresenter < HistoryPresenter
  def changes
    if new_item?
      template.text_green_dark "creó el #{movement}", nil, 'b'
    else
      "modificó: #{present_changes.html_safe}".html_safe
    end
  end

  def movement
    @movement_type ||= klass_type == 'Income' ? 'Ingreso' : 'Egreso'
  end

  def present_changes
    history_data.map do |k, v|
      if k == :state
        state_html(k, v)
      elsif k == :error_messages
      elsif v.present?
        "#{text_gray(translate_attribute(k), nil, 'b')} de #{code(format_for(v[:from], v[:type]))} a #{code(format_for(v[:to], v[:type]))}"
      else
        nil
      end
    end.compact.join(', ')
  end

  def state_html(k, v)
    [translate_attribute(k), ' de ',
     state_trans(v[:from]), ' a ', state_trans(v[:to])
    ].join('')
  end

  def state_trans(st)
    case st
    when 'draft' then text_gray('Borrador', nil, 'b')
    when 'due' then '<span class="text-error b">Atrasado</span>'
    when 'approved' then text_green('Aprobado', nil, 'b')
    when 'paid' then text_green_dark('pagado', nil, 'b')
    when 'nulled' then text_red('Anulado', nil, 'b')
    end
  end
end
