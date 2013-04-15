class Transference extends App.Payment
  accountToSel: '#transference_account_to_id'
  formSel: '#transference-form'
  verificationSel: '#transference_payment_verification'
  #
  initialize: ->
    @set('inverse', currency != @get('baseCurrency') )
    # select2 method to bind change
    @setAccountToSelect2()
    @setAccountToInit()
    @setTotalCurrency()

    # set rivets
    rivets.bind($(@formSel), {transference: this})

    @on 'change:exchange_rate change:amount', @setTotalCurrency
  #
  setAccountToInit: ->
    other = @get('baseCurrency') == @get('currency')
    @set(
      currency: 'USD'
      sameCurrency: other # Used for enable disable exchange_rate
    )

App.Transference = Transference
