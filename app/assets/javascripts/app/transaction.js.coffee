# Model to control the items
class Item extends Backbone.Model
  defaults:
    item_id: 0
    price: 0
    quantity: 1
    subtotal: 0
    rate: 1
  #
  initialize: ->
    @on('change:price change:quantity change:rate', @setSubtotal)
    @on('change:item', @setPrice)
    @setSubtotal()
  #
  setSubtotal: ->
    sub = ( 1 * @get('quantity') * 1 * @get('price')  ) / (1 * @get('rate') )
    @set('subtotal', sub)
  #
  setAutocompleteEvent: (el) ->
    $(el).on 'autocomplete-done', 'input.autocomplete', (event, item) =>
      q = @get('quantity') * 1
      q = 1 unless q <= 0

      @set(price: item.price, quantity: q, item_id: item.id)

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
    sub = @reduce((sum, p)->
      sum + p.get('subtotal')
    , 0)

    $(@subtotalPath).html(sub)

    @calculateTotal(sub)
  #
  calculateTotal: (sub)->
    tot = sub
    $(@totalPath).val(tot)
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
  #
  setCurrency: ->
    el = _.find( $('#transaction_currency_id').get(0).options, (el) =>
      el.value == @get('currency_id')
    )

    code = $(el).text().split(' ')[0]
    rate = fx.convert(1, {from: code, to: @.get('baseCode')})
    @set(code: code, rate: rate)

    @setCurrencyLabel()

  setCurrencyLabel: ->
    html = "1 #{@get('code')} = "
    label = "<span class='label label-inverse'>#{@get('code')}</span>"
    $('.currency').html(label)

window.App.TransactionCurrency = TransactionCurrency
