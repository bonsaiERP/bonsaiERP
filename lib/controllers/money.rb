module Controllers::Money
  def show(account)
    ledgers = account.get_ledgers
    case params[:option]
    when "nulled"
      ledgers.nulled
    when "uncon"
      ledgers.pendent
    when "con"
      ledgers.con
    else
      params[:option] = "all"
      ledgers
    end
  end
end

