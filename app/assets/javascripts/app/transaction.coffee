# Model to control the items
class ItemModel extends Backbone.Model
  initialize: ->
    @row      = $(@.get("row"))
    @tot      = @row.find(".total_row")
    @item_id  = @row.find("input.item_id")
    @price    = @row.find("input.price")
    @quantity = @row.find("input.quantity")
    @desc     = @row.find("input.desc")
    @del      = @row.find("a.destroy")

    @desc.data("cid", @.cid)
    @row.data("cid", @.cid)

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
      return false if _b.notEnter(event)
      price = $(this).val() * 1
      self.set({price: price.round(2)})
    @quantity.live 'keyup focusout', (event)->
      return false if _b.notEnter(event)
      price = $(this).val() * 1
      quantity = $(this).val() * 1
      self.set({quantity: quantity.round(2)})

  # set values after autocomplete
  setValues: (ui)->
    @item_id.val(ui.item.id)
    @price.val(ui.item.price)
    @desc.val(ui.item.label)
    @.set({item_id: ui.item.id, description: ui.item.label, price: ui.item.price * 1})
  # Total
  total: (set)->
    total = @.get("quantity") * @.get("price")
    @tot.html(_b.ntc(total)) unless set
    total

#class ItemView extends Backbone.View

window.ItemModel = ItemModel

rowTemplate = '<tr class="item">
                        <td>
                          <input type="text" size="60" class="desc">
                          <div class="input numeric integer required"><input type="number" step="1" size="35" required="required" name="income[transaction_details_attributes][<%= num %>][item_id]" id="income_transaction_details_attributes_<%= num >_item_id" class="numeric integer required item_id"></div>
                        </td>
                        <td><div class="input numeric decimal optional"><input type="decimal" value="<%= num %>" step="any" size="8" name="income[transaction_details_attributes][<%= num %>][price]" id="income_transaction_details_attributes_<%= num %>_price" class="numeric decimal optional price"></div></td>
                        <td><div class="input numeric decimal optional"><input type="decimal" value="<%= num %>" step="any" size="8" name="income[transaction_details_attributes][<%= num %>][quantity]" id="income_transaction_details_attributes_<%= num %>_quantity" class="numeric decimal optional quantity"></div></td>
                        <td data-val="<%= num %>.<%= num %>" class="total_row r"><%= num %>,<%= num %><%= num %></td>
                        <td class="del"><a title="Borrar" class="destroy" href="javascript:">&nbsp;</a></td>
                      </tr>'

class ItemCollection extends Backbone.Collection
  model: ItemModel
  # Init
  initialize: ->
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

    # Event for adding item
    $('a#add_item').live 'click', (event)->
      self.addItem()

    $('tr.item a.destroy').live 'click', (event)->
      self.removeItem(this)

    @.bind("remove", ->
      console.log "Deleted row"
    )

    $('#transaction_discount').live 'keyup focusout', (event)->
      return false if _b.notEnter(event)
      val = (this.value * 1).round(2)
      self.trans.set({discount: val})
      $(this).val(val)

  # setTransaction
  setTrans: (@trans)->
    self = @

    # Change discount
    @trans.bind("change:discount", ->
    )

    $('#items_table').find("tr.item").each (i, el)->
      item_id  = $(el).find("input.item").val() * 1
      desc     = $(el).find("input.desc").val()
      price    = $(el).find("input.price").val() * 1
      quantity = $(el).find("input.quantity").val() * 1
      # Create
      item = new ItemModel({item_id: item_id, description: desc, price: price, quantity: quantity, trans: self.trans, row: el})

      self.add(item)
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
    @.remove(@.getByCid(cid))
    row.remove()

  # Creates a new Row
  createNewRow: ->
    row = _.template(rowTemplate)
    row({num: (new Date).getTime() } )
    console.log row
    row

  # Calculates the total
  total: ->
    @.reduce( (sum, item)->
      console.log item.total()
      sum += item.total(true)
    , 0)
  discount: ->
  taxes: ->

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
