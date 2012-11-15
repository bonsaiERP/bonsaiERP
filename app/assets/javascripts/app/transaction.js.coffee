# Model to control the items
class Item extends Backbone.Model
  defaults:
    item_id: 0
    price: 0
    original_price: 0
    quantity: 1
    subtotal: 0
    rate: 1
  #
  initialize: ->
    @on('change:rate', @setPrice)
    @on('change:price change:quantity', @setSubtotal )
    @setSubtotal()
  #
  setSubtotal: ->
    console.log 'sub', @get('price')
    sub = 1 * @get('quantity') * 1 * @get('price')
    @set('subtotal', sub)
  #
  setPrice: ->
    console.log 'Before set price'
    price = ( @get('original_price') * @get('rate') ).toFixed(_b.currency.precision) * 1
    @set(price: price )
  #
  setAutocompleteEvent: (el) ->
    $(el).on 'autocomplete-done', 'input.autocomplete', (event, item) =>
      q = @get('quantity') * 1
      q = 1 unless q <= 0

      price = ( item.price * @get('rate') ).toFixed(_b.currency.precision) * 1

      @set(original_price: item.price, price: price, quantity: q, item_id: item.id)

class Income extends Backbone.Collection
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
    @currency.on 'change:currency_id', ->
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
    $(@totalPath).val(tot.toFixed(_b.currency.precision))
  #
  setList: ->
    @$table.find('tr.item').each (i, el) =>
      @add(item = new Item )
      rivets.bind(el, {item: item})
      item.setAutocompleteEvent(el)
  #
  addItem: ->
    num = (new Date).getTime()

    $tr = $(@getItemHtml(num)).insertAfter('tr.item:last')

    $tr.createAutocomplete()
    @add(item = new Item(rate: @currency.get('rate') ) )
    rivets.bind($tr, {item: item})
    item.setAutocompleteEvent($tr)
  #
  getItemHtml: (num) ->
    itemTemplate.replace(/\$num/g, num)
  #
  deleteItem: (item, src)->
    unless @models.length <= 2
      $(src).parents('tr.product').remove()
      @remove(prod)
      @calculateSubtotal()
  # Sets the items currency
  setCurrency: (cur) ->
    @each (el) ->
      if el.attributes.item_id?
        console.log cur.get('rate')
        el.set('rate', cur.get('rate'))


window.App = {}
window.App.Income = Income

class TransactionCurrency extends Backbone.Model
  defaults:
    currency_id: 0
    code: ''
    baseCode: ''
    rate: 1
  initialize: ->
    @set(currency_id: $('#transaction_currency_id').val(), baseCode: organisation.currency_code)

    @on('change:currency_id', @setCurrency )
    @setCurrency()
  #
  setCurrency: ->
    el = _.find( $('#transaction_currency_id').get(0).options, (el) =>
      el.value == @get('currency_id')
    )

    code = $(el).text().split(' ')[0]
    rate = fx.convert(1, {from: @get('baseCode'), to: code })
    @set(code: code, rate: rate)

    @setCurrencyLabel()
  #
  setCurrencyLabel: ->
    html = "1 #{@get('code')} = "
    label = "<span class='label label-inverse'>#{@get('code')}</span>"
    $('.currency').html(label)

window.App.TransactionCurrency = TransactionCurrency

itemTemplate = """<tr class="item">
    <td>
      <div class="control-group autocomplete optional"><div class="controls"><input id="income_transaction_details_attributes_$num_item_id" name="income[transaction_details_attributes][$num][item_id]" type="hidden"><input class="autocomplete optional item_id ui-autocomplete-input" data-source="/items/search.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off"><span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span></div></div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-original-price="null" data-value="item.price" id="income_transaction_details_attributes_$num_price" name="income[transaction_details_attributes][$num][price]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-value="item.quantity" id="income_transaction_details_attributes_$num_quantity" name="income[transaction_details_attributes][$num][quantity]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td class="total_row r">
      <span data-text="item.subtotal | number"></span>
    </td>
    <td class="del"><a href="javascript:" class="destroy" title="Borrar">&nbsp;</a></td>
</tr>"""
