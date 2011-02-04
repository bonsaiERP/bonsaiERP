# encoding: utf-8
module IncomesHelper
  def note_title(income)
    if income.state == "draft"
      "Proforma"
    else
      "Nota"
    end
  end
end
