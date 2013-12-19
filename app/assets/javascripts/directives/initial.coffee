myApp.directive('ngInitial', ->
  {
    restrict: 'A',
    controller: [
      '$scope', '$element', '$attrs', '$parse', ($scope, $element, $attrs, $parse) ->
        val = $attrs.value || $attrs.ngInitial
        getter = $parse($attrs.ngModel)
        setter = getter.assign
        setter($scope, val)
    ]
  }
)
