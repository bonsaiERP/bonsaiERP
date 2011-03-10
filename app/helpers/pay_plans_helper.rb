# encoding: utf-8
module PayPlansHelper
  def pay_plan_state(state)
    case state
    when "Aplicado"
      css = "dark_grey"
    when "Válido"
      css = ""
    when "Atrasado"
      css ="red"
    end
    "<span class='#{css}'>#{state}</span>".html_safe
  end

end
