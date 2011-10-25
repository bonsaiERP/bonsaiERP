# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < BasePresenter
  presents :account_ledger

  def null_link
    h.link_to "Anular", account_ledger, :class => 'delete', 'data-confirm' => 'Esta seguro de borrar la transacción' if account_ledger.can_destroy?
  end

  def show_exchange_rate
    account_ledger.show_exchange_rate? ? 'block' : 'none'
  end

  def null_state
    h.content_tag(:span, "Anulada", :class => 'dashlet b bg_red') if account_ledger.nulled?
  end

  def exchange_rate_hint
    html = "Tipo de cambio: <a href='javascript:' id ='suggested_exchange_rate'>#{h.ntc(0, :precision => 4)}</a>"
    html << ", Invertirdo: <a href='javascript:' id='suggested_inverted_rate'>#{h.ntc(0, :precision => 4)}</a>"
    html.html_safe
  end

  def exchange_rate
    unless account_ledger.exchange_rate == 1
      html = "#{account_ledger.account.currency_symbol} 1 = "
      if account_ledger.transaction_id.present?
        html << "#{h.currency_symbol} "
      elsif account_ledger.to_id.present?
        html << "#{account_ledger.to.currency_symbol} "
      end
      html << h.ntc(account_ledger.exchange_rate, :precision => 4)
      html
    end
  end

  # Presents the account select
  def account_select(ac)
    html = "#{ac.name} (<strong>#{ac.currency_symbol} #{h.ntc ac.amount.abs}</strong>) "
    case ac.original_type
    when "Bank"
      html << "<span class='dashlet bg_green'>Banco</span>"
    when "Cash"
      html << "<span class='dashlet bg_green'>Caja</span>"
    when "Client"
      html << "<span class='dashlet bg_dark'>Cliente</span>"
    when "Supplier"
      html << "<span class='dashlet bg_dark'>Proveedor</span>"
    when "Staff"
      html << "<span class='dashlet bg_dark'>Personal</span>"
    end

    html.html_safe
  end

  def selected_account
    if account_ledger.account_id.present?
      account_select(account_ledger.account)
    else
      "<span class='grey'>Seleccione una cuenta</span>".html_safe
    end
  end
end
