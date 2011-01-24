# Class that helps to do all calculations
# This is encharged for all configuration in the transactions
class Transaction
  # default configuration with ids from the form
  conf: {
    'currency_id': '#income_currency_id',
    'discount_id': '#income_discount',
    'taxes_id': '#taxes',
    'subtotal_id': '#subtotal',
    'discount_percentage_id': '#discount_percentage',
    'discount_total_id': '#discount_total',
    'taxes_total_id': '#taxes_total',
    'taxes_percentage_id': '#taxes_percentage',
    'total_id': '#total_value',
    'items_table_id': '#items_table',
    'add_item_id': '#add_item'
  },
  # Construnctor
  # params Object conf
  constructor: (@items, @trigger = 'body', conf = {})->
    self = this
    @conf = $.extend(@conf, conf)
    self.set_events()
  # Sets the events
  set_events: ->
    this.set_discount_event()
    this.set_taxes_event()
    this.set_item_change_event("table select.item", "input.price")
    this.set_price_quantity_change_event("table", "input.price", "input.quantity")
    this.set_add_item_event()
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
    $(item_sel).live("change keyup", ->
      id = $(this).val()
      item = self.search_item(id)
      $(this).parents("tr:first").find(price_sel).val( item.price ).trigger("change")
      #$(self.trigger).trigger("item:change", [this, item])
    )
  # triggers the price and qunaitty change
  set_price_quantity_change_event: (grid_sel, price_sel, quantity_sel)->
    self = this
    $(grid_sel).find("#{price_sel}, #{quantity_sel}").live("change", ->
      self.calculate_total_row(this, "input.price,input.quantity", "td.total_row")
    )
  #  Set the venet for add_item row to the table
  set_add_item_event: ->
    self = this
    $(@conf.add_item_id).live("click", ->
      self.add_item()
    )
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
  # Adds a nes item
  add_item: ->
    $tr = $("#{@conf.items_table_id} tr:eq(1)").clone()
    pos = (new Date()).getTime()
    $tr.find("input, select").each((i, el)->
      name = $(el).attr("name").replace(/\[\d+\]/, "[#{pos}]")
      $(el).attr("name", name).val("")
    )
    $tr.insertBefore("#{@conf.items_table_id} tr.extra:first")
  # returns the item from a list
  search_item: (id)->
    id = parseInt(id)
    for k in @items
      return k if id == k.id

window.Transaction = Transaction
