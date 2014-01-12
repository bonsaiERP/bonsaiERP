# Go to directives/initial.coffee
#myApp.directive('ngMovementAccounts', ->
#  {
#    restrict: 'A',
#    controller: ['$scope', '$element', '$attrs', ($scope, $element, $attrs) ->
#      $scope.accounts = $('#accounts').data('accounts')
#
#      console.log $scope.account
#      # Set select2
#      $element.select2(
#        data: $scope.accounts
#        formatResult: Plugin.paymentOptions
#        formatSelection: Plugin.paymentOptions
#        escapeMarkup: (m) -> m
#        dropdownCssClass: 'hide-select2-search'
#        placeholder: 'Seleccione la cuenta'
#      )
#      .on('change', (event) ->
#        data = $element.select2('data')
#        $scope.currency = data.currency
#      )
#
#    ]
#  }
#)
#
