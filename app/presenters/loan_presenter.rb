# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class LoanPresenter < BasePresenter
  presents :loan

  def new_title
    if loan.is_a?(Loanin)
      "Recibir prestamo"
    else
      "Dar prestamo"
    end
  end

  def loan_url
    if loan.persisted?
      h.edit_loan_path(loan.id)
    else
      h.loans_path
    end
  end

  def account_currencies
    Hash[Account.money.values_of(:id, :currency_id)]
  end
end
