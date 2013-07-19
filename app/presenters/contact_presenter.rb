# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactPresenter < BasePresenter
  def address_tag
    "#{ icon 'icon-building muted', 'Dirección' } #{address}".html_safe if address.present?
  end

  def phone_tag
    "#{ icon 'icon-phone muted', 'Teléfono' } #{phone}".html_safe if phone.present?
  end

  def email_tag
    "#{ icon 'icon-envelope muted', 'Email' } #{email}".html_safe if email.present?
  end

  def tax_number_tag
    "#{ icon 'icon-barcode muted', 'Código tributario' } #{tax_number}".html_safe if tax_number.present?
  end

  def mobile_tag
    "#{ icon 'icon-mobile-phone muted', 'Móvil' } #{mobile}".html_safe if mobile.present?
  end
end
