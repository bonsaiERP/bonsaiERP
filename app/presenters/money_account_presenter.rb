class MoneyAccountPresenter < BasePresenter
  def active_tag
    active? ? icon('icon-ok green', 'Visible') : icon('icon-cross red', 'Invisible')
  end

  def pendent_ledgers_tag
    if pendent_ledgers.any?
      link_to template.bank_path(id, pendent: true) , class: 'text-error' do
        "#{icon 'icon-warning'} Tiene transaccines pendientes".html_safe
      end
    end
  end

  def ledgers_view
    if template.params[:pendent].present?
      pendent_ledgers.includes(:account, :account_to)
    else
      ledgers.includes(:account, :account_to)
    end
  end

  def phone_tag
    "#{icon 'icon-phone muted', 'Teléfono'} #{phone}".html_safe  if phone.present?
  end

  def mobile_tag
    "#{icon 'icon-mobile muted', 'Móvil'} #{mobile}".html_safe  if mobile.present?
  end

  def email_tag
    "#{icon 'icon-envelope muted', 'Email'} #{mobile}".html_safe  if email.present?
  end

  def address_tag
    "#{icon 'icon-building muted', 'Dirección'} #{template.nl2br address}".html_safe  if address.present?
  end
end
