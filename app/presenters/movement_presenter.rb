# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MovementPresenter < BasePresenter

  def present_ledgers
    present AccountLedgerQuery.new.payments_ordered(id), AccountLedgerPresenter
  end
  alias_method :payments_and_devolutions, :present_ledgers

  def pendent_ledgers
    present AccountLedgerQuery.new.payments_ordered(id).pendent, AccountLedgerPresenter
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
    html = case state
    when 'draft' then "<span class='b gray-light'>Borrador</span>"
    when 'approved' then "<span class='b bonsai-dark'>Aprobado</span>"
    when 'paid' then "<span class='b green-dark'>#{ paid_text }</span>"
    when 'nulled' then "<span class='b red'>Anulado</span>"
    end

    html.html_safe
  end

  def state_text
    case state
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

  def enable_disable_inventory_text
    if no_inventory?
      "Activar inventario"
    else
      "Desactivar inventario"
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

  def enable_disable_button_css
    if no_inventory?
      'btn btn-success'
    else
      'btn btn-danger'
    end
  end

  def show_inventory_buttons?
    not(no_inventory?) && OrganisationSession.inventory_active?
  end

private
  def today
    @today ||= Date.today
  end
end
