# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MovementPresenter < BasePresenter

  def present_ledgers
    present AccountLedgers::Query.new.payments_ordered(id), AccountLedgerPresenter
  end
  alias_method :payments_and_devolutions, :present_ledgers

  def pendent_ledgers
    present AccountLedgers::Query.new.payments_ordered(id).pendent, AccountLedgerPresenter
  end

  #def payments_devolutions
  #  to_model.ledgers.includes(:account_to).order('date  desc, id desc')
  #end

  def balance?
    to_model.balance > 0
  end

  def has_error_label
    "<span class='label label-important' rel='tooltip' title='Corrija los errores'>ERROR</span>".html_safe if to_model.has_error?
  end

  def state_tag
    case
    when is_draft? then template.text_gray 'Borrador', '', 'b'
    when(is_approved? && today > to_model.due_date)
      "<span class='b text-error'>Atrasado</span>".html_safe
    when is_approved? then template.text_green 'Aprovado', '', 'b'
    when is_paid? then template.text_green_dark 'Pagado', '', 'b'
    when is_nulled? then template.text_red 'Anulado', '', 'b'
    end
  end

  def state_text
    case state
    when(is_approved? && today > to_model.due_date) then 'Atrasado'
    when 'draft' then 'Borrador'
    when 'approved' then 'Aprobado'
    when 'paid' then paid_text
    when 'nulled' then 'Anulado'
    end
  end

  def paid_text
    ""
  end

  def inventory_tag
    if is_active?
      case
      when delivered?
        label_green('IC', 'Inventario completo')
      when no_inventory?
        label_gray('ID', 'Inventario desactivado')
      else
        label_yellow('IP', 'Inventario pendiente')
      end
    end
  end


  def due_date_tag
    d = ""
    if is_approved?
      css = ( today > to_model.due_date ) ? "text-error" : ""
      d = "<span class='muted text-muted'>Vence el:</span> "
      d << "<span class='i #{css}'>#{ icon 'icon-time' } "
      d << l(to_model.due_date)
      d << "</span>"
    end
    d.html_safe
  rescue
    ''
  end

  def description_tag
    "#{ icon 'icon-file muted', 'Descripción'} #{ sanitize description }".html_safe if description.present?
  end

  def enable_disable_inventory_text_tag
    if no_inventory?
      "<span class='green'>#{icon('icon-off')} Activar inventario</span>".html_safe
    else
      "<span class='red'>#{icon('icon-off')} Desactivar inventario</span>".html_safe
    end
  end

  # show enable disable inventory
  def enable_disable_inventory?
    active? && !delivered? && !is_draft?
  end

  def enable_disable_inventory_button
    if !is_nulled? && !delivered?
      template.content_tag :h5, class: 'n ib' do
        link_to enable_disable_inventory_text, template.inventory_income_path(id),
          method: :patch, class: (no_inventory? ? 'green' : 'red')
      end
    end
  end

  def enable_disable_inventory_text
    if no_inventory?
      'Activar inventario'
    else
      'Desactivar inventario'
    end
  end

  # Value to enable disable inventory
  def enable_disable_inventory_val
    if no_inventory?
      false
    else
      true
    end
  end

  def show_inventory_buttons?
    !no_inventory? && !is_nulled?
  end

  def tax_tag
    "#{tax_name} (#{tax_type_tag} #{tax_percentage_dec}%)".html_safe
  end

  def tax_type_tag
    if tax_in_out?
      '<small class="n">por dentro</small>'
    else
      '<small class="n">por fuera</small>'
    end
  end

  def tax_icon
    if tax_in_out
      icon 'icon-collapse-alt fs130', 'Por dentro'
    else
      icon 'icon-expand-alt fs130', 'Por fuera'
    end
  end

  private

    def today
      @today ||= Date.today
    end
end
