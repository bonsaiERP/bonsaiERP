module PaymentsHelper
  def nulled_payment(pay_type, payment)
    if payment.transaction_paid?
      ''
    elsif payment.active
      link_to "Anular #{pay_type}", null_payment_payment_path(payment), 'data-method' => 'put', :class => 'null null_payment'
    else
      'Anulado'
    end
  end
end
