# Autocomplete for movements
myApp.directive 'detailAutocomplete', ->
  restrict: 'A',
  scope: {},
  link: ($scope, $elem, $attr) ->
    mod = model = $attr.ngModel

    $elem.data 'value', $scope.$parent.detail.item
    # Set autocomplete
    $elem.autocomplete(
      source: $attr.source,
      select: (event, ui) ->
        details = $scope.$parent.$parent.details

        if _.find(details, (det) -> det.item_id == ui.item.id)
          $elem.val('')
          $('.top-left').notify(
            type: 'warning',
            message: { text: 'Ya ha seleccionado ese ítem' }
          ).show()
          return

        $scope.$apply (scope) ->
          er = scope.$parent.$parent.exchange_rate
          scope.$parent.detail.exchange_rate = er
          scope.$parent.detail.item = ui.item.label
          scope.$parent.detail.item_old = ui.item.label
          scope.$parent.detail.item_id = ui.item.id
          scope.$parent.detail.price = _b.roundVal(ui.item.price / er, 2)
          scope.$parent.detail.original_price = ui.item.price
          scope.$parent.detail.unit_symbol = ui.item.unit_symbol
          scope.$parent.detail.unit_name = ui.item.unit_name

      search: (event, ui) ->
        $elem.addClass('loading')
      response: (event, ui) ->
        $elem.removeClass('loading')
    )

    $elem.blur ->
      $scope.$apply (scope) ->
        if $scope.$parent.detail.item is ''
          scope.$parent.detail.item = ui.item.label
          scope.$parent.detail.item_old = ui.item.label
          scope.$parent.detail.item = ui.item.label
          scope.$parent.detail.item_id = ui.item.id
          scope.$parent.detail.price = ui.item.price
          scope.$parent.detail.original_price = ui.item.price
          scope.$parent.detail.exchange_rate = scope.$parent.$parent.exchange_rate
        else
          scope.$parent.detail.item = scope.$parent.detail.item_old
  #



# Autocomplete for inventories
.directive 'inventoryDetailAutocomplete', ->
  restrict: 'A',
  scope: {},
  link: ($scope, $elem, $attr) ->
    model = $attr.ngModel
    $elem.data 'value', $scope.$parent.detail.item
    # Set autocomplete
    $elem.autocomplete(
      source: $attr.source,
      select: (event, ui) ->
        details = $scope.$parent.$parent.details

        if _.find(details, (det) -> det.item_id == ui.item.id)
          $elem.val('')
          $('.top-left').notify(
            type: 'warning',
            message: { text: 'Ya ha seleccionado ese ítem' }
          ).show()
          return

        $scope.$apply (scope) ->
          scope.$parent.detail.item = ui.item.label
          scope.$parent.detail.item_old = ui.item.label
          scope.$parent.detail.item_id = ui.item.id
          scope.$parent.detail.unit = ui.item.unit_symbol
          scope.$parent.detail.stock = ui.item.stock

      search: (event, ui) ->
        $elem.addClass('loading')
      response: (event, ui) ->
        $elem.removeClass('loading')
    )

    $elem.blur ->
      $scope.$apply (scope) ->
        if $scope.$parent.detail.item is ''
          scope.$parent.detail.item_id = ui.item.id
          scope.$parent.detail.item = ui.item.label
          scope.$parent.detail.item_old = ui.item.label
          scope.$parent.detail.unit = ui.item.unit_symbol
          scope.$parent.detail.stock = ui.item.stock
        else
          scope.$parent.detail.item = scope.$parent.detail.item_old
