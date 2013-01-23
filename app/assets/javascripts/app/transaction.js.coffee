# Model to control the items
class Item extends Backbone.Model
  defaults:
    item_id: 0
    price: 0.0
    original_price: 0.0
    quantity: 1.0
    subtotal: 0.0
    rate: 1.0
  #
  initialize: ->
    @on('change:rate', @setPrice)
    @on('change:price change:quantity', @setSubtotal )
    @setSubtotal()
  #
  setSubtotal: ->
    sub = 1 * @get('quantity') * 1 * @get('price')
    @set('subtotal', sub)
  #
  setPrice: ->
    price = _b.roundVal( @get('original_price') * (1.0 / @get('rate') ), bonsai.presicion )
    @set(price: price )
  #
  setAutocompleteEvent: (el) ->
    $(el).on 'autocomplete-done', 'input.autocomplete', (event, item) =>
      q = @get('quantity') * 1
      q = 1 unless q <= 0

      price = _b.roundVal( item.price * (1/@get('rate')), _b.numPresicion )

      @set(original_price: item.price, price: price, quantity: q, item_id: item.id)
  #
  delete: (event) =>
    src = event.currentTarget || event.srcElement
    @collection.deleteItem(this, src)

class Transaction extends Backbone.Collection
  model: Item
  total: 0
  totalPath: '#total'
  subtotalPath: '#subtotal'
  @itemTemplate: $('#item-template').html()
  #
  initialize: (@currency)->
    @$table = $('#items-table')

    # Events
    @on 'change', @calculateSubtotal
    self = this
    @currency.on 'change:rate', ->
      self.setCurrency(this)

    @$addLink = $('#add-item-link')
    @$addLink.live 'click', => @addItem()
  #
  calculateSubtotal: ->
    sub = @reduce((sum, p) ->
      if p.attributes.item_id?
        sum + p.get('subtotal')
      else
        sum + 0
    , 0)

    $(@subtotalPath).html(_b.ntc(sub) )

    @calculateTotal(sub)
  #
  calculateTotal: (sub)->
    tot = sub
    $(@totalPath).val(tot.toFixed(_b.numPrecision))
  #
  setList: ->
    @$table.find('tr.item').each (i, el) =>
      @add(item = new Item( $(el).data('item') ) )
      rivets.bind(el, {item: item})
      item.setAutocompleteEvent(el)
  #
  addItem: ->
    num = (new Date).getTime()

    if $('tr.item:last').length > 0
      $tr = $(@getItemHtml(num)).insertAfter('tr.item:last')
    else
      $tr = $(@getItemHtml(num)).insertAfter('tr.head')

    $tr.createAutocomplete()
    @add(item = new Item(rate: @currency.get('rate') ) )
    rivets.bind($tr, {item: item})
    item.setAutocompleteEvent($tr)
  #
  getItemHtml: (num) ->
    itemTemplate.replace(/\$num/g, num)
  #
  deleteItem: (item, src)->
    $row = $(src).parents('tr.item')
    if $row.attr('id')
      $input = $row.next('input')
      html = ['<input type="hidden" name="', $input.attr('name').replace(/\[id\]/, '[_destroy]')
        ,'" value="1" />'].join('')
      $(html).insertAfter($input)

    $row.remove()
    @remove(item)
    @calculateSubtotal()
  # Sets the items currency
  setCurrency: (cur) ->
    @each (el) ->
      if el.attributes.item_id?
        el.set('rate', cur.get('rate'))

class Income extends Transaction
  getItemHtml: (num) ->
    super(num).replace(/\$klass/g, 'income')

class Expense extends Transaction
  getItemHtml: (num) ->
    super(num).replace(/\$klass/g, 'expense')

@App = {}
@App.Income = Income
@App.Expense = Expense

class TransactionCurrency extends Backbone.Model
  defaults:
    currency: ''
    baseCurrency: ''
    rate: 1
  initialize: ->
    @set(currency: $('#transaction_currency').val(), baseCurrency: organisation.currency)

    @on('change:currency', =>
      @setCurrency()
      @activateExchange()
    )
    @activateExchange()
    @setCurrency()
  #
  setCurrency: ->
    rate = fx.convert(1, {from: @get('currency'), to: @get('baseCurrency') }).toFixed(4) * 1
    @set(rate: rate)
    @setCurrencyLabel()
  #
  setCurrencyLabel: ->
    html = "1 #{@get('currency')} = "
    label = Currency.label(@get('currency'))

    $('.currency').html(label)
  #
  activateExchange: ->
    if @get('baseCurrency') == @get('currency')
      $('#transaction_exchange_rate').attr('disabled', true)
    else
      $('#transaction_exchange_rate').attr('disabled', false)


window.App.TransactionCurrency = TransactionCurrency

itemTemplate = """<tr class="item" data-item="{"original_price":"0.0","price":"0.0","quantity":"1.0","subtotal":"0.0"}">
    <td class='span6 nw'>
      <div class="control-group autocomplete optional">
        <div class="controls">
          <input id="income_$klass_details_attributes_$num_item_id" name="income[$klass_details_attributes][$num][item_id]" type="hidden"/>
          <input class="autocomplete optional item_id ui-autocomplete-input span11" data-source="/items/search.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off"/>
          <a href="/items/new" class="ajax btn btn-small" rel="tooltip" style="margin-left: 5px;" title="Nuevo ítem"><i class="icon-plus-sign icon-large"></i></a>
          <span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span>
        </div>
      </div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-original-price="null" data-value="item.price" id="income_$klass_details_attributes_$num_price" name="income[$klass_details_attributes][$num][price]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-value="item.quantity" id="income_$klass_details_attributes_$num_quantity" name="income[$klass_details_attributes][$num][quantity]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td class="total_row r">
      <span data-text="item.subtotal | number"></span>
    </td>
    <td class="del"><a href="javascript:;" class="bicon-trash" title="Borrar" rel="tooltip" data-on-click="item:delete"></a></td>
</tr>"""
