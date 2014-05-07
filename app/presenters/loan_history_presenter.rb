class LoanHistoryPresenter < HistoryPresenter
  def changes
    if new_item?
      template.text_green_dark 'creó el registro', nil, 'b'
    else
      if (ch = present_changes).present?
        "modificó: <br/>#{ch}".html_safe
      else
        'modificó la fecha de actualización'.html_safe
      end
    end
  end

  def present_changes
    arr = history.except('extras').map do |k, v|
      from, to = format_for(v[:from], v[:type]), format_for(v[:to], v[:type])
      "#{attr_text k} de #{code from} a #{code to}"
    end
    arr << extra_changes
    arr.compact.join(', ')
  end

  def extra_changes
    if lextras.present? && (lextras['to'].present? || lextras['from'].present?)
      interests_changes  if lextras['to']['interests'].present?
    end
  end

  def interests_changes
    from = context.ntc get_lextras_from('interests')
    to = context.ntc get_lextras_to('interests')
    "#{attr_text 'interests'} de #{code from} a #{code to}"
  end

  def get_lextras_from(key)
    get_lextras('from', key)
  end

  def get_lextras_to(key)
    get_lextras('to', key)
  end

  def get_lextras(al, key)
    lextras[al][key]
  rescue
    nil
  end

  def lextras
    history_data['extras']
  end
end
