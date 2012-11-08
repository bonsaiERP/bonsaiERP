# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module AccountLedgersHelper
  def al_operation(al)
    html = ""
    case al.operation
    when 'cin' then html = "<span></span>"
    when 'cout' then html = ""
    when 'pin' then html = "<span class='label'>cobro</span>"
    when 'pout' then html = ""
    when 'din' then html = ""
    when 'dout' then html = ""
    when 'null' then html = ""
    end

    html.html_safe
  end

  def link_related_ledger_account(al, money)
    case al.operation
    when 'cin' then link_to al.contact,  al.contact
    when 'cout' then html = ""
    when 'pin' then html = link_to al.transaction, al.transaction
    when 'pout' then html = link_to al.transaction, al.transaction
    when 'din' then html = ""
    when 'dout' then html = ""
    when 'null' then html = ""
    end
  end

end
