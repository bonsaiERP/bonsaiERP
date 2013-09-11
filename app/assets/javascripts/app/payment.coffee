# Class for payments
class Payment extends Backbone.Model
  accountToSel: ''
  formSel: ''
  verificationSel: ''
  defaults:
    amount: 0.0
    exchange_rate: 1.0
    inverse: false
    bank: true
    type: ''
    accountsTo: []
    sameCurrency: true
    baseCurrency: ''
  #
  initialize: ->
    @set('inverse', currency != @get('baseCurrency') )
    @set('totalCurrency', _b.ntc(0))
    # select2 method to bind change
    @setAccountToSelect2()
    # set rivets
    rivets.bind($(@formSel), {payment: this})

    @on 'change:exchange_rate change:amount', @setTotalCurrency
  #
  convert: (cur, inverse) ->
    val = if @get('inverse')
      fx.convert(1, from: @get('baseCurrency'), to: cur)
    else
      fx.convert(1, from: cur, to: @get('baseCurrency'))

    val.toFixed(4) * 1
  #
  convertInverse: ->
    val = if @get('inverse')
      1 / @get('exchange_rate') * 1
    else
      @get('exchange_rate') * 1

    val
  #
  isInverse: ->
    @get('currency') != @get('baseCurrency')
  # Method to set account_to related with select2 change event
  setAccountTo: (data) ->
    other = @get('baseCurrency') == data.currency

    @set(
      currency: data.currency
      exchange_rate: @convert(data.currency)
      type: data.type
      sameCurrency: other # Used for enable disable exchange_rate
      bank: data.type is 'Bank'
    )
    @setCurrencyLabel()
  #
  setCurrencyLabel: ->
    name = currencies[@get('currency')].name
    $('span.currency').html ['<span class="label label-inverse" data-toggle="tooltip" title="', name,'">', @get('currency'),'</span>' ].join('')
  #
  setTotalCurrency: ->
    total = @convertInverse() * @get('amount')

    @set('totalCurrency', _b.ntc(total) )
  #
  setAccountToSelect2: ->
    self = this
    # Set select2 and data
    $(@accountToSel).select2(
      data: @get('accountsTo')
      formatResult: App.Payment.paymentOptions
      formatSelection: App.Payment.paymentOptions
      escapeMarkup: (m) -> m
      dropdownCssClass: 'hide-select2-search'
      placeholder: 'Seleccione la cuenta'
    )
    .on('change', (event) ->
      self.setAccountTo($(this).select2('data') )
    )
  #
  isBank: ->
    @get('type') == 'Bank'

# Class for Income
class IncomePayment extends Payment
  accountToSel: '#incomes_payment_account_to_id'
  formSel: '#income-payment-form'
  verificationSel: '#income_payment_verification'

#
class IncomeDevolution extends Payment
  accountToSel: '#incomes_devolution_account_to_id'
  formSel: '#income-devolution-form'
  verificationSel: '#income_devolution_verification'

# Class for Expemse
class ExpensePayment extends Payment
  accountToSel: '#expenses_payment_account_to_id'
  formSel: '#expense-payment-form'
  verificationSel: '#expense_payment_verification'

class ExpenseDevolution extends Payment
  accountToSel: '#expenses_devolution_account_to_id'
  formSel: '#expense-devolution-form'
  verificationSel: '#expense_devolution_verification'

Payment.paymentOptions = (val) ->
  amt = ''
  switch val.type
    when 'Cash'
      txt = 'Efectivo'
    when 'Bank'
      txt = 'Banco'
    when 'Expense'
      txt = 'Egreso'
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>'
    when 'Income'
      txt = 'Ingreso'
      amt = ' <span class="muted"> Saldo:</span> <span class="balance">' + _b.ntc(val.amount) + '</span>'


  ['<strong class="gray">',txt, "</strong> ", val.to_s,
   amt, ' <span class="label bg-black">',
   val.currency, '</span>'].join('')



App.Payment = Payment
App.IncomePayment = IncomePayment
App.IncomeDevolution = IncomeDevolution
App.ExpensePayment = ExpensePayment
App.ExpenseDevolution = ExpenseDevolution
