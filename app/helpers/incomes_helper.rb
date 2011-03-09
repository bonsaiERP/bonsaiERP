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

  # Links for incomes
  def link_incomes(text, option, options = {})
    params[:option] = 'all' if params[:option].nil?
    active = (params[:option] == option) ? "active" : ""
    link_to text, incomes_path(:option => option), options.merge(:class => active)
  end
end
