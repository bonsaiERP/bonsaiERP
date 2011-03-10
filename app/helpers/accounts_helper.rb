module AccountsHelper
  def with_payment(al)
    if al.payment
      txt = ntc(al.payment_amount) + ' + ' + ntc(al.payment_interests_penalties)

      link_to(txt, "/payments/#{al.payment_id}/transaction", :title => 'Cantidad + intereses/penalidades')
    end
  end

  # Creates a link to the transaction if exists
  def link_description(al)
    if al.transaction_id
      link_to al.description, al.transaction
    else
      al.description
    end
  end

  # links to the correct account for account_ledger
  def link_account(al)
    case al.account_type
    when"Bank" then link_to "Bancos", al.account
    when"CashRegister" then link_to "Cajas", al.account
    end
  end
end
