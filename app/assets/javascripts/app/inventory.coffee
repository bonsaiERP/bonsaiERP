# Model
class InventoryDetail extends Backbone.Model
  defaults:
    quantity: 0.0
  #
  delete: (event) =>
    src = event.currentTarget || event.srcElement
    @collection.deleteItem(this, src)
  #
  setAutocompleteEvent: ($el) ->
    $el.on('autocomplete-done', 'input.autocomplete', (event, item) =>
      if @collection.where(item_id: item.id).length > 0
        @resetAutocompleteValue(event)
        return false

      @set(item_id: item.id)
      $el.find('.unit').text(item.unit_symbol)
    )
  #
  resetAutocompleteValue: (event) ->
    setTimeout( =>
      $el = $(event.target)
      $el.data('value', '')
      $el.val('')
      $el.siblings('input:hidden').val('')
      alert('El ítem que selecciono ya existe en la lista')
    , 50)

# Collection
class Inventory extends Backbone.Collection
  model: InventoryDetail
  initialize: ->
    @template =  _.template(itemTemplate)
    @setList()

    rivets.bind($('#items tr.last'), {inventory: this})
  #
  setList: ->
    $('#items  tr.item').each (i, el) =>
      $el = $(el)
      @add(pos: i)
      item = @models[@length - 1]
      rivets.bind($el, {item: item})
      item.setAutocompleteEvent($el)
  #
  deleteItem: (item, src) ->
    return alert "Debe existir al menos un item" if @models.length is 1

    $(src).parents('tr.item').hide()
    @remove(item)
  #
  addItem: =>
    num = new Date().getTime()
    $tr = $(@template(num: num, operation: @operation))
    $tr.insertBefore('#items tr.last')
    $tr.createAutocomplete()
    @add({num: num})
    item = @models[@length - 1]
    item.setAutocompleteEvent($tr)

    rivets.bind $tr, {item: item}

class InventoryIn extends Inventory
  operation: 'in'

class InventoryOut extends Inventory
  operation: 'out'

class TransDetail extends InventoryDetail
  #
  setAutocompleteEvent: ($el) ->
    $el.on('autocomplete-done', 'input.autocomplete', (event, item) =>
      if @collection.where(item_id: item.id).length > 0
        @resetAutocompleteValue(event)
        return false

      @set(item_id: item.id)
      $el.find('.unit').text(item.unit)
      $el.find('.available').text(_b.ntc item.quantity)
    )

class InventoryTransference extends Inventory
  model: TransDetail
  operation: 'trans'
  initialize: ->
    @template =  _.template(transTemplate)
    @setList()

    rivets.bind($('#items tr.last'), {inventory: this})

@App.InventoryOut = InventoryOut
@App.InventoryIn = InventoryIn
@App.InventoryTransference = InventoryTransference

itemTemplate = """
<tr class="item form-inline">
  <td>
    <div class="control-group autocomplete required"><div class="controls"><input name="inventories_{{operation}}[inventory_details_attributes][{{num}}][item_id]" type="hidden"><input class="autocomplete required item_id span10 ui-autocomplete-input" data-new-url="/items/new" data-source="/items.json" id="item_autocomplete" name="item_autocomplete{{num}}" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off"><a href="/items/new" class="ajax btn btn-small" title="Nuevo" data-toggle="tooltip" style="margin-left: 5px;"><i class="icon-plus-sign icon-large"></i></a><span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span></div></div>
  </td>
  <td>
    <div class="control-group decimal required inventory_in_inventory_operation_details_quantity"><div class="controls"><input class="numeric decimal required" id="inventory_in_inventory_operation_details_attributes_0_quantity" name="inventories_{{operation}}[inventory_details_attributes][{{num}}][quantity]" size="10" step="any" type="decimal" value="0.0"></div></div>
  </td>
  <td class="r"><span class="unit"></span></td>
  <td>
    <a class="dark btn" data-on-click="item:delete" href="javascript:;" title="borrar" data-toggle="tooltip">
      <i class="icon-trash" title="" data-toggle="tooltip" data-original-title="Borrar"></i>
    </a>
  </td>
</tr>
"""

transTemplate = """
<tr class="item form-inline">
  <td>
     <div class="control-group autocomplete required inventories_transference_inventory_details_item">
       <div class="controls">
         <input name="inventories_transference[inventory_details_attributes][{{num}}][item_id]" type="hidden">
         <span role="status" aria-live="polite" class="ui-helper-hidden-accessible"></span>
         <input class="autocomplete required item_id span10 ui-autocomplete-input" data-source="/inventory_transferences/1.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off">
       </div>
     </div>
  </td>
  <td>
    <span class="unit"></span>
  </td>
  <td>
    <div class="control-group decimal required inventories_transference_inventory_details_quantity">
      <div class="controls">
        <input class="numeric decimal required" name="inventories_transference[inventory_details_attributes][{{num}}][quantity]" size="10" step="any" type="decimal" value="0.0">
      </div>
    </div>
  </td>
  <td>
    <span class="available"></span>
  </td>
  <td>
    <a class="dark btn" data-on-click="item:delete" data-toggle="tooltip" href="javascript:;" title="" data-original-title="borrar">
      <i class="icon-trash"></i>
    </a>
  </td>
</tr>
"""
