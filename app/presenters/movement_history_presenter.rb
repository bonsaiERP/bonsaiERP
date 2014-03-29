class MovementHistoryPresenter < HistoryPresenter
  def changes
    if new_item?
      template.text_green_dark "creó el #{movement}", nil, 'b'
    else
      present_changes.html_safe
    end
  end

  def movement
  end

  def present_changes
    res = [filter_changes, mov_extras_changes, details_changes].flatten.compact.join(', ')
    if res.present?
      res
    else
      'La fecha de modificación'
    end
  end

  def filter_changes
    @filter_changes ||= history.map do |k, v|
      case k
      when :state then state_html(k, v)
      when :error_messages, :extras, :updater_id, :nuller_id, :approver_id, details_col
        nil
      else
        v.present? ? get_change(k, v) : nil
      end
    end
  end

  def present_extras
    unless history_data['extras']['from'] == history_extras_to
      history_data['extras']['from']
    end
  end

  def get_change(k, v)
    [attr_text(k), ' de ',
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

  def mov_extras_changes
    [inventory_operation, change_inventory].compact
  end

  def mov_extras
    history_data['extras']
  end

  def balance_inventory(k)
    mov_extras[k]['balance_inventory']
  end

  def inventory_operation;  end

  def change_inventory
    return  if mov_extras.blank? || mov_extras['from']['inventory'].blank?
    from, to = mov_extras['from']['inventory'], mov_extras['to']['inventory']
    if from.present? || to.present?
      arr = ['Inventario INACTIVO', 'Inventario ACTIVO']
      from, to = from.to_s == 'true' ? arr.reverse : arr
      "#{attr_text 'inventory'} de #{code from} a #{code to}"
    end
  end

  def details_changes

  end
end
