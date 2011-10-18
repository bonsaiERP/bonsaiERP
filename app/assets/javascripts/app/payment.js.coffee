# Class for payments
class Payment
  # constructor
  constructor: (@accounts, @currencies, @account_data, @currency_id)->
    @$account   = $('#account_ledger_account_id')
    @$amount    = $('#account_ledger_base_amount')
    @$interests = $('#account_ledger_interests_penalties')
    @$exchange  = $('#account_ledger_exchange_rate')
    @$exchange.val(1) if @$exchange.val() * 1 == 0

    @.setEvents()
    @.calculateTotal()
  # events
  setEvents: ->
    self = @

    # amount interests_penalties
    $('input.amt').die()
    $('input.amt').live 'focusout keyup', (event)->
      return false if _b.notEnter(event)

      val = this.value * 1
      if this.id == 'account_ledger_exchange_rate'
        $(this).val(val.round(4))
      else
        $(this).val(val.round(2))
      self.calculateTotal()

    # select
    @$account.live 'change keyup', (event)->
      self.setCurrency()
  # sets currency
  setCurrency: ->
    val = @$account.val()

    switch
      when val.match /^\d+$/
        val = val * 1
        @.showCurrency(@accounts[val].currency_id)
      else
        @.showExchange(false)
  # Show currency
  showCurrency: (currency_id)->
    symbol = @currencies[currency_id].symbol
    $("span.currency").html("(#{symbol})")

    @.showExchange currency_id != @currency_id
    @$exchange.val(1) if currency_id == @currency_id

  # show the exchange
  showExchange: (val)->
    if val
      $('div.exchange_rate').show(300)
    else
      $('div.exchange_rate').hide(300)

  # Calculates total
  calculateTotal: ->
    amount   = @$amount.val() * 1
    int      = @$interests.val() * 1
    exchange = @$exchange.val() * 1

    total = (amount + int) * exchange
    $('#payment_total_currency').html(_b.ntc(total))

window.Payment = Payment
