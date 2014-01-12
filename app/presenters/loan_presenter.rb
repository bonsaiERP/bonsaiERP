class LoanPresenter < BasePresenter
  def loan_type
    if to_model.is_a?(Loans::Receive)
      text_red 'Prestamo recibido'
    else
      text_green 'Prestamo otorgado'
    end
  end

  def payment_path
    if is_receive?
      template.new_receive_loan_payment_path(id)
    else
      template.new_give_loan_payment_path(id)
    end
  end

  def interest_path
    if is_receive?
      template.new_interest_receive_loan_payment_path(id)
    else
      template.new_interest_give_loan_payment_path(id)
    end
  end

  def payment_link
    if is_receive?
      link_to payment_path, class: 'btn btn-success', data: { target: '#payment-form' } do
       "#{icon('icon-minus-sign')} Pagar prestamo".html_safe
      end
    else
      link_to payment_path, class: 'btn btn-success', data: { target: '#payment-form' } do
        "#{icon('icon-plus-sign')} Cobrar prestamo".html_safe
      end
    end
  end

  def interest_link
    if is_receive?
      link_to interest_path, class: 'btn btn-success', data: { target: '#interest-form' } do
       "#{icon('icon-minus-sign')} Pagar prestamo".html_safe
      end
    else
      link_to interest_path, class: 'btn btn-success', data: { target: '#interest-form' } do
        "#{icon('icon-plus-sign')} Cobrar prestamo".html_safe
      end
    end
  end

  def is_give?
    @is_give ||= to_model.is_a? Loans::Give
  end

  def is_receive?
    @is_receive ||= to_model.is_a? Loans::Receive
  end
end
