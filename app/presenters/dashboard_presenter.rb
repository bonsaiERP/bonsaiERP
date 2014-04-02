# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardPresenter < Struct.new(:view_context, :date_range)
  delegate :render, :link_to, to: :view_context
  delegate :incomes_by_item, :expenses_by_item, :total_incomes, :total_expenses, :total,
   :incomes_percentage, :expenses_pecentage, :incomes_dayli, :expenses_dayli, to: :report

  alias :vc :view_context

  def pendent_ledgers
    total = AccountLedger.pendent.count
    if total > 0
      link_to "<i class='icon-warning'></i> Hay #{total} transaccion(es) no verificadas".html_safe, vc.account_ledgers_path(pendent: true), class: 'text-error'
    end
  end

  def report
    @report ||= Report.new(date_range)
  end

  def present_date_range
    "del <i>#{I18n.l(date_range.date_start)}</i> al <i>#{I18n.l(date_range.date_end)}</i>".html_safe
  end
end
