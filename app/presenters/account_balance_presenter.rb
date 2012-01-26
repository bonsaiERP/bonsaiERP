# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountBalancePresenter < BasePresenter
  presents :account_balance

  def link_contact_title(contact)
    case contact.class.to_s
    when "Client"   then "Clientes"
    when "Supplier" then "Proveedores"
    when "Staff"    then "Otros contactos"
    end
  end

  def accounts_to_hash(contact)
    Hash[contact.accounts.values_of(:currency_id, :amount).map do |cur, amt|
      [ cur, amt.to_f ]
    end]
  end

end
