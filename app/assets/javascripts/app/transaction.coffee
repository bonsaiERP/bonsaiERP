# Model to control the items
class ItemModel extends Backbone.Model
  initialize: ->
    @row      = $(@.get("row"))
    @tot      = @row.find(".total_row")
    @price    = @row.find("input.price")
    @quantity = @row.find("input.quantity")

    @trans  = @.get("trans")

    @.unset("row")
    @.unset("trans")
    @.total()

    self = @
    @.bind("change:price", -> self.total())
    @.bind("change:quantity", -> self.total())

    @.setEvents()
  # Set Evetns
  setEvents: ->
    self = @
    @price.live 'keyup focusout', (event)->
      console.log event.keyCode
      return false if event.type == "keyup" and event.keyCode != $.ui.keyCode.ENTER
      price = $(this).val() * 1
      self.set({price: price.round(2)})
    @quantity.live 'keyup focusout', (event)->
      quantity = $(this).val() * 1
      self.set({quantity: quantity.round(2)})

  # Total
  total: ->
    total = @.get("quantity") * @.get("price")
    @tot.html(_b.ntc(total))
    total

#class ItemView extends Backbone.View

window.ItemModel = ItemModel
class ItemCollection extends Backbone.Collection
  model: ItemModel
  # Init
  setTrans: (@trans)->
    self = @

    $('#items_table').find("tr.item").each (i, el)->
      item_id  = $(el).find("input.item").val() * 1
      desc     = $(el).find("input.desc").val()
      price    = $(el).find("input.price").val() * 1
      quantity = $(el).find("input.quantity").val() * 1
      # Create
      item = new ItemModel({item_id: item_id, description: desc, price: price, quantity: quantity, trans: self.trans, row: el})

      self.add(item)

  addItem: ->

# Principal class to control all behabeviour
class TransactionModel extends Backbone.Model
  constructor: ( @currencies, @exchange_rates, @default_currency, currency_id, exchange_rate )->
    super(
      currency_id: currency_id,
      default_currency: @default_currency,
      exchange_rate: exchange_rate,
      default_symbol: @.getCurrencySymbol(@default_currency)
      currency_symbol: @.getCurrencySymbol(currency_id)
    )

  # Init
  initialize: ->
    self = @

    @.bind "change:currency_id", (model, currency)->
      self.set({ currency_symbol: self.currencies[currency].symbol })

    # Set the views for each row
    @items = new ItemCollection
    @items.setTrans(@)

  # Gets the currency symbol
  getCurrencySymbol: (currency)->
     @currencies[currency].symbol

window.TransactionModel = TransactionModel


# View for the template
class ExchangeRateDialog extends Backbone.View
  initialize:->
    self = @
    @label = $('label[for=transaction_currency_id]')

    @model.bind("change:currency_id", (model, name)->
      self.openDialog()
    )
    @model.bind("change:exchange_rate", (model, name)->
      self.setLabel()
    )

    $(@el).find("span.default_symbol").html(@model.get("default_symbol"))

    @.setEvents()
  # Set events for edit
  setEvents: ->
    self = @
    $('#edit_exchange_rate_link').live('click', (event)->
      self.openDialog()
      false
    )
  # Events
  events:
    "click button": "setExchange"
  # Label
  setLabel: ->
    @label.find("span.rate_details").remove()
    unless @model.get("curency_id") == @model.get("default_currency")
      span = $('<span/>').addClass("rate_details n black")
      html = [@model.get("currency_symbol"), " 1 = ",
      "<strong>", @model.get("default_symbol"), " ", _b.ntc(@model.get("exchange_rate"), 4), "</strong>",
      ' <a href="javascript:" id="edit_exchange_rate_link">editar tipo de cambio</a>']

      span.html(html.join(""))
      @label.append(span)

  # Change in exchange rate
  setExchange: ->
    @model.set({exchange_rate: $(@el).find("#exchange_rate").val() * 1 })
    @.closeDialog()
  # present dialog
  openDialog: ->
    $(@el).find("#exchange_rate").val(@model.get("exchange_rate"))
    $(@el).find("span.currency_symbol").html(@model.get("currency_symbol"))
    $( @el ).dialog("open")
  closeDialog: ->
    $( @el ).dialog("close")

window.ExchangeRateDialog = ExchangeRateDialog

class Table extends Backbone.View
  initialize: ->
    super(arguments)
    @el = $('#items_table')
    @.setHeaders()

    self = @
    # curency_id
    @model.bind("change:currency_id", ->
      self.setHeaders()
    )
  # Sets the header for the currecy
  setHeaders: ->
    $(@el).find("span.currency").html(@model.get("currency_symbol") )

# Global class that controls the events for many classes
class TransactionGlobal
  # Constructor
  constructor: (@currencies, @rates, @default_currency, currency_id, exchange_rate)->
    @currency_id = $('#transaction_currency_id')

    @transaction = new TransactionModel(@currencies, @rates, @default_currency, currency_id, exchange_rate)
    @.setEvents()
    # Dialog
    @rate_dialog = new ExchangeRateDialog({model: @transaction, el: @.createExchangeRateDialog() })
    # Table
    @table = new Table({model: @transaction})

  # Events
  setEvents: ->
    self = @
    @currency_id.live 'change', (event)->
      currency_id = $(this).val() * 1
      self.transaction.set({currency_id: currency_id})

  # Creates the exchange rate dialog for the View
  createExchangeRateDialog: ->
    createDialog(
      id: 'currency_dialog',
      html: $('#currency_form').html(),
      title: 'Tipo de cambio',
      autoOpen: false,
      width: 500,
      position: 'center',
      close: (event, ui)->
        $(this).hide()
        return false
    )


window.TransactionGlobal = TransactionGlobal
