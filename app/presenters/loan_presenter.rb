class LoanPresenter < BasePresenter
  def loan_type
    if to_model.is_a?(Loans::Receive)
      text_red 'Prestamo recibido'
    else
      text_green 'Prestamo otorgado'
    end
  end
end
