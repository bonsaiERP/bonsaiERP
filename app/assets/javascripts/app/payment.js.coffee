# Class for payments
class @Payment


@Payment.paymentOptions = (val) ->
  amt = ''
  switch val.type
    when 'Cash'
      txt = 'Caja'
    when 'Bank'
      txt = 'Banco'
    when 'Expense'
      txt = 'Egreso'
      amt = " <span class='muted'> Saldo:</span> <span class='balance'>" + _b.ntc(val.balance) + "</span>"
    when 'Income'
      txt = 'Ingreso'
      amt = " <span class='muted'> Saldo:</span> <span class='balance'>" + _b.ntc(val.balance) + "</span>"


  ['<span class="label">',txt, "</span> ", val.to_s, 
    amt, " <span class='label label-inverse'>", 
   val.currency, "</span>"].join('')
