# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < Resubject::Presenter
  def conciliation_tag
    html = if conciliation?
            "<i class='icon-ok text-success' title='Verficado' rel='tooltip'></i>"
           else
             "<i class='icon-remove text-error' title='No verficado' rel='tooltip'></i>"
           end

    html.html_safe
  end

  include UsersModulePresenter

  def initials(name)
    name.split(' ').map(&:first).join('')
  end

  def operation_label
    case to_model.operation
    when 'payin', 'intin'
      "<span class='label label-success' >#{operation}</span>"
    when 'payout', 'intout'
      "<span class='label label-error' >#{operation}</span>"
    end
  end

  def account_contact_tag
    html = ""
    if account_contact
      html << "<i class='icon-user'></i> #{account_contact}"
    end

    html.html_safe
  end

  def operation
    case to_model.operation
    when 'payin'
      'Cobro'
    when 'intin'
      'Cobro Int.'
    when 'payout'
      'Pago'
    when 'intout'
      'Pago Int.'
    when 'devin'
      'Devolución'
    end
  end

  def operation_tag
    text = operation
    css = case to_model.operation
          when 'payin', 'intin', 'devout'
            'label-success'
          when 'payout', 'intout', 'devin'
            'label-important'
          end

    "<span class='label #{css}'>#{text}</span>".html_safe
  end
end
