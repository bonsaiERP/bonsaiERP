# Class that helps to do all calculations
# This is encharged for all configuration in the transactions
class Events

_.extend(Events::, Backbone.Events)

this.Events = Events


class Model
  constructor: ->
    Backbone.Model.apply(this, arguments)

_.extend(Model::, Backbone.Model.prototype)

this.Model = Model


class Collection
  constructor: ->
    Backbone.Collection.apply(this, arguments)

_.extend(Collection::, Backbone.Collection.prototype)

this.Collection = Collection

class TransactionModel extends Model
  dialog_open_on_change: true

  constructor: ( @currencies, @exchange_rates, @default_currency )->
    super({currency_id: @default_currency, exchange_rate: 1})

    @currency_id          = $('#transaction_currency_id')
    @currency_id_label    = $('label[for=transaction_currency_id]')
    @exchange_rate        = $('#transaction_exchange_rate')
    @exchange_button      = $('#exchange_rate_button')

    @.setEvents()
    @.createExchangeRateDialog()

  # Init functions Events more related to change of attributes
  initialize: ->
    self = @

    @.bind "change:currency_id", ->
      self.setExchangeRateHtml()

    @.bind "change:exchange_rate", ->
      self.setExchangeRateHtml()

  # Events for showing not for interaction
  setEvents: ->
    self = @
    # Currency
    @currency_id.live 'change keyup', (event)->
      # Check the keyup event
      if event.type == "keyup" and not (event.keyCode == $.ui.keyCode.UP or evet.keyCode == $.ui.keyCode.DOWN)
        return false

      self.set {currency_id: $(this).val() * 1}

      if self.dialog_open_on_change and self.get("currency_id") != self.default_currency
        $(self.exchange_rate_dialog).dialog("open")

    # Button
    @exchange_button.live 'click', ->
      $(self.exchange_rate_dialog).dialog("close")
      self.set({exchange_rate: $('#exchange_rate').val() * 1})
    # Edit link
    $('#exchange_rate_link').live 'click', ->
      $(self.exchange_rate_dialog).dialog("open")

  # Creates the exchange rate dialog
  createExchangeRateDialog: ->
    self = @
    @exchange_rate_dialog = createDialog(
      html: $('#currency_form').html()
      title: 'Tipo de cambio'
      autoOpen: false
      width: 500
      position: 'center'
      close: (event, ui)->
        $(this).hide()
        false
    )
    $('#currency_form').remove()

  # Creates the HTML for the label
  setExchangeRateHtml: ->
    @currency_id_label.find('span.cont').remove()

    console.log @.get("currency_id"), @default_currency

    unless @.get('currency_id') == @default_currency
      html = ["<span class='cont n black'>", "Tipo de cambio ", @.getCurrencySymbol(@default_currency), " 1 = ",
      "<strong>", @.getCurrencySymbol(@.get('currency_id'))," ", _b.ntc(@.get('exchange_rate'), 4), "</strong>",
      "&nbsp;&nbsp;&nbsp;",  "<a href='javascript:' class='b pencil' id='exchange_rate_link'>editar</a>",
      "</span>"]

      @currency_id_label.append(html.join(""))

   # Gets the currency symbol
   getCurrencySymbol: (currency)->
     @currencies[currency].symbol

class IncomeModel extends TransactionModel

window.IncomeModel = IncomeModel

class Income

window.Income = Income
##################
#class TransactionModel extends Model
#
#a = new TransactionModel("prueba")
#a.bind "change:name", (model, name)->
#  alert "Nombre para: #{model} es ahora #{name}"
#
#window.a = a

#window.Income = Income
#
## Set defaults for this class
#class Buy extends Transaction
#  # Construnctor
#  # params Object conf
#  constructor: (@items, @trigger = 'body', conf = {}, @currencies, @exchange_rates)->
#    self = this
#    @conf['currency_id']                 = '#buy_currency_id'
#    @conf['discount_id']                 = '#buy_discount'
#    @conf['currency_exchange_id']        = '#buy_exchange_rate'
#    @conf['edit_rate_link_id']           = '#edit_rate_link'
#    @conf['insert_exchange_rate_prompt'] = "Ingrese el tipo de cambio"
#    super
#
#window.Buy = Buy
#
## Set defaults for expenses
#class Expense extends Transaction
#  # Construnctor
#  # params Object conf
#  constructor: (@items, @trigger = 'body', conf = {}, @currencies, @exchange_rates)->
#    self = this
#    @conf['currency_id']                 = '#expense_currency_id'
#    @conf['discount_id']                 = '#expense_discount'
#    @conf['currency_exchange_id']        = '#expense_exchange_rate'
#    @conf['edit_rate_link_id']           = '#edit_rate_link'
#    @conf['insert_exchange_rate_prompt'] = "Ingrese el tipo de cambio"
#    super
#
#window.Expense = Expense
