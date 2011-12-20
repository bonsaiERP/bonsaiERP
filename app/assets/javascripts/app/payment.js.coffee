# Class for payments
class Payment
  # constructor
  constructor: (@accounts, @currencies, @account_data, @currency_id)->
    @$account   = $('#account_ledger_account_id')
    @$amount    = $('#account_ledger_base_amount')
    @$interests = $('#account_ledger_interests_penalties')

    @rate = {}

    @.setEvents()
  start:->
    @.calculateTotal()
  # events
  setEvents: ->
    self = @

    # amount interests_penalties
    $('input.amt').die()
    $('input.amt').live 'focusout keyup', (event)=>
      return false if _b.notEnter(event)
      @.calculateTotal()

    $('#account_ledger_exchange_rate').on 'change:rate', (event, rate)=>
      @rate = rate
      @.setCurrency()
      $('#account_ledger_exchange_rate').val(rate.rate.round(4)).trigger('focusout')

  # Callback for dropdown
  setAccount: (id, val)->
    $('#account_ledger_account_id').val(id).trigger("change")
  # Show currency
  showCurrency: (currency_id)->
    symbol = @currencies[currency_id].symbol
    $("span.currency").html("(#{symbol})")

    @.showExchange currency_id != @currency_id

  # Calculates total
  calculateTotal: ->
    amount   = @$amount.val() * 1
    int      = @$interests.val() * 1 || 0

    rate = $('#account_ledger_exchange_rate').val() * 1
    try
      if @currency_id != organisation.currency_id and  organisation.currency_id == @rate.currency.id
        rate = 1/rate
    catch e

    total = (amount + int) * (rate || 1)
    $('#payment_total_currency').html(_b.ntc(total))
  # Sets the currency for all items
  setCurrency: ->
    $('#payment_form span.currency').html(@rate.currency.symbol)

window.Payment = Payment
