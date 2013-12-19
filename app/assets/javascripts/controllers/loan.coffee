# Controller for creating the Loans
myApp.controller 'LoanController', ['$scope', ($scope) ->
  $scope.accounts = angular.element('#accounts').data('accounts')
  $scope.same_currency = true

  # Set select2
  $('#account_to_id').select2(
    data: $scope.accounts
    formatResult: App.Payment.paymentOptions
    formatSelection: App.Payment.paymentOptions
    escapeMarkup: (m) -> m
    dropdownCssClass: 'hide-select2-search'
    placeholder: 'Seleccione la cuenta'
  )
  .on('change', (event) ->
    data = $(this).select2('data')
    sc = $scope.baseCurrency is data.currency
    $scope.$apply (scope) ->
      scope.same_currency = sc
      scope.exchange_rate = 7
    $('.currency').html _b.currencyLabel data.currency
  )

]
