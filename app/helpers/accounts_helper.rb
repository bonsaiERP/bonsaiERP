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
end
