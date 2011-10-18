# Backbone model
class ExchangeRate extends Backbone.Model
  setAll: (input, observe, @currency_id, @accounts, @currencies, @options)->
    @$input  = $(input)
    @observe = observe
    @$label  = @$input.siblings 'label'

    @$currencies = @$label.find(".currencies")
    @$hide   = if @options["hide"] then $(@options["hide"]) else @$input.parents "div:first"

    # Set rate if exists
    if @$input.val().match(/^\d+$/) or $(@observe).val().match(/^\d+$/)
      rate = @$input.val() * 1
      curr = $(@observe).val() * 1
      @.set({rate: rate, "currency": @currencies[curr]})

    @.setEvents()
  # Events
  setEvents: ->
    self = @
    @$input.live 'focusout keyup', (event)->
      return false if _b.notEnter(event)
      self.set({rate: $(this).val() * 1})
    # Rate
    @.bind "change:rate", ->
      @.triggerExchange()
      @.setRate()
    # Currency
    @.bind "change:currency", ->
      @.triggerExchange()
      @.setCurrency()

    @.chageCurrencyEvent()
    @.rateEvents()
  # trigger for rate and currency
  triggerExchange: ->
    @.setSuggestRates()

    @$input.trigger("change:rate", [{rate: @.get("rate"), currency: @.get("currency") }])
  # Account event
  chageCurrencyEvent: ->
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
          self.set({currency: self.currencies[self.accounts[val].currency_id]})
        else
          self.$hide.hide 'slow'

  # set the rate
  setRate: ->
    @$input.val(@.get("rate")).mark()
  # Sets the data for currency
  setCurrency: ->
    from = @currencies[@currency_id].symbol
    to   = @.get("currency").symbol
    @$currencies.html("(#{from} a #{to})")

    @.presentCurrency()
  # Presents the hidden div
  presentCurrency: ->
    if @currency_id == @.get("currency").id
      @$hide.hide('slow')
     else
       @$hide.show('slow')
  # Set the rate for a currency
  setSuggestRates: ->
    try
      from = @currencies[@currency_id].code
      to   = @.get("currency").code
      rate = fx.convert(1, {from: from, to: to})
      inv_rate = 1/rate
      @.set({suggest_rate: rate.round(4), suggest_inv_rate: inv_rate.round(4)})
      $('#suggested_exchange_rate').html(_b.ntc(rate, 4) )
      $('#suggested_inverted_rate').html(_b.ntc(inv_rate, 4) )
    catch e
  # rateEvents
  rateEvents: ->
    self = @
    $('#suggested_exchange_rate').live 'click', (event)->
      self.set({rate: self.get("suggest_rate")})
    # Inverted
    $('#suggested_inverted_rate').live 'click', (event)->
      if res = prompt("Tipo de cambio invertido:", self.get("suggest_inv_rate"))
        res = 1/(res * 1)
        self.set({rate: res.round(4)})

window.ExchangeRate = ExchangeRate
