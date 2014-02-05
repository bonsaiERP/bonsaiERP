class MovementHistoryPresenter < HistoryPresenter
  def changes
    if new_item?
      template.text_green_dark "creó el #{movement}", nil, 'b'
    else
      "modificó: #{present_changes.html_safe}".html_safe
    end
  end

  def movement
  end

  def present_changes
    arr = history.map do |k, v|
      case k
      when :state then state_html(k, v)
      when :error_messages, :extras, :updater_id, :nuller_id, details_col
        nil
      else
        v.present? ? get_change(k, v) : nil
      end
    end

    [arr, extras_changes, details_changes].flatten.compact.join(', ')
  end

  def present_extras
    unless history_data['extras']['from'] == history_extras_to
      history_data['extras']['from']
    end
  end

  def get_change(k, v)
    [text_gray(translate_attribute(k), nil, 'b'), ' de ',
     code(format_for(v[:from], v[:type])), ' a ',
     code(format_for(v[:to], v[:type]))
    ].join('')
  end

  # extras hstore
  def history_extras_to
    @history_extras_to ||= Hash[
      history_data['extras']['to'].map { |k, v| [k, v.to_s] }
    ]
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

  def extras_changes
    [inventory_operation, change_no_inventory].compact
  end

  def extras
    history_data['extras']
  end

  def balance_inventory(k)
    extras[k]['balance_inventory']
  end

  def inventory_operation
  end

  def change_no_inventory
  end

  def details_changes
  end
end
