class ExchangeRate extends Backbone.Model
  constructor: (input, observe, @currency_id, @accounts, @currencies, @options)->
    @$input  = $(input)
    @observe = observe
    @$label  = @$input.siblings 'label'

    @$currencies = @$label.find(".currencies")
    @$hide   = if @options["hide"] then $(@options["hide"]) else @$input.parents "div:first"

    @.setEvents()
    # Set rate if exists
    if @$input.val().match(/^\d+$/) or $(@observe).val().match(/^\d+$/)
      rate = @$input.val() * 1
      curr = $(@observe).val() * 1
      @.set({rate: rate, "currency": @currencies[curr]})

  # Events
  setEvents: ->
    @.bind "change:rate", -> @.triggerExchange
    @.bind "change:currency", -> @.triggerExchange

    @.chageCurencyEvent()
    @.rateEvents()
  # trigger for rate and currency
  triggerExchange: ->
    @.setSuggestRates()
    @.setRate()
    @.setCurrency()

    @$input.trigger("exchange_rate", [{rate: @.get("rate"), currency: @.get("currency") }])
  # Account event
  chageCurencyEvent: ->
    self = @

    $(@observe)
    .die('change keyup focusout')
    .live 'change keyup focusout', ->
      html = ''
      rate = 0.0
      currency_id = false

      switch
        when $(@).val().match /^\d+$/
          val = $(@).val() * 1
          @.set({currency: @currencies[@accounts[val].currency_id]})
        else
          self.$hide.hide 'slow'

  # set the rate
  setRate: ->
    @$input.val(@.get("rate"))
  # Sets the data for currency
  setCurrency: ->
    from = @currencies[@currency_id].symbol
    to   = @currencies[@.get("currency_id")].symbol
    @$currencies.html("(#{from} a #{to})")

    @.presentCurrency()
  # Presents the hidden div
  presentCurrency: ->
    if @currency_id == @.get("currency").id
      @$hide.hide('slow')
  # Set the rate for a currency
  setSuggestRates: ->
    try
      from = @currencies[@currency_id].code
      to   = @.get("currency").code
      rate = fx.convert(1, {from: from, to: to})
      inv_rate = 1/rate
      $('#suggested_exchange_rate').html(_b.ntc(rate, 4) ).data('val', rate.round(4))
      $('#suggested_inverted_rate').html(_b.ntc(inv_rate, 4) ).data('val', inv_rate.round(4))
    catch e
  # rateEvents
  rateEvents: ->
    self = @
    $('#suggested_exchange_rate').live 'click', (event)->
      self.$input.val($(this).data('val')).mark()
      self.$input.trigger("exchange_rate", [$(this).data('val')])
    # Inverted
    $('#suggested_inverted_rate').live 'click', (event)->
      if res = prompt("Tipo de cambio invertido:", $(this).data('val'))
        res = 1/(res * 1)
        self.$input.val(res.round(4)).mark()
        .trigger("exchange_rate", [$(this).data('val')])

window.ExchangeRate = ExchangeRate
