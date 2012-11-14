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
  #
  initialize: (currency)->
    @$table = $('#items-table')

    # Events
    @on 'change', @calculateSubtotal
    self = this
    currency.on 'change:currency_id', ->
      self.setCurrency(this)
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
  addItem: =>
    $loc = @$table.find('tr.item:last')
    $loc.after($('#item-template').html())
    tr = $loc.get(0)

    @add(p = new Item())
    rivets.bind(tr, {product: p})
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

  setCurrencyLabel: ->
    html = "1 #{@get('code')} = "
    label = "<span class='label label-inverse'>#{@get('code')}</span>"
    $('.currency').html(label)

window.App.TransactionCurrency = TransactionCurrency
