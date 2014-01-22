class MoneyAccountPresenter < BasePresenter
  def active_tag
    active? ? icon('icon-ok green', 'Visible') : icon('icon-remove red', 'Invisible')
  end

  def pendent_ledgers_tag
    if pendent_ledgers.any?
      link_to template.bank_path(id, pendent: true) , class: 'text-error' do
        "#{icon 'icon-warning-sign'} Tiene transaccines pendientes".html_safe
      end
    end
  end

  def ledgers_view
    if template.params[:pendent].present?
      pendent_ledgers
    else
      ledgers
    end
  end
end
