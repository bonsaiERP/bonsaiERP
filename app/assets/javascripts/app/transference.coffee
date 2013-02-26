class Transference extends App.Payment
  accountToSel: '#transference_account_to_id'
  formSel: '#transference-form'
  initialize: ->
    @set('inverse', currency != @get('baseCurrency') )
    # select2 method to bind change
    @setAccountToSelect2()
    # set rivets
    rivets.bind($(@formSel), {transference: this})

    @searchAndSetAccountToCurrency()

    @on 'change:exchange_rate change:amount', ->
      @setTotalCurrency()
      @setCurrencyLabel()
  #
  searchAndSetAccountToCurrency: ->
    ac = _.find(@get('accountsTo'), (v) => v.id == @get('account_to_id'))
    @set('currency', ac.currency)
    @setTotalCurrency()
    @setCurrencyLabel()
  #
  convertInverse: ->
    val = if @get('inverse')
      @get('exchange_rate') * 1
    else
      1 / @get('exchange_rate') * 1

    val.toFixed(4) * 1

App.Transference = Transference
