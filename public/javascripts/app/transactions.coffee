# Class that helps to do all calculations
# This is encharged for all configuration in the transactions
class Transaction
  # default configuration with ids from the form
  conf: {
    'table_id': '#items_table',
    'taxes_id': '#taxes',
    'subtotal_id': '#subtotal',
    'discount_percentage_id': '#discount_percentage',
    'discount_total_id': '#discount_total',
    'taxes_total_id': '#taxes_total',
    'taxes_percentage_id': '#taxes_percentage',
    'total_id': '#total_value',
    'items_table_id': '#items_table',
    'add_item_id': '#add_item',
    'default_currency_id': 1,
    'one_item_table_warning': "Error: Debe existir al menos un ítem"
  },
  currency_id: 0,
  exchange_rate: 1,
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {})->
    self = this
    @conf = $.extend(@conf, conf)
    this.currency_id = @conf.default_currency_id
    self.set_events()
  # Sets the events
  set_events: ->
    this.set_currency_event()
    this.set_edit_rate_link_event()
    this.set_discount_event()
    this.set_taxes_event()
    this.set_item_change_event("table select.item", "input.price")
    this.set_price_quantity_change_event("table", "input.price", "input.quantity")
    this.set_add_item_event()
    this.set_delete_item_event()
    this.check_currency_data()
  # Event for currency change
  set_currency_event: ->
    self = this
    $(@conf.currency_id).live("change keyup", (e)->
      if e.type == "keyup" and not (e.keyCode == $.ui.keyCode.UP or e.keyCode == $.ui.keyCode.DOWN)
        return false
      self.set_exchange_rate()
    )
   set_edit_rate_link_event: ->
     self = this
     $('#edit_rate_link').live("click", ->
       rate = prompt("Tipo de cambio", $(self.conf.currency_exchange_rate_id).val()) * 1
       if rate > 0
         $(self.conf.currency_exchange_rate_id).val(rate)
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
    self = this
    $(id).find("input:checkbox").live('click', ->
      sum = 0
      sum += 1 * $(k).siblings("span").data("rate") for k in $(self.conf.taxes_id).find("input:checkbox:checked")
      $(self.conf.taxes_percentage_id).html(_b.ntc(sum)).data("val", sum)
      self.calculate_taxes()
    )
    #$(self.trigger).trigger("tax:calculated", [taxes_subtotal] )
  # Sets the item change event
  set_item_change_event: (item_sel, price_sel)->
    self = this
    $(item_sel).live("change keyup", (e)->
      id = $(this).val()
      item = self.search_item(id)
      if id != ""
        $(this).parents("tr:first").find(price_sel).val( item.price ).trigger("change")
      #$(self.trigger).trigger("item:change", [this, item])
    )
  # triggers the price and qunaitty change
  set_price_quantity_change_event: (grid_sel, price_sel, quantity_sel)->
    self = this
    $(grid_sel).find("#{price_sel}, #{quantity_sel}").live("change", ->
      self.calculate_total_row(this, "input.price, input.quantity", "td.total_row")
    )
  #  Set the event for add_item row to the table
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
    else
      base = this.find_currency(@conf.default_currency_id)
      change = this.find_currency(self.currency_id)
      self.exchange_rate = self.find_exchange_rate(self.currency_id)
      # set value
      $(@conf.currency_exchange_rate_id).val(self.exchange_rate)
      $(@conf.currency_id).data({'base': base, 'change': self.exchange_rate})
      this.set_exchange_rate_html()

   # sets the HTML for the span of exchange rate
  set_exchange_rate_html: ->
    self = this
    $span = $(@conf.currency_id).siblings("label").find("span")
    currency = this.find_currency(@conf.default_currency_id)
    change = this.find_currency(this.currency_id)
    html = "1 #{change.name} = <span class='b'>#{self.exchange_rate}</span> #{currency.name.pluralize()} "
    html += "<a id='edit_rate_link' href='javascript:'>editar</a>"
    $span.html( html ).mark()

  # Returs the details for a currency
  find_currency: (currency_id)->
    for k in @currencies
      return k if k.id == currency_id

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

    this.calculate_subtotal("table #{res}")
  # Calculates the subtotal price for all items
  calculate_subtotal: (selector)->
    sum = 0
    $(selector).each((i, el)->
      sum += $(el).data("val") || 0
    )
    $(@conf.subtotal_id).html(_b.ntc(sum)).data("val", sum)
    this.calculate_discount()
  # Calculates the total amount of discount
  calculate_discount: ->
    val = ( -1 * $(@conf.discount_id).val() )/100 * $(@conf.subtotal_id).data("val") || 0
    $(@conf.discount_total_id).html(_b.ntc(val)).data("val", val)
    this.calculate_taxes()
  # Calculates the total taxes
  calculate_taxes: ()->
    val = ($(@conf.subtotal_id).data("val") + $(@conf.discount_total_id).data("val")) * $(@conf.taxes_percentage_id).data("val")/100 || 0
    $(@conf.taxes_total_id).html(_b.ntc(val)).data("val", val)
    this.calculate_total()
  # Calculate total price
  calculate_total: ()->
    sum = $(@conf.subtotal_id).data("val") + $(@conf.discount_total_id).data("val") + $(@conf.taxes_total_id).data("val") || 0
    $(@conf.total_id).html(_b.ntc(sum)).data("val", sum)
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
    currency_id = $(@conf.currency_id).val() * 1
    if @conf.default_currency_id != currency_id
      base = this.find_currency(@conf.default_currency_id)
      change = this.find_currency(currency_id)
      change.rate = $(@conf.currency_exchange_rate_id).val() * 1
      $(@conf.currency_id).data({'base': base, 'change': change})
      this.set_exchange_rate_html()

  # returns the item from a list
  search_item: (id)->
    id = parseInt(id)
    for k in @items
      return k if id == k.id
  # Removes an item from the list

window.Transaction = Transaction

# Class for incomes
class Income extends Transaction
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {}, @currencies, @exchange_rates)->
    self = this
    @conf['currency_id'] = '#income_currency_id'
    @conf['discount_id'] = '#income_discount'
    @conf['currency_exchange_rate_id'] = '#income_currency_exchange_rate'
    @conf['edit_rate_link_id'] = '#edit_rate_link'
    @conf['insert_exchange_rate_prompt'] = "Ingrese el tipo de cambio"
    this.set_total_event()
    super
  set_total_event: ->
    self = this
    $('body').live('total', ->
      unless self.conf.default_currency_id == self.currency_id
        self.set_total_currency()
    )
  # Override the default event because when the currency is changed the prices change#Event for currency change
  # Sets the exchange rate for the current
  set_exchange_rate: ->
    super
    unless @conf.default_currency_id == this.currency_id
      this.set_total_currency()
    else
      $('#total_value_currency').html("")
      $('#currency_symbol').html("")
  # Sets the value value
  set_total_currency: ->
    tot_currency = $(@conf.total_id).data('val') / this.exchange_rate || 0
    currency = this.find_currency(this.currency_id)
    $('#total_value_currency').html("#{_b.ntc(tot_currency)}")
    $('#currency_symbol').html("Total #{currency.name.pluralize()}")


  # Creates a message indicating that prices have changed to other currecy
  create_currency_message: (currency)->
    message = "Los items ahora tienen precios en <strong>#{currency.name.pluralize()}</strong>, transformados con el tipo de cambio seleccionado"
    $('#items_header').after("<div class='message' id='currency_message' style='display:none'><span class='close'>&nbsp;</span>#{message}</div>")
    $('#currency_message').show("slow")


window.Income = Income
