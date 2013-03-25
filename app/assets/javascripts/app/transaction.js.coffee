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

# Uses the Item#buy_price instead of Item#price
class ExpenseItem extends Item
  setAutocompleteEvent: (el) ->
    $(el).on 'autocomplete-done', 'input.autocomplete', (event, item) =>
      q = @get('quantity') * 1
      q = 1 unless q <= 0

      price = _b.roundVal( item.buy_price * (1/@get('rate')), _b.numPresicion )

      @set(original_price: item.price, price: price, quantity: q, item_id: item.id)



class Transaction extends Backbone.Collection
  model: Item
  total: 0.0
  totalPath: '#total'
  subtotalPath: '#subtotal'
  #
  initialize: (@currency) ->
    @$table = $('#items-table')
    @itemTemplate = _.template(itemTemplate)

    # Events
    @on 'change', @calculateSubtotal
    self = this
    @currency.on 'change:rate', ->
      self.setCurrency(this)

    @$addLink = $('#add-item-link')
    @$addLink.click => @addItem()
  #
  calculateSubtotal: ->
    sub = @reduce((sum, p) ->
      if p.attributes.item_id?
        sum + p.get('subtotal')
      else
        sum + 0.0
    , 0.0)

    $(@subtotalPath).html(_b.ntc(sub) )

    @calculateTotal(sub)
  #
  calculateTotal: (sub)->
    tot = sub
    $(@totalPath).val(tot.toFixed(Config.precision))
  #
  setList: ->
    @$table.find('tr.item').each (i, el) =>
      @add($(el).data('item') )
      item = @models[@length - 1]
      rivets.bind(el, {item: item})
      item.setAutocompleteEvent(el)
  #
  addItem: ->
    num = (new Date).getTime()

    $tr = $(@getItemHtml(num)).insertBefore('#subtotal-line')

    $tr.createAutocomplete()
    @add(rate: @currency.get('rate') )
    item = @models[@length - 1]
    rivets.bind($tr, {item: item})
    item.setAutocompleteEvent($tr)
  #
  getItemHtml: (num) ->
    #itemTemplate.replace(/\$num/g, num)
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
    @itemTemplate(num: num, klass: 'income', search_path: 'search_income')

class Expense extends Transaction
  model: ExpenseItem
  getItemHtml: (num) ->
    @itemTemplate(num: num, klass: 'expense', search_path: 'search_expense')
  #
  setList: ->
    @$table.find('tr.item').each (i, el) =>
      data = $(el).data('item')
      data.price = data.buy_price
      @add( data )
      item = @models[@length - 1]
      rivets.bind(el, {item: item})
      item.setAutocompleteEvent(el)

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
          <input id="{{klass}}_{{klass}}_details_attributes_{{num}}_item_id" name="{{klass}}[{{klass}}_details_attributes][{{num}}][item_id]" type="hidden"/>
          <input class="autocomplete optional item_id ui-autocomplete-input span11" data-source="/items/{{search_path}}.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off"/>
          <a href="/items/new" class="ajax btn btn-small" rel="tooltip" style="margin-left: 5px;" title="Nuevo ítem"><i class="icon-plus-sign icon-large"></i></a>
          <span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span>
        </div>
      </div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-original-price="null" data-value="item.price" id="{{klass}}_{{klass}}_details_attributes_{{num}}_price" name="{{klass}}[{{klass}}_details_attributes][{{num}}][price]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-value="item.quantity" id="{{klass}}_{{klass}}_details_attributes_{{num}}_quantity" name="{{klass}}[{{klass}}_details_attributes][{{num}}][quantity]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td class="total_row r">
      <span data-text="item.subtotal | number"></span>
    </td>
    <td class="del"><a href="javascript:;" class="bicon-trash" title="Borrar" rel="tooltip" data-on-click="item:delete"></a></td>
</tr>"""
