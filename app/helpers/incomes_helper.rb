# encoding: utf-8
module IncomesHelper
  def note_title(income)
    if income.state == "draft"
      "Proforma"
    else
      "Nota"
    end
  end

  def cash_credit(cash)
    if cash
      "Contado"
    else
      "Crédito"
    end
  end
end
