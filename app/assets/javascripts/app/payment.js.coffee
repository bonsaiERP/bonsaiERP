# Class for payments
class Payment extends Backbone.Model
  defaults:
    amount: 0.0
    interest: 0.0
    exchange_rate: 1.0

  # Check if the organisation currency is the same
  otherCurrency: ->
    @get('currency') != currency

  bindChange: (sel) ->
    $(sel).on('change:account_to', (e, data) =>
      @set('currency', data.currency)
    )

Payment.paymentOptions = (val) ->
  amt = ''
  switch val.type
    when 'Cash'
      txt = 'Caja'
    when 'Bank'
      txt = 'Banco'
    when 'Expense'
      txt = 'Egreso'
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>'
    when 'Income'
      txt = 'Ingreso'
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>'


  ['<span class="label">',txt, "</span> ", val.to_s, 
    amt, ' <span class="label label-inverse">', 
   val.currency, '</span>'].join('')

App.Payment = Payment
