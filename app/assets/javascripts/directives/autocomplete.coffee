myApp.directive 'ngAutocomplete', [ ->
  restrict: 'A',
  link: ($scope, $elem, attr, ctrl) ->
    mod = model = attr.ngModel

    # Set autocomplete
    $elem.autocomplete(
      source: attr.source,
      select: (event, ui) ->
        $scope.$apply (sc) ->
          if attr.ngCollection
            ind = parseInt(attr.ngAutocomplete || attr.ngIndex)
            sc = $scope[attr.ngCollection][ind]
          else
            sc = $scope

          sc.item = ui.item.label
          sc.item_id = ui.item.id
          sc.roriginal_price = sc.price = ui.item.price

        #if attr.ngAuto
        #$scope["#{model}Attributes"] = ui.item
        #scope.$apply (sco) ->
        #console.log sco
        #$scope.$emit 'autocomplete-done', ui.item
        #sco.price = 100

      change: (event, ui) ->
    )

    $elem.blur ->
      if $scope["#{model}"] is ''
        $scope.$apply (scope) ->
          scope["#{model}"] = null
          scope["#{model}Attributes"] = {}
          scope["#{model}_id"] = null
          $scope.$emit 'autocomplete-blur'
      else
        $elem.val($scope["#{model}Attributes"].label)
]
