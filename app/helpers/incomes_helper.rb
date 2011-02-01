# encoding: utf-8
module IncomesHelper
  def note_title(income)
    if income.aproved?
      "Nota"
    else
      "Proforma"
    end
  end
end
