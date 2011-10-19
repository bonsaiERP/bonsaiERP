# Class for payments
class Payment
  # constructor
  constructor: (@accounts, @currencies, @account_data, @currency_id)->
    @$account   = $('#account_ledger_account_id')
    @$amount    = $('#account_ledger_base_amount')
    @$interests = $('#account_ledger_interests_penalties')
    @rate = {}

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
      $(this).val(val.round(2))
      self.calculateTotal()

    # select
    @$account.live 'change keyup', (event)->
      self.setCurrency()

    $('#account_ledger_exchange_rate').live 'change:rate', (event, rate)->
      self.rate = rate
      self.calculateTotal()

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

  # Calculates total
  calculateTotal: ->
    amount   = @$amount.val() * 1
    int      = @$interests.val() * 1

    total = (amount + int) * (@rate.rate || 1)
    $('#payment_total_currency').html(_b.ntc(total))

window.Payment = Payment
