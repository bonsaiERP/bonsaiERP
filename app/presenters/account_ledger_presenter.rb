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

  def exchange_rate_hint
    html = "Tipo de cambio: <a href='javascript:' id ='suggested_exchange_rate'>#{h.ntc(0, :precision => 4)}</a>"
    html << ", Invertirdo: <a href='javascript:' id='suggested_inverted_rate'>#{h.ntc(0, :precision => 4)}</a>"
    html.html_safe
  end

  def exchange_rate
    unless account_ledger.exchange_rate == 1
      html = "#{account_ledger.account.currency_symbol} 1 = "
      html << "#{account_ledger.to.currency_symbol} "
      html << h.ntc(account_ledger.exchange_rate, :precision => 4)
      html
    end
  end
end
