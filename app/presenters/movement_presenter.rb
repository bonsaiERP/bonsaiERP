# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MovementPresenter < BasePresenter

  def payments
    present AccountLedgerQuery.new.payments_ordered(id), AccountLedgerPresenter
  end

  def devolutions
    present to_model.payments_devolutions.includes(:account_to).order('date  desc, id desc'), AccountLedgerPresenter
  end

  def balance?
    to_model.balance > 0
  end

  def has_error_label
    "<span class='label label-important' rel='tooltip' title='Corrija los errores'>ERROR</span>".html_safe if to_model.has_error?
  end

  def state_tag
    html = case state
    when "draft" then "<span class='b gray'>Borrador</span>"#label_tag('borrador')
    when "approved" then "<span class='b purple'>Aprobado</span>"#label_blue('aprobado')
    when "paid" then "<span class='b green'>#{ paid_text }</span>"#label_green('pagado')
    when "nulled" then "<span class='b red'>Anulado</span>"#label_red('anulado')
    end

    html.html_safe
  end

  def paid_text
    ""
  end

  def due_date_tag
    d = ""
    if is_approved?
      css = ( today > to_model.due_date ) ? "text-error" : ""
      d = "<span class='muted'>Vence el:</span> "
      d << "<span class='i #{css}'>#{ icon 'icon-time' } "
      d << l(to_model.due_date)
      d << "</span>"
    end
    d.html_safe
  end

  def description_tag
    "#{ icon 'icon-file-alt', 'Descripción'} #{ description }".html_safe if description.present?
  end

private
  def today
    @today ||= Date.today
  end
end
