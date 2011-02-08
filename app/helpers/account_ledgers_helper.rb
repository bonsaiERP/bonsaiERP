module AccountLedgersHelper
  def with_payment(al)
    if al.payment
      txt = ntc(al.payment_amount)
      txt << "; ( Intereses: #{ntc(al.payment_interests_penalties)} )" if al.payment_interests_penalties > 0
      link_to(txt, "/payments/#{al.payment_id}/transaction")
    end
  end
end
