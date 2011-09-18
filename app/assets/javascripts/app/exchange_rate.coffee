class ExchangeRate
  constructor: (@input, @observe, @amount, @currency_id, @accounts, @currencies, @contact, @account_data)->
    @$input = $(@input)
    @$label = @$input.siblings 'label'
    @$hide  = @$input.parents "div:first"
    @$rate  = $('account_ledger_exchange_rate')

    @$after = $('<span/>').insertAfter(@$input)
    @.setEvents()
    @.setLabel()
    @observe_many = if @amount.match(/,/) then true else false
    @.setContactCurrencies() if @contact
  # Events
  setEvents: ->
    @.accountIdEvent()
    @.setEventForCalculation()
  # Calculation events
  setEventForCalculation: ->
    self = @

    $("#{ @amount },#{ @input }").live 'focusout keyup', (event)->
      return false if _b.notEnter(event)

      amount = 0
      $(self.amount.split(",")).each (i, el)->
        number = ($(el).val() * 1).round(2)
        $(el).val(number)
        amount += number

      rate = (self.$input.val() * 1).round(4)
      self.$input.val(rate)

      self.$after.html(" #{self.$label.find('.currency_symbol').html()} #{_b.ntc(rate * amount)}")
  # Account event
  accountIdEvent: ->
    self = @

    $(@observe)
    .die('change keyup focusout')
    .live 'change keyup focusout', ->
      html = ''
      rate = 0.0
      currency_id = false

      switch
        when $(@).val().match /^\d+$/
          self.presentExchangeForAccount @.value
        else
          self.$hide.hide 'slow'

  # present
  setLabel: ->
    arr = [@$label.html(),
      " (#{@currencies[@currency_id].symbol} a <span class='currency_symbol'></span>)&nbsp;&nbsp;",
      "<a href='javascript:' class='n view_currencies'>Tipos de cambio</a>"
    ]
    @$label.html(arr.join("") )
  #
  presentExchangeForAccount: (val)->
    currency_id = @accounts[val * 1].currency_id
    @.presentHiddenDiv(currency_id)

  #
  presentHiddenDiv: (currency_id)->
    if @currency_id == currency_id
      @$hide.hide('slow')
    else
      cur = @currencies[currency_id]
      @$label.find('.currency_symbol').html(cur.symbol)
      @$hide.show('slow').mark()


  # @param String
  createAmountInterestLabel: (currency_id)->
    cur = "#{currency_complete_plural}"
    if(@currencies[currency_id])
      ra = this.currencies[currency_id]
      cur = ra.currency_symbol + " " + ra.currency_name.pluralize()

    $('label[for=payment_amount]').html("Cantidad (" + cur + ")")
    $('label[for=payment_interests_penalties]').html("Intereses/Penalidades (" + cur + ")")
  # Creates option box and events for the contact
  setContactCurrencies: ->
    html = ''
    # Selected if any
    sel = "#{@account_data.account_id}-#{@account_data.currency_id}"

    for currency_id, amount of @contact.currencies
      if @contact.currencies[currency_id] < 0
        val = "#{@contact.id}-#{currency_id}"
        selected = if sel == val then "selected='selected'" else ""
        html += "<option class='i' value='#{val}' #{selected}>"
        cur = @currencies[currency_id * 1]
        html += "(#{cur.symbol} #{Math.abs amount}) #{@contact.name}</option>"

    $('#account_ledger_account_id option:first').after(html)

window.ExchangeRate = ExchangeRate
