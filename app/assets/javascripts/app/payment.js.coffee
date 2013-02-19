# Class for payments
class Payment extends Backbone.Model
  initialize: ->
    @on 'change:baseCurrency', (m, v) ->
      @set('inverse', currency != @get('baseCurrency') )
  defaults:
    amount: 0.0
    interest: 0.0
    exchange_rate: 1.0
    inverse: false
    sameCurrency: true
  convert: (cur) ->
    if @get('inverse')
      fx.convert(1, from: @get('baseCurrency'), to: cur)
    else
      fx.convert(1, from: cur, to: @get('baseCurrency'))
  isInverse: (cur) ->
    cur != @get('baseCurrency')
  # Method for select2
  bindChange: (sel) ->
    $(sel).on('change:account_to', (e, data) =>
      other = @get('baseCurrency') == data.currency
      @set({currency: data.currency, exchange_rate: @convert(data.currency), sameCurrency: other})
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
