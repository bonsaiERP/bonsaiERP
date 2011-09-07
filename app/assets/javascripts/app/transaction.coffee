# Model to control the items
class ItemModel extends Backbone.Model
  initialize: ->
    @trans    = @.get("trans")
    @row      = $(@.get("row"))
    @tot      = @row.find(".total_row")
    @item_id  = @row.find("input.item_id")
    @price    = @row.find("input.price")

    oprice = @price.data("original_price") * 1
    @.set({original_price: oprice})

    @quantity = @row.find("input.quantity")
    @desc     = @row.find("input.desc")
    @del      = @row.find("a.destroy")

    @desc.data("cid", @.cid)
    @row.data("cid", @.cid)


    @.unset("row")
    @.unset("trans")
    @.calculateTotal()

    # price
    @.bind "change:price", -> @.calculateTotal()
    @.bind "change:rate", -> @.setRate()
    # quantity
    @.bind "change:quantity", -> @.calculateTotal()
    # total
    @.bind "change:total", -> @.setTotal()

    @.setEvents()
  # Set Evetns for inputs
  setEvents: ->
    self = @
    @price.bind 'keyup focusout', (event)->
      return false if _b.notEnter(event)
      price = $(this).val() * 1
      self.set({price: price.round(2)})
    @quantity.bind 'keyup focusout', (event)->
      return false if _b.notEnter(event)
      price = $(this).val() * 1
      quantity = $(this).val() * 1
      self.set({quantity: quantity.round(2)})

  # set values after autocomplete
  setValues: (ui)->
    rate = @collection.trans.get("exchange_rate")
    oprice = ui.item.price * 1
    price = (oprice * 1/rate).round(2)
    @item_id.val(ui.item.id)
    @price.val(price)
    @desc.val(ui.item.label)
    @.set({item_id: ui.item.id, description: ui.item.label, price: price, original_price: oprice})
  # set the exchange rate
  setRate: ->
    price = @.get("original_price") * ( 1/@.get("rate") )
    @price.val(price.round(2))
    @.set({price: price})
  # Total
  calculateTotal: ->
    total = @.get("quantity") * @.get("price")
    @.set({total: total})
  # sets the total
  setTotal: ->
    @tot.html(_b.ntc(@.get("total") ) )
    $('body').trigger("subtotal")

#class ItemView extends Backbone.View

window.ItemModel = ItemModel


class ItemCollection extends Backbone.Collection
  model: ItemModel
  # Init
  initialize: ->
    self = @

    # Set Item events
    @.setItemEvents()

    # Remove
    @.bind "remove", -> $('body').trigger("subtotal")

    # Tax Event for trans
    #@trans.bind "taxes:change"


  # Item Events
  setItemEvents: ->
    self = @
    # Convert to autocomplete
    $('input.desc').live 'focusin', ->
      return false if $(this).hasClass("ui-autocomplete-input")
      $('input.desc.ui-autocomplete-input').autocomplete("destroy")
      $(this).autocomplete(
        source: "/item_autocomplete"
        select: (event, ui)->
          item = self.getByCid($(this).data("cid"))
          item.setValues(ui)
          false
      )

    ##########
    # Events for items
    # add
    $('a#add_item').live 'click', (event)-> self.addItem()
    # remove
    $('tr.item a.destroy').live 'click', (event)-> self.removeItem(this)
  # setTransaction
  setTrans: (@trans)->
    self = @

    # Change discount
    @trans.bind("change:discount", ->
    )

    $('#items_table').find("tr.item").each (i, row)->
      item_id  = $(row).find("input.item").val() * 1
      desc     = $(row).find("input.desc").val()
      price    = $(row).find("input.price").val() * 1
      quantity = $(row).find("input.quantity").val() * 1
      # Create
      item = new ItemModel({item_id: item_id, description: desc, price: price, quantity: quantity, trans: self.trans, row: row, rate: self.trans.get("exchange_rate")})

      self.add(item)
    # trigger subtotal
    $('body').trigger("subtotal")

  # Adds and item to the collection
  addItem: ->
    row = @.createNewRow()
    $('tr.subtotal').before(row)
    item = new ItemModel({item_id: '', description: '', price: 0, quantity: 0, trans: @.trans, row: row})
    @.add(item)
  # Remove item
  removeItem: (el)->
    if @.length <= 1
      alert "Debe existir al menos un ítem"
      return false

    row = $(el).parents("tr")
    cid = row.data("cid")
    input = row.next("input:hidden")
    # remove
    if input.length > 0
      $('<input/>').attr(
        type: 'hidden',
        name: input.attr("name").replace(/id/, '_destroy')
        value: 1
      ).insertAfter(input)

    @.remove(@.getByCid(cid))
    row.remove()

  # Creates a new Row
  createNewRow: ->
    row = $('<tr/>').addClass("item")
    .html($('tr.item:first').html())
    row.find("input.desc").removeClass("ui-autocomplete-input")
    num = (new Date).getTime()

    row.find("input").each (i, el)->
      if el.name
        $(el).attr({ name: el.name.replace(/\d+/, num), id: el.id.replace(/\d+/, num)} )
      $(el).val('')
    row.find(".total_row").html("")
    row

  # changes the rate to all items
  changeRate: ->
    trans = @trans
    @models.each (model)->
      model.set({rate: trans.get("exchange_rate")})
  # Calculates the total
  subtotal: ->
    @.reduce( (sum, item)->
      sum += item.get("total")
    , 0)
  # changes the prices for all items


# Principal class to control all behabeviour
class TransactionModel extends Backbone.Model
  # set defaults
  defaults:
    discount: 0
    discount_total: 0
    taxes: 0
    taxes_total: 0

  # Init
  initialize: ->
    self = @

    @currencies = @.get("currencies")
    @exchange_rates = @.get("exchange_rates")
    @default_currency = @.get("default_currency")

    # Set currency symbols
    @.set({
      currency_symbol: @.getCurrencySymbol(@.get("currency_id")),
      default_symbol: @.getCurrencySymbol(@.get("default_currency"))
    })

    @.bind "change:currency_id", (model, currency)->
      @.set({ currency_symbol: @currencies[currency].symbol })
      @.setCurrency()

    # Set the views for each row
    @items = new ItemCollection
    @items.setTrans(@)

    $('body').live 'subtotal', (event)-> self.setSubtotal()

    # Discount
    @.discountEvent()
    @.bind("change:discount", @.setDiscount)
    # Tax Event
    @.taxesEvent()
    @.bind("change:taxes", @.setTaxes)
    # Exchange rate
    @.bind("change:exchange_rate", ->
      $('#transaction_exchange_rate').val(self.get("exchange_rate"))
      @items.changeRate()
    )

  # set Currency
  setCurrency: ->
    $('.currency').html(@.get("currency_symbol"))
  # set subtotal
  setSubtotal: ->
    subtotal = @items.subtotal()
    @.set({subtotal: subtotal})
    $('#subtotal').html(_b.ntc(subtotal) )
    @.setDiscount()

  # discount Event
  discountEvent: ->
    self = @
    $('#transaction_discount').live 'keyup focusout', (event)->
      return false if _b.notEnter(event)
      val = (this.value * 1).round(2)
      $(this).val(val)
      self.set({discount: (val/100).round(4)})

  # Sets the discount
  setDiscount: ->
    discount = @.get("subtotal") * @.get("discount")
    @.set({discount_total: discount})
    $('#discount_total').html("- " + _b.ntc(discount))
    @.setTaxes()
  # Taxes event
  taxesEvent: ->
    self = @
    $('#taxes input:checkbox').live 'click', (event)->
      sum = 0
      $('#taxes input:checked').each (i, el)->
        sum += ($("#span#{el.value}.tax").data("rate") * 1)

      self.set({taxes: ( sum/100 ).round(4)})
  # set Taxes
  setTaxes: ->
    taxes = (@.get("subtotal") - @.get("discount_total")) * @.get("taxes")
    @.set({taxes_total: taxes})
    $('#taxes_percentage').html( _b.ntc(100 * @.get("taxes") ) )
    $('#taxes_total').html(_b.ntc(taxes))
    @.setTotal()
  # total
  setTotal: ->
    total = @.get("subtotal") - @.get("discount_total") + @.get("taxes_total")
    $('#total_value').html(_b.ntc(total))

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
      unless self.model.get("currency_id") == self.model.get("default_currency")
        self.openDialog()
      else
        self.model.set({exchange_rate: 1})
        self.setLabel()
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
    @label.find("span.rate_details").html('')
    unless @model.get("currency_id") == @model.get("default_currency")
      html = [@model.get("currency_symbol"), " 1 = ",
      "<strong>", @model.get("default_symbol"), " ", _b.ntc(@model.get("exchange_rate"), 4), "</strong>",
      ' <a href="javascript:" id="edit_exchange_rate_link">editar tipo de cambio</a>']
      @label.find("span.rate_details").html(html.join(""))

  # Change in exchange rate
  setExchange: ->
    rate = ($(@el).find("#exchange_rate").val() * 1).round(4)
    @model.set({exchange_rate: rate})
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

    @transaction = new TransactionModel(
      currencies: @currencies,
      exchange_rates: @rates,
      default_currency: @default_currency,
      currency_id: currency_id,
      exchange_rate: exchange_rate
    )
    @.setEvents()
    # Dialog
    @rate_dialog = new ExchangeRateDialog({model: @transaction, el: @.createExchangeRateDialog() })
    @rate_dialog.setLabel()
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
