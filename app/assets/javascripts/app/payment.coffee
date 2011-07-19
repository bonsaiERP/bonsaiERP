class Payment
  constructor: (@currency_id, @accounts, @contact)->
    @.setEvents()
    @.setContactCurrencies()
  # Events
  setEvents: ->
    @.accountIdEvent()
  # Account event
  accountIdEvent: ->
    self = @

    $('#account_ledger_account_id')
    .die('change keyup focusouy')
    .live 'change keyup focusout', ->
      html = ''
      rate = 0.0

      #try
      currency_id = self.accounts[$(@).val() * 1].currency_id

      if self.currency_id != currency_id
        name = self.currencies[currency_id].name.pluralize()

        $('.exchange_rate').show('slow').mark()
        $('#exchange_rate_cur').html(name)
      else
        $('.exchange_rate').hide('slow')

      #catch e

      $('#cur').html(html).mark()

      # @param String
      createAmountInterestLabel: (currency_id)->
        cur = "#{currency_complete_plural}"
        if(@.currencies[currency_id])
          ra = this.currencies[currency_id]
          cur = ra.currency_symbol + " " + ra.currency_name.pluralize()

        $('label[for=payment_amount]').html("Cantidad (" + cur + ")")
        $('label[for=payment_interests_penalties]').html("Intereses/Penalidades (" + cur + ")")
  # Creates option box and events for the contact
  setContactCurrencies: ->
    console.log @contact
    #html = ''
    #for k in @account_currencies
    #  html += "<option class='b' val='#{-k}'>#{@account_currencies[k]}</option>"
    #$('#account_ledger_account_id').prepend(html)

window.Payment = Payment
