class Loans::ReceivePresenter < BasePresenter
  def loan_type
    text_red 'Prestamo recibido'
  end

  def payment_path
    template.new_pay_loan_payment_path(id)
  end

  def interest_path
    template.new_pay_interest_loan_payment_path(id)
  end

  def payment_link
    link_to payment_path, class: 'btn btn-success', data: { target: '#payment-form' } do
     "#{icon('icon-minus-sign')} Pagar prestamo".html_safe
    end
  end

  def interest_link
    link_to interest_path, class: 'btn btn-success', data: { target: '#interest-form' } do
     "#{icon('icon-minus-sign')} Pagar prestamo".html_safe
    end
  end
end

