# Helper method
paymentOptions = (val) ->
  amt = ''
  return  unless val?

  switch val.type
    when 'Cash'
      txt = 'Efectivo'
    when 'Bank'
      txt = 'Banco'
    when 'StaffAccount'
      txt = 'Personal'
    when 'Expense'
      txt = 'Egreso'
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>'
    when 'Income'
      txt = 'Ingreso'
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>'


  ['<strong class="gray">',txt, "</strong> ", _.escape(val.to_s),
   amt, ' <span class="label bg-black">',
   val.currency, '</span>'].join('')


Plugin.paymentOptions = paymentOptions
