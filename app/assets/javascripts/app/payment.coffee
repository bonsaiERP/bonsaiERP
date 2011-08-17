# Class for payments
class Payment
  # constructor
  constructor: (@accounts, @currencies, @contact, @account_data, @currency_id)->
    @$account   = $('#account_ledger_account_id')
    @$amount    = $('#account_ledger_amount')
    @$interests = $('#account_ledger_interests_penalties')
    @$exchange  = $('#account_ledger_exchange_rate')

    @.createContactOptions()

    @.setEvents()
  # events
  setEvents: ->
    self = @

    # amount interests_penalties
    $('input.amt').live 'focusout keyup', (event)->
      return false if event.type == 'keyup' and event.keyCode != $.ui.keyCode.ENTER

      val = this.value * 1
      $(this).val(val.round(2))
      self.calculateTotal()

    # select
    @$account.live 'change keyup', (event)->
      self.setCurrency()
  # Creates other options for the contact accounts
  createContactOptions: ->
    html = ""
    # Selected if any
    sel = "#{@account_data.account_id}-#{@account_data.currency_id}"

    for currency_id, amount of @contact.currencies
      if @contact.currencies[currency_id] < 0
        val = "#{@contact.id}-#{currency_id}"
        selected = if sel == val then "selected='selected'" else ""
        html += "<option class='i' value='#{val}' #{selected}>"
        cur = @currencies[currency_id * 1]
        html += "(#{cur.symbol} #{Math.abs amount}) #{@contact.name}</option>"

    @$account.find("option:first").after(html)

  # sets currency
  setCurrency: ->
    val = @$account.val()

    switch
      when val.match /^\d+$/
        val = val * 1
        @.showCurrency(@accounts[val].currency_id)
      when val.match /^\d+-\d+/
        arr = val.split("-")
        @.showCurrency(arr[1] * 1)
      else
        @.showExchange(false)
  # Show currency
  showCurrency: (currency_id)->
    symbol = @currencies[currency_id].symbol
    $("span.currency").html("(#{symbol})")

    @.showExchange currency_id != @currency_id

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
    $('#total_currency').html(_b.ntc(total))

window.Payment = Payment
