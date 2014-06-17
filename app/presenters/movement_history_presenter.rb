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
    res = [filter_changes, details_changes].flatten.compact.join(', ')

    if res.present?
      res
    else
      'La fecha de modificación'
    end
  end

  def filter_changes
    @filter_changes ||= history.except('updated_at').map do |key, val|
      case key
      when 'state' then state_html(key, val)
      when 'error_messages', 'extras', 'updater_id',
           'nuller_id', 'approver_id', 'balance_inventory',
           'operation_type', details_col.to_s
        nil
      else
        val.present? ? get_change(key, val) : nil
      end
    end
  end

  def get_change(key, val)
    return  if val.is_a?(Array)

    get_history_attribute(key, val)
  end

  def get_history_attribute(key, val)
    case key
    when 'delivered' then
      inventory_state(val)
    else
      present_history_attribute(key, val)
    end
  end

  def present_history_attribute(key, val)
   [attr_text(key), ' de ',
     code(format_for(val[:from], val[:type])), ' a ',
     code(format_for(val[:to], val[:type]))
    ].join('')
  end

  # extras hstore
  def history_extras_to
    @history_extras_to ||= Hash[
      history_data['extras']['to'].map { |k, v| [k, v.to_s] }
    ]
  end

  def inventory_state(val)
    ['Inventario de', code(inventory_tag(val[:from])), code(inventory_tag(val[:to]))].join('')
  end

  def inventory_tag(val)
    if val
      label_green('IC', 'Inventario completo')
    else
      label_yellow('IP', 'Inventario pendiente')
    end
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
    if history_data[details_col.to_s].present?
      [context.link_to('Cambio en ítems', context.movement_detail_history_path(id) , class: 'ajax')]
    end
  end
end
