$(->
  class Payment
    #
    intialize: (@currency_id, @accounts, @rates)->
      this.set_account_id_event()

    # Event for account
    set_account_id_event: ->
      $('#payment_account_id').live('change keyup', ->
        account_id = $(this).val() * 1
        #if transaction_currency_id != accounts[account_id].currency_id
        #  $('#cur').html("Tipo de cambio <a href=''>editar</a>")
        #else
        #  $('#cur').html("")
      )
)
