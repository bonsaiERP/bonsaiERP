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
    @on('change:price change:quantity', @setSubtotal)

    @setSubtotal()
  #
  setSubtotal: ->
    sub = 1 * @get('quantity') * 1 * @get('price')
    @set('subtotal', sub)
    @collection.calculateSubtotal()
  #
  setPrice: ->
    price = _b.roundVal( @get('original_price') * (1.0 / @get('rate') ), bonsai.presicion )
    @set(price: price )
  #
  setAutocompleteEvent: (el) ->
    $(el).on 'autocomplete-done', 'input.autocomplete', (event, item) =>
      if @collection.where(item_id: item.id).length > 0
        @resetAutocompleteValue(event)
        return false

      price = _b.roundVal( item.price * (1/@get('rate')), _b.numPresicion )

      @set(original_price: item.price, price: price, item_id: item.id)
  #
  resetAutocompleteValue: (event) ->
    setTimeout( =>
      $el = $(event.target)
      $el.data('value', '')
      $el.val('')
      $el.siblings('input:hidden').val('')
      alert('El ítem que selecciono ya existe en la lista')
    , 50)
  #
  delete: (event) =>
    src = event.currentTarget || event.srcElement
    @collection.deleteItem(this, src)

# Uses the Item#buy_price instead of Item#price
class ExpenseItem extends Item
  setAutocompleteEvent: (el) ->
    $(el).on 'autocomplete-done', 'input.autocomplete', (event, item) =>
      if @collection.where(item_id: item.id).length > 0
        @resetAutocompleteValue(event)
        return

      price = _b.roundVal( item.buy_price * (1/@get('rate')), _b.numPresicion )

      @set(original_price: item.buy_price, price: price, item_id: item.id)

# TransactionModel
class TransactionModel extends Backbone.Model
  defaults:
    currency: ''
    baseCurrency: ''
    rate: 1
    direct_payment: false
    total: 0.0
  initialize: ->
    cur = $('#transaction_currency').val()
    @set(
      currency: cur
      baseCurrency: organisation.currency
      sameCurrency: cur is organisation.currency
    )
    @createAccountToOptions()

    @setEvents()
    @activateExchange()
    @setCurrency()
  #
  setEvents: ->
    @on('change:currency', =>
      @setCurrency()
      @activateExchange()
      @createAccountToOptions()
    )
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
  # Creates the account_to options
  createAccountToOptions: ->
    data = _.filter(@get('accountsTo'), (v) => @get('currency') is v.currency)

    $('#account_to_id').select2('destroy')
    .select2({
      data: data,
      formatResult: App.Payment.paymentOptions,
      formatSelection: App.Payment.paymentOptions,
      dropdownCssClass: 'hide-select2-search'
      escapeMarkup: (m) -> m
    })



# Collection that holds and integrates all models Item and TransModel
class Transaction extends Backbone.Collection
  model: Item
  total: 0.0
  totalPath: '#total'
  subtotalPath: '#subtotal'
  transSel: '.trans'
  transModel: false
  accountsTo: []
  #
  initialize: ->
    total = $('#total').val()
    @$table = $('#items-table')
    @itemTemplate = _.template(itemTemplate)

    @setList()
    @calculateSubtotal()

    @$addLink = $('#add-item-link')
    @$addLink.click => @addItem()

    # Because of calculations total is lost
    $('#total').val(total)
  #
  setAccountsTo: (@accountsTo) ->
    self = this
    # TransModel
    @transModel = new TransactionModel(
      accountsTo: @accountsTo
      direct_payment: $('#direct_payment').prop('checked')
      account_to_id: $('#account_to_id').val()
    )
    rivets.bind $(@transSel), {trans: @transModel}
    @transModel.on 'change:rate', -> self.setCurrency()

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
    $tr = $(@getItemHtml()).insertBefore('#subtotal-line')

    $tr.createAutocomplete()
    @add(rate: @transModel.get('rate') )
    item = @models[@length - 1]
    rivets.bind($tr, {item: item})
    item.setAutocompleteEvent($tr)
    @calculateSubtotal()
  #
  deleteItem: (item, src) ->
    $row = $(src).parents('tr.item')
    if item.get('id')?
      item.set('_destroy', "1")
      $row.hide()
    else
      $row.detach()

    @remove(item)
    @calculateSubtotal()
  # Sets the items currency
  setCurrency: ->
    @each (el) =>
      el.set('rate', @transModel.get('rate'))


# Income
class Income extends Transaction
  getItemHtml: ->
    num = new Date().getTime()
    @itemTemplate(num: num, klass: 'incomes_form', det: 'income', search_path: 'search_income')

# Expense
class Expense extends Transaction
  model: ExpenseItem
  getItemHtml: ->
    num = new Date().getTime()
    @itemTemplate(num: num, klass: 'expenses_form', det: 'expense', search_path: 'search_expense')


@App.Income = Income

@App.Expense = Expense


itemTemplate = """<tr class="item" data-item="{"original_price":"0.0","price":"0.0","quantity":"1.0","subtotal":"0.0"}">
    <td class='span6 nw'>
      <div class="control-group autocomplete optional">
        <div class="controls">
          <input id="{{klass}}_{{det}}_details_attributes_{{num}}_item_id" name="{{klass}}[{{det}}_details_attributes][{{num}}][item_id]" type="hidden"/>
          <input class="autocomplete optional item_id ui-autocomplete-input span11" data-source="/items/{{search_path}}.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off"/>
          <a href="/items/new" class="ajax btn btn-small" rel="tooltip" style="margin-left: 5px;" title="Nuevo ítem"><i class="icon-plus-sign icon-large"></i></a>
          <span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span>
        </div>
      </div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-original-price="null" data-value="item.price" id="{{klass}}_{{det}}_details_attributes_{{num}}_price" name="{{klass}}[{{det}}_details_attributes][{{num}}][price]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-value="item.quantity" id="{{klass}}_{{det}}_details_attributes_{{num}}_quantity" name="{{klass}}[{{det}}_details_attributes][{{num}}][quantity]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td class="total_row r">
      <span data-text="item.subtotal | number"></span>
    </td>
    <td class="del"><a href="javascript:;" class="dark btn" title="Borrar" data-toggle="tooltip" data-on-click="item:delete"><i class="icon-trash"></i></a></td>
</tr>"""
