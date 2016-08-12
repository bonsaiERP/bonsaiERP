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
    if to_model.ledgers.pendent.any?
      html = <<-EOS
      <p class="help-block">
        Los cobros o devoluciones con
        <span class="label label-warning"><i class="icon-warning"></i> Pendiente</span>
        necesitan verificación o anulación
      </p>
      EOS

      html.html_safe
    end
  end

  def paid_text
    I18n.t("income.paid")
  end

  def deliver_inventory_button
    if inventory? && !is_nulled? && !delivered?
      link_to 'javascript:;', class: 'btn btn-success', id: 'inventory-deliver-link' do
        "#{icon('icon-logout')} Entregar mercadería".html_safe
      end
    end
  end

  def inventory_devolution_button
    if inventory_was_moved?
      link_to "#{icon 'icon-login'} Devolución mercadería".html_safe, 'javascript:;',
        id: 'inventory-devolution-link', class: 'btn btn-danger'
    end
  end

end
