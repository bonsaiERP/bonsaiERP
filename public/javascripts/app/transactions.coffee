# Class that helps to do all calculations
# This is encharged for all configuration in the transactions
class Transaction
  # default configuration with ids from the form
  conf: {
    'table_id'                  : '#items_table',
    'taxes_id'                  : '#taxes',
    'subtotal_id'               : '#subtotal',
    'discount_percentage_id'    : '#discount_percentage',
    'discount_total_id'         : '#discount_total',
    'taxes_total_id'            : '#taxes_total',
    'taxes_percentage_id'       : '#taxes_percentage',
    'total_id'                  : '#total_value',
    'items_table_id'            : '#items_table',
    'add_item_id'               : '#add_item',
    'default_currency_id'       : 1,
    'one_item_table_warning'    : "Error: Debe existir al menos un ítem",
    'currency_exchange_rate_id' : ""
  },
  currency_id   : 1,
  exchange_rate : 1,

  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {})->
    self = this
    #self['currency_id'] = 2#conf.currency_id
    @conf              = $.extend(@conf, conf)
    @.currency_id   = $(@conf.currency_id).val() * 1
    @.exchange_rate = $(@conf.currency_exchange_rate_id).val() * 1

    @.set_events()
    $("#{@conf.table_id} select:first").trigger('change')

  # Sets the events
  set_events: ->
    @.set_currency_event()
    @.set_edit_rate_link_event()
    @.set_discount_event()
    @.set_taxes_event()
    @.set_item_change_event("table select.item", "input.price")
    @.set_price_quantity_change_event("table", "input.price", "input.quantity")
    @.set_add_item_event()
    @.set_delete_item_event()
    @.set_total_event()
    @.check_currency_data()

  # Event for the total currency
  set_total_event: ->
    self = this
    $('body').live('total', ->
      self.set_total_currency()
    )

  # Event for currency change
  set_currency_event: ->
    self = this
    $(@conf.currency_id).live("change keyup", (e)->
      if e.type == "keyup" and not (e.keyCode == $.ui.keyCode.UP or e.keyCode == $.ui.keyCode.DOWN)
        return false
      self.set_exchange_rate()
    )

  # Set event for the edit change rate link
  set_edit_rate_link_event: ->
     self = this
     $('#edit_rate_link').live("click", ->
       rate = prompt("Tipo de cambio", $(self.conf.currency_exchange_rate_id).val()) * 1
       if rate > 0
         $(self.conf.currency_exchange_rate_id).val(rate.toFixed(4))
         self.exchange_rate = rate
         $('body').trigger('total')
         self.set_exchange_rate_html()
     )

  # Event when changed discount rate
  set_discount_event: ->
    self = this
    $(@conf.discount_id).live("change", ->
      val = $(this).val() * 1
      $(self.conf.discount_percentage_id).html(_b.ntc(val)).data("val", val)
      self.calculate_discount()
    )

  # Sets the events for calculating taxes, triggering body
  # with arguments: Ej. [{checked: true, rate: 12.3}]
  # @param String id
  set_taxes_event: (id = @conf.taxes_id)->
    self = @
    # Used click instead of click because IE
    $(id).find("input").click( ->
      sum = 0
      sum += 1 * $(k).siblings("span").data("rate") for k in $(self.conf.taxes_id).find("input:checkbox:checked")

      $(self.conf.taxes_percentage_id).html(_b.ntc(sum)).data("val", sum)
      self.calculate_taxes()
    )

  # Sets the item change event
  set_item_change_event: (item_sel, price_sel)->
    self = @

    $(item_sel).live("change keyup", (e)->
      id = $(this).val()
      item = self.search_item(id)

      if id != ""
        $(this).parents("tr:first").find(price_sel).val( item.price ).trigger("change")
      #$(self.trigger).trigger("item:change", [this, item])
    )

  # triggers the price and qunaitty change
  set_price_quantity_change_event: (grid_sel, price_sel, quantity_sel)->
    self = @

    $(grid_sel).find("#{price_sel}, #{quantity_sel}").live("change", ->
      self.calculate_total_row(@, "input.price, input.quantity", "td.total_row")
    )

  # Set the event for add_item row to the table
  set_add_item_event: ->
    self = this

    $(@conf.add_item_id).live("click", ->
      self.add_item()
    )

  # Sets the event for removing items from the list
  set_delete_item_event: ->
    self = this

    $(@conf.table_id).find("a.destroy").live("click", ->
      if $(self.conf.table_id).find("tr.item").length <= 1
        alert(self.conf.one_item_table_warning)
        return false

      $tr = $(this).parents('tr')
      $input = $tr.next('input:hidden')
      $tr.detach()

      name = $input.attr("name").replace("[id]", "[_destroy]")
      dest = $('<input/>').attr({'type': 'hidden', 'value': 1, 'name': name})
      $input.after(dest)

      self.calculate_total_row($(self.conf.table_id).find("tr:first"), "input.price,input.quantity", "td.total_row")
    )

  # Sets the exchange rate for the current
  set_exchange_rate: ->
    self = this
    self.currency_id = 1 * $(@conf.currency_id).val()

    if @conf.default_currency_id == self.currency_id
      $(@conf.currency_id).siblings("label").find("span").html("")
      $(@conf.currency_exchange_rate_id).val(1)
      self.exchange_rate = 1

      $('#total_value_currency').html("")
      $('#currency_symbol').html("")
    else
      base = this.find_currency(@conf.default_currency_id)
      change = this.find_currency(self.currency_id)
      self.exchange_rate = self.find_exchange_rate(self.currency_id)
      # set value
      $(@conf.currency_exchange_rate_id).val(self.exchange_rate)
      $(@conf.currency_id).data({'base': base, 'change': self.exchange_rate})

      this.set_exchange_rate_html()
      this.set_total_currency()

   # sets the HTML for the span of exchange rate
  set_exchange_rate_html: ->
    self          = this
    $span         = $(@conf.currency_id).siblings("label").find("span")
    currency      = this.find_currency(@conf.default_currency_id)
    change        = this.find_currency(this.currency_id)
    exchange_rate = $(@conf.currency_exchange_rate_id).val() * 1
    html          = "1 #{change.name}                                   = <span class = 'b'>#{_b.ntc(exchange_rate, 4)}</span> #{currency.name.pluralize()} "

    html += "<a id='edit_rate_link' href='javascript:'>editar</a>"
    try
      $span.html( html ).mark()
    catch e

  # Returs the details for a currency
  find_currency: (currency_id)->
    for k in @currencies
      return k if k.id == currency_id

  # Finds the exchange rate for a currency
  find_exchange_rate: (currency_id)->
    for k in @exchange_rates
      rate = k.rate * 1 if k.currency_id == currency_id

    rate

  # Calculates the total for a row in the grid
  # @param DOM el
  # @param String selectors "input.price,input.name"
  calculate_total_row: (el, selectors, res)->
    tot = 1
    $tr = $(el).parents("tr:first")

    $tr.find(selectors).each((i, el)->
      tot = tot * $(el).val()
    )
    $tr.find(res).html(_b.ntc(tot)).data("val", tot)

    @.calculate_subtotal("table #{res}")

  # Calculates the subtotal price for all items
  calculate_subtotal: (selector)->
    sum = 0
    $(selector).each((i, el)->
      sum += $(el).data("val") || 0
    )

    $(@conf.subtotal_id).html(_b.ntc(sum)).data("val", sum)
    @.calculate_discount()

  # Calculates the total amount of discount
  calculate_discount: ->
    val = $(@conf.discount_id).val()/100 * $(@conf.subtotal_id).data("val") || 0
    $(@conf.discount_total_id).html(_b.ntc(val)).data("val", -1 * val)
    @.calculate_taxes()

  # Calculates the total taxes
  calculate_taxes: ()->
    val = ($(@conf.subtotal_id).data("val") + $(@conf.discount_total_id).data("val")) * $(@conf.taxes_percentage_id).data("val")/100 || 0
    $(@conf.taxes_total_id).html(_b.ntc(val)).data("val", val)
    @.calculate_total()

  # Calculate total price
  calculate_total: ()->
    sum = $(@conf.subtotal_id).data("val") + $(@conf.discount_total_id).data("val") + $(@conf.taxes_total_id).data("val") || 0
    currency = this.find_currency(@conf.default_currency_id)
    $(@conf.total_id).html("#{currency.symbol} #{_b.ntc(sum)}").data("val", sum)
    $('body').trigger('total', [sum])

  # Adds a nes item
  add_item: ->
    $tr = $("#{@conf.items_table_id} tr:eq(1)").clone()
    pos = (new Date()).getTime()

    $tr.find("input, select").each((i, el)->
      name = $(el).attr("name").replace(/\[\d+\]/, "[#{pos}]")
      $(el).attr("name", name).val("")
    )
    $tr.find("td.total_row").html(_b.ntc(0))
    $tr.insertBefore("#{@conf.items_table_id} tr.extra:first")

  # checks that the currency data is available
  check_currency_data: ->
    if @conf.default_currency_id != this.currency_id
      this.set_exchange_rate_html()

  # returns the item from a list
  search_item: (id)->
    id = parseInt(id)
    for k in @items
      return k if id == k.id

  # Sets the value value
  set_total_currency: ->
    tot_currency = $(@conf.total_id).data('val') / this.exchange_rate || 0
    currency = this.find_currency(this.currency_id)

    $('#total_value_currency').html("#{currency.symbol} #{_b.ntc(tot_currency)}")
    $('#currency_symbol').html("Total #{currency.name.pluralize()}")

window.Transaction = Transaction

# Class for incomes
class Income extends Transaction
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {}, @currencies, @exchange_rates)->
    self = this
    @conf['currency_id']                 = '#income_currency_id'
    @conf['discount_id']                 = '#income_discount'
    @conf['currency_exchange_rate_id']   = '#income_currency_exchange_rate'
    @conf['edit_rate_link_id']           = '#edit_rate_link'
    @conf['insert_exchange_rate_prompt'] = "Ingrese el tipo de cambio"
    super


  # Override the default event because when the currency is changed the prices change#Event for currency change
  # Sets the exchange rate for the current
  #set_exchange_rate: ->
  #  super
  #  unless @conf.default_currency_id == this.currency_id
  #    this.set_total_currency()
  #  else
  #    $('#total_value_currency').html("")
  #    $('#currency_symbol').html("")


window.Income = Income

# Set defaults for this class
class Buy extends Transaction
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {}, @currencies, @exchange_rates)->
    self = this
    @conf['currency_id']                 = '#buy_currency_id'
    @conf['discount_id']                 = '#buy_discount'
    @conf['currency_exchange_rate_id']   = '#buy_currency_exchange_rate'
    @conf['edit_rate_link_id']           = '#edit_rate_link'
    @conf['insert_exchange_rate_prompt'] = "Ingrese el tipo de cambio"
    super

window.Buy = Buy

# Set defaults for expenses
class Expense extends Transaction
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {}, @currencies, @exchange_rates)->
    self = this
    @conf['currency_id']                 = '#expense_currency_id'
    @conf['discount_id']                 = '#expense_discount'
    @conf['currency_exchange_rate_id']   = '#expense_currency_exchange_rate'
    @conf['edit_rate_link_id']           = '#edit_rate_link'
    @conf['insert_exchange_rate_prompt'] = "Ingrese el tipo de cambio"
    super

window.Expense = Expense
