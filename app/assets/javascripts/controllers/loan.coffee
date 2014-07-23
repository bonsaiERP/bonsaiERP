# Controller for creating the Loans
myApp.controller('LoanController', ['$scope', ($scope) ->
  $scope.accounts = angular.element('#accounts').data('accounts')
  $scope.same_currency = true

  # Set select2
  $('#account_to_id').select2(
    data: $scope.accounts
    minimumResultsForSearch: if $scope.accounts.length > 8 then 1 else -1
    formatResult: Plugin.paymentOptions
    formatSelection: Plugin.paymentOptions
    escapeMarkup: (m) -> m
    dropdownCssClass: 'hide-select2-search'
    placeholder: 'Seleccione la cuenta'
  )
  .on('change', (event) ->
    data = $(this).select2('data')
    sc = $scope.baseCurrency is data.currency
    $scope.$apply (scope) ->
      scope.same_currency = sc
      rate = fx.convert(1, { from: data.currency, to: $scope.baseCurrency }).toFixed(4) * 1
      scope.exchange_rate = rate
    $('.currency').html _b.currencyLabel data.currency
  )
])
