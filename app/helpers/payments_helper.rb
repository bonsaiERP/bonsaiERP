# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
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

  # Creates part fo the title for payments
  def transaction_title(klass)
    case klass.type
    when 'Income'  then "Venta #{klass.ref_number}"
    when 'Buy'     then "Compra #{klass.ref_number}"
    when 'Expense' then "Gasto #{klass.ref_number}"
    end
  end

  def transaction_payment_type(klass)
    case klass.type
    when 'Income'         then "cobro"
    when 'Buy', 'Expense' then "pago"
    end
  end

  def delete_confirm(klass)
    if klass.paid?
      "Borrar este registro creara una transacción con la cuenta relacionada"
    else
      "Borrar este registro borrara la transacción con la cuenta relacionada"
    end
  end
end
