myApp.directive('initial', ->
  {
    restrict: 'A',
    controller: [
      '$scope', '$element', '$attrs', '$parse', ($scope, $element, $attrs, $parse) ->
        val = $attrs.value or $attrs.ngInitial
        val = val *  1 if $attrs.type is 'number'

        getter = $parse($attrs.ngModel)
        setter = getter.assign
        setter($scope, val)
    ]
  }
)
.directive('ngMovementAccounts', ->
  {
    restrict: 'A',
    controller: ['$scope', '$element', '$attrs', ($scope, $element, $attrs) ->
      $scope.accounts = $('#accounts').data('accounts')

      # Set select2
      $element.select2(
        data: $scope.accounts
        minimumResultsForSearch: if $scope.accounts.length > 8 then 1 else -1
        formatResult: Plugin.paymentOptions
        formatSelection: Plugin.paymentOptions
        escapeMarkup: (m) -> m
        dropdownCssClass: 'hide-select2-search'
        placeholder: 'Seleccione la cuenta'
        formatNoMatches: (term) -> 'No se encontro resultados'
      )
      .on('change', (event) ->
        data = $element.select2('data')
        $scope.currency = data.currency
      )

      $scope.$watch 'account_to_id', (ac_id) ->
        $element.select2('val', ac_id)

    ]
  }
)

