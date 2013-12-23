# Controller for incomes and expenses
myApp.controller 'MovementController', ['$scope', 'MovementDetail', ($scope, MovementDetail) ->

  $scope.currency = $('#currency').val()
  $scope.same_currency = true
  $scope.details = []
  $scope.direct_payment = $('#direct_payment').prop('checked')
  $scope.tax_label = 'Por fuera'


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
    # Sel all clases to correct currency
    $('.currency').html(_b.currencyLabel scope.currency)

  # Check for cahnges on exchange_rate to update details
  $scope.$watch 'exchange_rate', ->
    _.each $scope.details, (det) ->
      det.price = _b.roundVal(det.original_price / $scope.exchange_rate, 2)


  # Tax label
  $scope.taxLabel = ->
    if $scope.tax_in_out is true then 'Por dentro' else 'Por fuera'

  # Subtotal
  $scope.subtotal = ->
    _.reduce( $scope.details, (s, det) ->
      console.log s
      s += det.subtotal()
    , 0)


  # total
  $scope.total = ->
    0
]
