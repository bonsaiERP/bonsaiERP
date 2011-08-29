module ContactsHelper
  # Sets the contact type
  def contact_type(type, plural = true)
    if type == 'clients'
      plural ? 'Clientes' : 'cliente'
    elsif type == "suppliers"
      plural ? 'Proveedores' : 'proveedor'
    end
  end

  def link_contact_ledger(al, account_ids)
    if al.transaction_id.present?
      link_to al.transaction, al.transaction
    else
      if account_ids.include?(al.account_id)
        link_to al.to, get_account_contact_url(al.to)
      else
        link_to al.account, get_account_contact_url(al.account)
      end
    end
  end

  def get_account_contact_url(ac)
    case ac.original_type
    when "Bank"
      "/banks/#{ac.accountable_id}"
    when "Cash"
      "/cashes/#{ac.accountable_id}"
    end
  end
end
