# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardPresenter < Struct.new(:view_context)
  delegate :render, :link_to, to: :view_context

  alias :vc :view_context

  def pendent_ledgers
    total = AccountLedger.pendent.count
    if total > 0
      link_to "<i class='icon-warning-sign'></i> Hay #{total} transaccion(es) no verificadas".html_safe, vc.account_ledgers_path, class: 'text-error'
    end
  end
end
