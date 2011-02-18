module AccountLedgersHelper
  def with_payment(al)
    if al.payment
      txt = ntc(al.payment_amount) + ' + ' + ntc(al.payment_interests_penalties)

      link_to(txt, "/payments/#{al.payment_id}/transaction", :title => 'Cantidad + intereses/penalidades')
    end
  end
end
