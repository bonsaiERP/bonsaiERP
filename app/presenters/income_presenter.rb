# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomePresenter < MovementPresenter

  def income_payment
    Incomes::Payment.new(account_id: id, date: Date.today, amount: 0)
  end

  def income_devolution
    Incomes::Devolution.new(account_id: id, date: Date.today, amount: 0)
  end

  def pendent_conciliations
    if ledgers.pendent.any?
      html = <<-EOS
      <p class="help-block">
        Los cobros o devoluciones con
        <span class="label label-warning"><i class="icon-warning-sign"></i> Pendiente</span>
        necesitan verificación o anulación
      </p>
      EOS

      html.html_safe
    end
  end
end
