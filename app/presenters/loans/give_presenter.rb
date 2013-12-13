class Loans::GivePresenter < BasePresenter
  def loan_type
    text_green 'Prestamo otorgado'
  end

  def payment_path
    template.new_charge_loan_payment_path(id)
  end

  def interest_path
    template.new_charge_interest_loan_payment_path(id)
  end

  def payment_link
    link_to payment_path, class: 'btn btn-success', data: { target: '#payment-form' } do
      "#{icon('icon-plus-sign')} Cobrar prestamo".html_safe
    end
  end

  def interest_link
    link_to interest_path, class: 'btn btn-success', data: { target: '#interest-form' } do
      "#{icon('icon-plus-sign')} Cobrar prestamo".html_safe
    end
  end

end

