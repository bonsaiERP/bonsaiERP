# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensePresenter < MovementPresenter

  def expense_payment
    Expenses::Payment.new(account_id: id, date: Date.today, amount: 0.0)
  end

  def expense_devolution
    Expenses::Devolution.new(account_id: id, date: Date.today, amount: 0)
  end

  def pendent_conciliations
    if ledgers.pendent.any?
      html = <<-EOS
      <p class="help-block">
        Los pagos o devoluciones con
        <span class="label label-warning"><i class="icon-warning-sign"></i> Pendiente</span>
        necesitan verificación o anulación
      </p>
      EOS

      html.html_safe
    end
  end

  def paid_text
    "Pagado"
  end
end
