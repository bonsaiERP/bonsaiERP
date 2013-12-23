# Controller for incomes and expenses
myApp.controller 'MovementController', ['$scope', 'MovementDetail', ($scope, MovementDetail) ->

  $scope.currency = $('#currency').val()
  $scope.same_currency = true
  $scope.details = []
  $scope.direct_payment = $('#direct_payment').prop('checked')

  # initialize items
  _.each $('#details').data('details'), (det) ->
    $scope.details.push(new MovementDetail(det))

  # Remove an item
  $scope.destroy = (index) ->
    if $scope.details.length is 1
      # Alert message
      return
    $scope.details.splice index, 1

  # Changes the exchange_rates on the details
  $scope.updateDetailsExchangeRate = (rate) ->

  # Check for the change in currency and activate all methods
  $scope.$watch 'currency', (current, old, scope) ->
    curr = window.organisation.currency
    scope.same_currency = current is curr
    scope.exchange_rate = fx.convert(1, { from: current, to: curr }).toFixed(4) * 1

  # Check for cahnges on exchange_rate to update details
  $scope.$watch 'exchange_rate', ->
    _.each $scope.details, (det) ->
      det.price = _b.roundVal(det.original_price / $scope.exchange_rate, 2)

]
