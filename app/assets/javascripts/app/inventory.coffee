# Model
class InventoryDetail extends Backbone.Model
  initialize: ->
    @setAutocomplete()
  defaults:
    quantity: 0.0
  #
  deleteItem: (event) =>
    src = event.currentTarget || event.srcElement
    @collection.deleteItem(this, src)
  #
  setAutocomplete: ->
    @get('tr').on('autocomplete-done', 'input.autocomplete', (event, item) =>
      @get('tr').find('.unit').text(item.unit_symbol)
    )

# Collection
class Inventory extends Backbone.Collection
  model: InventoryDetail
  table: '#items'
  initialize: ->
    @setItems()
    $tr = $('#items tr.item:first').clone()
    $tr.find('input').val('')
    @template =  _.template(itemTemplate)

    rivets.bind($('#items tr.last'), {inventory: this})
  #
  setItems: ->
    $("#items tr.item").each( (i, el) =>
      $el = $(el)
      @add({tr: $el})
      item = @models[@length - 1]
      rivets.bind $el, {item: item}
    )
  #
  deleteItem: (item, src) ->
    return alert "Debe existir al menos un item" if @models.length is 1

    $(src).parents('tr.item').hide()
    @remove(item)
  #
  addItem: =>
    num = new Date().getTime()
    $tr = $(@template(num: @length))
    $tr.insertBefore('#items tr.last')
    $tr.createAutocomplete()
    @add({tr: $tr})
    item = @models[@length - 1]

    rivets.bind $tr, {item: item}


App.Inventory = Inventory

itemTemplate = """
<tr class="item">
  <td>
    <div class="control-group autocomplete required inventory_in_inventory_operation_details_item"><div class="controls"><input id="inventory_in_inventory_operation_details_attributes_0_item_id" name="inventory_in[inventory_operation_details_attributes][{{num}}][item_id]" type="hidden"><input class="autocomplete required item_id span10 ui-autocomplete-input" data-new-url="/items/new" data-source="/items.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off"><a href="/items/new" class="ajax btn btn-small" title="Nuevo" data-toggle="tooltip" style="margin-left: 5px;"><i class="icon-plus-sign icon-large"></i></a><span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span></div></div>
  </td>
  <td>
    <div class="control-group decimal required inventory_in_inventory_operation_details_quantity"><div class="controls"><input class="numeric decimal required" id="inventory_in_inventory_operation_details_attributes_0_quantity" name="inventory_in[inventory_operation_details_attributes][{{num}}][quantity]" size="10" step="any" type="decimal" value="0.0"></div></div>
  </td>
  <td><span class="unit"></span></td>
  <td>
    <a class="dark btn" data-on-click="item:deleteItem" href="javascript:;" title="borrar" data-toggle="tooltip">
      <i class="icon-trash" title="" data-toggle="tooltip" data-original-title="Borrar"></i>
    </a>
  </td>
</tr>
"""
